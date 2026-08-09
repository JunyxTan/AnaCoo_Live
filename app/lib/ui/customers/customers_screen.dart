import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../data/extensions.dart';
import '../../data/job_repository.dart';
import '../../domain/scheduling.dart';
import '../../domain/service_labels.dart';
import '../../domain/shop_time.dart';
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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final customers = ref.watch(customersProvider(_query)).value ?? const <Customer>[];
    final counts = ref.watch(customerJobCountsProvider).value ?? const <int, int>{};

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabCustomers)),
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
                    message: strings.noCustomers,
                    icon: Icons.people_outline,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final jobCount = counts[customer.id] ?? 0;
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      );
                    },
                  ),
          ),
        ],
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
    final turnaround = ref.read(turnaroundDaysProvider);
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
            collection: AppointmentDraft(
              at: suggestCollection(
                dropOff.at,
                hours,
                turnaroundDays: turnaround,
                slotMinutes: slot,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
