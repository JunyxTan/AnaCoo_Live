import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/job_repository.dart';
import '../domain/scheduling.dart';
import '../domain/shop_time.dart';
import '../l10n/app_strings.dart';
import '../providers/providers.dart';
import '../services/intake_service.dart';
import 'calendar/calendar_screen.dart';
import 'customers/customers_screen.dart';
import 'job/job_detail_screen.dart';
import 'job/job_editor_screen.dart';
import 'settings/settings_screen.dart';
import 'today/today_screen.dart';

/// Tab host, and the single place that owns the three intake entry points:
/// the Paste button, the share target, and the on-resume clipboard banner.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  int _tab = 0;
  IntakeCandidate? _banner;
  StreamSubscription<IntakeCandidate>? _shareSubscription;
  bool _startupDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shareSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startup() async {
    if (_startupDone) return;
    _startupDone = true;

    final intake = ref.read(intakeServiceProvider);
    _shareSubscription = intake.sharedText.listen(_handleCandidate);
    await intake.start();

    // Permissions, then a full re-plan: the app may have been closed for days,
    // and this is also the iOS top-up that keeps the 64-slot window full.
    final notifications = ref.read(notificationServiceProvider);
    notifications.onNotificationTapped = _openFromNotificationPayload;
    await notifications.requestPermissions();
    await ref.read(schedulerProvider).rebuild();
    ref.invalidate(notificationCapabilitiesProvider);
    ref.invalidate(pendingNotificationsProvider);

    final launchPayload = await notifications.launchPayload();
    if (launchPayload != null) {
      _openFromNotificationPayload(launchPayload);
    }

    await _maybeShowBatteryExplainer();
    await _pollClipboard();
  }

  /// Reminder / nudge payloads are `job:<id>`; agenda payloads are
  /// `agenda:YYYY-MM-DD`. Opening the right screen is what makes tapping a
  /// notification useful instead of dumping the tailor on Today.
  void _openFromNotificationPayload(String payload) {
    if (!mounted) return;
    if (payload.startsWith('job:')) {
      final id = int.tryParse(payload.substring(4));
      if (id == null) return;
      unawaited(
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => JobDetailScreen(jobId: id)),
        ),
      );
      return;
    }
    if (payload.startsWith('agenda:')) {
      setState(() => _tab = 0);
    }
  }

  Future<void> _maybeShowBatteryExplainer() async {
    final db = ref.read(databaseProvider);
    final settings = await db.loadSettings();
    if (settings.batteryExplainerSeen) return;
    if (!ref.read(notificationServiceProvider).isSupported) return;
    if (!mounted) return;
    await showBatteryExplainer(context, ref.read(appStringsProvider));
    await db.saveSettings(
      const AppSettingsCompanion(batteryExplainerSeen: Value(true)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_startupDone) return;
    // The app may have been backgrounded across midnight, so recompute what
    // "today" and "overdue" mean before anything is shown again.
    ref.invalidate(todayKeyProvider);
    ref.invalidate(overdueAppointmentsProvider);
    // Top up the notification window and re-check the clipboard, both of which
    // only make sense once the app is actually in front of the tailor.
    unawaited(ref.read(schedulerProvider).rebuild());
    unawaited(_pollClipboard());
  }

  Future<void> _pollClipboard() async {
    if (_banner != null) return;
    final candidate = await ref.read(intakeServiceProvider).pollClipboardForBanner();
    if (candidate == null || !mounted) return;
    setState(() => _banner = candidate);
  }

  /// The Paste button. Reads the clipboard because it was asked to — on iOS
  /// this is what triggers the system paste prompt.
  Future<void> _pasteAppointment() async {
    final strings = ref.read(appStringsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final candidate = await ref.read(intakeServiceProvider).readClipboard();
    if (candidate == null) {
      messenger.showSnackBar(SnackBar(content: Text(strings.clipboardEmpty)));
      return;
    }
    await _handleCandidate(candidate);
  }

  /// Imports a candidate. Complete requests save in one shot and stay on Today;
  /// incomplete ones open the editor for a quick fix.
  Future<void> _handleCandidate(IntakeCandidate candidate) async {
    if (!mounted) return;
    setState(() => _banner = null);

    final strings = ref.read(appStringsProvider);
    final hours = ref.read(workingHoursProvider);
    final slot = ref.read(slotMinutesProvider);
    final fallback = snapIntoWorkingHours(shopNow(), hours, slotMinutes: slot);

    final parsed = candidate.parsed;
    final draft = parsed == null
        ? JobDraft(
            notes: candidate.rawText,
            rawMessage: candidate.rawText,
            dropOff: AppointmentDraft(at: fallback),
          )
        : draftFromParsed(
            parsed,
            fallbackAt: fallback,
            defaultDurationMinutes: 15,
          );

    final canOneShot = parsed != null &&
        draft.hasIdentifiableCustomer &&
        parsed.date != null &&
        parsed.time != null;

    if (canOneShot) {
      final jobId = await ref.read(jobRepositoryProvider).save(draft);
      await ref.read(intakeServiceProvider).markImported(candidate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.jobBooked),
          action: SnackBarAction(
            label: strings.edit,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => JobDetailScreen(jobId: jobId),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotParse)),
      );
    }

    final jobId = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => JobEditorScreen(initialDraft: draft, parsed: parsed),
      ),
    );
    if (jobId == null) return;

    await ref.read(intakeServiceProvider).markImported(candidate);
  }

  void _newJob() {
    final hours = ref.read(workingHoursProvider);
    final slot = ref.read(slotMinutesProvider);
    final dropOff = AppointmentDraft(
      at: snapIntoWorkingHours(shopNow(), hours, slotMinutes: slot),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobEditorScreen(
          initialDraft: JobDraft(dropOff: dropOff),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: Column(
        children: [
          if (_banner != null)
            _ImportBanner(
              candidate: _banner!,
              strings: strings,
              onImport: () => _handleCandidate(_banner!),
              onDismiss: () {
                ref.read(intakeServiceProvider).dismiss(_banner!);
                setState(() => _banner = null);
              },
            ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                TodayScreen(
                  onPasteAppointment: _pasteAppointment,
                  onNewJob: _newJob,
                ),
                const CalendarScreen(),
                const CustomersScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: strings.tabAppointments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: strings.tabCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: strings.tabCustomers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: strings.tabSettings,
          ),
        ],
      ),
    );
  }
}

class _ImportBanner extends StatelessWidget {
  const _ImportBanner({
    required this.candidate,
    required this.strings,
    required this.onImport,
    required this.onDismiss,
  });

  final IntakeCandidate candidate;
  final AppStrings strings;
  final VoidCallback onImport;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.content_paste_search,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.importDetectedTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: onImport,
              child: Text(strings.importAction),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              tooltip: strings.dismiss,
            ),
          ],
        ),
      ),
    );
  }
}
