import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/enums.dart';
import '../../data/extensions.dart';
import '../../data/job_repository.dart';
import '../../domain/scheduling.dart';
import '../../domain/shop_time.dart';
import '../../providers/providers.dart';
import '../job/job_detail_screen.dart';
import '../job/job_editor_screen.dart';
import '../widgets/common.dart';

/// Month grid with density dots over a day agenda. Tapping an empty day starts
/// a new job pre-dated to it.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late tz.TZDateTime _visibleMonth;
  late tz.TZDateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = shopNow();
    _visibleMonth = shopDateTime(now.year, now.month, 1);
    _selectedDay = startOfDay(now);
  }

  String get _monthKey =>
      '${_visibleMonth.year}-${_visibleMonth.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final monthEntries =
        ref.watch(monthAppointmentsProvider(_monthKey)).value ?? const [];
    final dayEntries =
        ref.watch(dayAppointmentsProvider(dayKey(_selectedDay))).value ?? const [];
    final blocked = ref.watch(blockedDayKeysProvider);
    final hours = ref.watch(workingHoursProvider);

    final countsByDay = <String, ({int dropOffs, int collections})>{};
    for (final entry in monthEntries) {
      final key = dayKey(entry.at);
      final current = countsByDay[key] ?? (dropOffs: 0, collections: 0);
      countsByDay[key] = entry.appointment.type == AppointmentType.dropOff
          ? (dropOffs: current.dropOffs + 1, collections: current.collections)
          : (dropOffs: current.dropOffs, collections: current.collections + 1);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tabCalendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: strings.today,
            onPressed: () => setState(() {
              final now = shopNow();
              _visibleMonth = shopDateTime(now.year, now.month, 1);
              _selectedDay = startOfDay(now);
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          _MonthHeader(
            month: _visibleMonth,
            label: formats.monthYear(_visibleMonth),
            onPrevious: () => setState(
              () => _visibleMonth = shopDateTime(
                _visibleMonth.year,
                _visibleMonth.month - 1,
                1,
              ),
            ),
            onNext: () => setState(
              () => _visibleMonth = shopDateTime(
                _visibleMonth.year,
                _visibleMonth.month + 1,
                1,
              ),
            ),
          ),
          _MonthGrid(
            month: _visibleMonth,
            selected: _selectedDay,
            counts: countsByDay,
            blockedDays: blocked,
            closedWeekdays: {
              for (var d = 1; d <= 7; d++)
                if (!hours.isOpenOn(d)) d,
            },
            formats: formats,
            onSelect: (day) => setState(() => _selectedDay = day),
          ),
          const Divider(height: 24),
          Expanded(
            child: _DayAgenda(
              day: _selectedDay,
              entries: dayEntries,
              blocked: blocked.contains(dayKey(_selectedDay)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newJobOnSelectedDay,
        icon: const Icon(Icons.add),
        label: Text(strings.newJob),
      ),
    );
  }

  void _newJobOnSelectedDay() {
    final hours = ref.read(workingHoursProvider);
    final slot = ref.read(slotMinutesProvider);
    final now = shopNow();
    // Keep the time of day sensible: today keeps "now", other days open at the
    // first slot the shop is actually open for.
    final seed = isSameDay(_selectedDay, now)
        ? now
        : _selectedDay.add(const Duration(hours: 12));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobEditorScreen(
          initialDraft: JobDraft(
            dropOff: AppointmentDraft(
              at: snapIntoWorkingHours(seed, hours, slotMinutes: slot),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final tz.TZDateTime month;
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
            ),
          ],
        ),
      );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.counts,
    required this.blockedDays,
    required this.closedWeekdays,
    required this.formats,
    required this.onSelect,
  });

  final tz.TZDateTime month;
  final tz.TZDateTime selected;
  final Map<String, ({int dropOffs, int collections})> counts;
  final Set<String> blockedDays;
  final Set<int> closedWeekdays;
  final Formats formats;
  final ValueChanged<tz.TZDateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstWeekday = month.weekday; // 1 = Monday
    final daysInMonth =
        shopDateTime(month.year, month.month + 1, 1).subtract(const Duration(days: 1)).day;
    final leading = firstWeekday - 1;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();
    final today = startOfDay(shopNow());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              for (var weekday = 1; weekday <= 7; weekday++)
                Expanded(
                  child: Center(
                    child: Text(
                      formats.weekdayNarrow(weekday),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < rows; row++)
            Row(
              children: [
                for (var column = 0; column < 7; column++)
                  Expanded(
                    child: _buildCell(
                      context,
                      row * 7 + column - leading + 1,
                      daysInMonth,
                      today,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    int dayOfMonth,
    int daysInMonth,
    tz.TZDateTime today,
  ) {
    if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
      return const SizedBox(height: 46);
    }
    final theme = Theme.of(context);
    final day = shopDateTime(month.year, month.month, dayOfMonth);
    final key = dayKey(day);
    final count = counts[key];
    final isSelected = isSameDay(day, selected);
    final isToday = isSameDay(day, today);
    final isBlocked = blockedDays.contains(key);
    final isClosed = closedWeekdays.contains(day.weekday);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onSelect(day),
      child: Container(
        height: 46,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : (isBlocked || isClosed)
                  ? theme.colorScheme.surfaceContainerHighest
                  : null,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayOfMonth',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: (isBlocked || isClosed)
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
                decoration: isBlocked ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 5,
              child: count == null
                  ? null
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < count.dropOffs.clamp(0, 3); i++)
                          _Dot(color: theme.colorScheme.secondary),
                        for (var i = 0; i < count.collections.clamp(0, 3); i++)
                          _Dot(color: theme.colorScheme.primary),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _DayAgenda extends ConsumerWidget {
  const _DayAgenda({
    required this.day,
    required this.entries,
    required this.blocked,
  });

  final tz.TZDateTime day;
  final List<AppointmentEntry> entries;
  final bool blocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                formats.fullDate(day),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _toggleBlock(context, ref),
              icon: Icon(
                blocked ? Icons.event_available_outlined : Icons.event_busy_outlined,
                size: 18,
              ),
              label: Text(blocked ? strings.unblockDay : strings.blockDay),
            ),
          ],
        ),
        if (entries.isEmpty)
          EmptyState(
            message: strings.noAppointmentsThisDay,
            icon: Icons.event_note_outlined,
          ),
        for (final entry in entries)
          AppointmentTile(
            entry: entry,
            languageCode: language,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => JobDetailScreen(jobId: entry.job.id),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _toggleBlock(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final strings = ref.read(appStringsProvider);
    final key = dayKey(day);
    if (blocked) {
      await db.unblockDay(key);
      return;
    }
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.blockDay),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: strings.blockReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(strings.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    await db.blockDay(key, reason.isEmpty ? null : reason);
  }
}
