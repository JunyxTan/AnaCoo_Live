import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/extensions.dart';
import '../../data/job_repository.dart';
import '../../domain/scheduling.dart';
import '../../domain/service_labels.dart';
import '../../domain/shop_time.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import '../job/job_detail_screen.dart';
import '../job/job_editor_screen.dart';
import '../widgets/common.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// Whether the list is showing the archive rather than the directory.
  bool _showArchived = false;

  /// Rows to leave out of the list until the write comes back through the
  /// stream. A swiped-away [Dismissible] that is still in the tree on the next
  /// build is an error, and waiting for the round trip would be one build too
  /// late.
  final _swiped = <int>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final source = _showArchived
        ? ref.watch(archivedCustomersProvider(_query))
        : ref.watch(customersProvider(_query));
    final all = source.value ?? const <Customer>[];
    final counts = ref.watch(customerJobCountsProvider).value ?? const <int, int>{};

    // Anything the stream has caught up on can stop being held back.
    _swiped.removeWhere((id) => !all.any((customer) => customer.id == id));
    final customers = all.where((c) => !_swiped.contains(c.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_showArchived ? strings.archived : strings.tabCustomers),
        actions: [
          IconButton(
            tooltip: _showArchived ? strings.tabCustomers : strings.archived,
            isSelected: _showArchived,
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            onPressed: () => setState(() {
              _showArchived = !_showArchived;
              // The held-back rows belong to the list being left behind.
              _swiped.clear();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: strings.searchCustomers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: customers.isEmpty
                ? EmptyState(
                    message: _showArchived
                        ? strings.noArchivedCustomers
                        : strings.noCustomers,
                    icon: _showArchived
                        ? Icons.inventory_2_outlined
                        : Icons.people_outline,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return _CustomerRow(
                        customer: customer,
                        jobCount: counts[customer.id] ?? 0,
                        strings: strings,
                        isArchived: _showArchived,
                        onSwipe: () => _setArchived(customer, !_showArchived),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Archives a swiped customer, or puts a swiped archived one back.
  ///
  /// Archiving offers Undo, because the swipe is easy to make by accident and
  /// the name is out of the directory the moment it lands. Restoring needs no
  /// undo — swiping the row again is the way back.
  Future<void> _setArchived(Customer customer, bool archived) async {
    final strings = ref.read(appStringsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);

    setState(() => _swiped.add(customer.id));
    await db.setCustomerArchived(customer.id, archived);
    if (!archived) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text('${customer.name} · ${strings.archived}'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: strings.undo,
          onPressed: () {
            // Undoes the holding back as well as the write, in case the stream
            // has not caught up with the swipe yet.
            if (mounted) setState(() => _swiped.remove(customer.id));
            unawaited(db.setCustomerArchived(customer.id, false));
          },
        ),
      ),
    );
  }
}

/// One name in the directory, swipe-left to archive.
///
/// The gesture only goes one way: end-to-start is a deliberate pull against the
/// reading direction, where start-to-end would fire on a stray drag while
/// scrolling.
class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.customer,
    required this.jobCount,
    required this.strings,
    required this.isArchived,
    required this.onSwipe,
  });

  final Customer customer;
  final int jobCount;
  final AppStrings strings;
  final bool isArchived;
  final VoidCallback onSwipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(customer.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onSwipe(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              size: 20,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              isArchived ? strings.restore : strings.archive,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: theme.colorScheme.surface,
        leading: CircleAvatar(
          child: Text(
            customer.name.isEmpty
                ? '?'
                : customer.name.characters.first.toUpperCase(),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                customer.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (jobCount > 1) ...[
              const SizedBox(width: 8),
              Chip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                label: Text(
                  strings.repeatCustomer,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          [
            if (customer.phone != null) customer.phone!,
            strings.jobCount(jobCount),
          ].join(' · '),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CustomerDetailScreen(customer: customer),
          ),
        ),
      ),
    );
  }
}

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final jobs = ref.watch(customerJobsProvider(customer.id)).value ?? const <JobBundle>[];

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (customer.phone != null)
            DetailRow(label: strings.phone, value: customer.phone!),
          if (customer.whatsappNumber != null)
            DetailRow(
              label: strings.whatsappNumber,
              value: customer.whatsappNumber!,
            ),
          DetailRow(label: strings.jobCount(jobs.length), value: ''),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _newJob(context, ref),
            icon: const Icon(Icons.add),
            label: Text(strings.newJobForCustomer),
          ),
          SectionHeader(
            strings.jobDetail,
            count: jobs.length,
            icon: Icons.work_outline,
          ),
          for (final bundle in jobs)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                serviceLabel(
                  bundle.job.service,
                  language,
                  freeText: bundle.job.serviceFreeText,
                ),
              ),
              subtitle: Text(
                [
                  jobStatusLabel(bundle.job.status, language),
                  if (bundle.dropOff != null)
                    formats.dayMonth(bundle.dropOff!.at),
                ].join(' · '),
              ),
              trailing: bundle.job.isRush ? const RushBadge() : null,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => JobDetailScreen(jobId: bundle.job.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _newJob(BuildContext context, WidgetRef ref) {
    final hours = ref.read(workingHoursProvider);
    final slot = ref.read(slotMinutesProvider);
    final dropOff = AppointmentDraft(
      at: snapIntoWorkingHours(shopNow(), hours, slotMinutes: slot),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobEditorScreen(
          initialDraft: JobDraft(
            customerId: customer.id,
            customerName: customer.name,
            phone: customer.phone,
            whatsappNumber: customer.whatsappNumber,
            dropOff: dropOff,
          ),
        ),
      ),
    );
  }
}
