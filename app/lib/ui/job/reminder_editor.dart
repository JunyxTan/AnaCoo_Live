import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/reminder_rule.dart';
import '../../providers/providers.dart';

/// Per-appointment reminder override.
///
/// Null rules mean "follow the Settings defaults", which is what almost every
/// appointment wants; the override exists for the occasional job that needs a
/// longer runway.
class ReminderSummary extends ConsumerWidget {
  const ReminderSummary({
    super.key,
    required this.rules,
    required this.onChanged,
  });

  final List<ReminderRule>? rules;
  final ValueChanged<List<ReminderRule>?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final defaults = ref.watch(defaultReminderRulesProvider);
    final effective = rules ?? defaults;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                effective.isEmpty
                    ? strings.none
                    : effective
                        .map((r) => describeRule(r, ref.watch(languageCodeProvider)))
                        .join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () => _edit(context, ref, effective),
              child: Text(strings.edit),
            ),
          ],
        ),
        if (rules != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onChanged(null),
              child: Text(strings.useDefaultReminders),
            ),
          ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    List<ReminderRule> current,
  ) async {
    final next = await showModalBottomSheet<List<ReminderRule>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReminderRuleSheet(initial: current),
    );
    if (next != null) onChanged(next);
  }
}

/// Human-readable description of a rule, in the UI language.
String describeRule(ReminderRule rule, String languageCode) {
  final formats = Formats(languageCode);
  String pick(String en, String zh, String ms) => switch (languageCode) {
        'zh' => zh,
        'ms' => ms,
        _ => en,
      };

  return switch (rule) {
    RelativeReminder(:final before) => () {
        if (before.inMinutes % 1440 == 0 && before.inMinutes != 0) {
          final d = before.inDays;
          return pick(
            '$d ${d == 1 ? 'day' : 'days'} before',
            '提前 $d 天',
            '$d hari sebelum',
          );
        }
        if (before.inMinutes % 60 == 0) {
          final h = before.inHours;
          return pick(
            '$h ${h == 1 ? 'hour' : 'hours'} before',
            '提前 $h 小时',
            '$h jam sebelum',
          );
        }
        return pick(
          '${before.inMinutes} min before',
          '提前 ${before.inMinutes} 分钟',
          '${before.inMinutes} min sebelum',
        );
      }(),
    DaysBeforeAtReminder(:final days, :final hour, :final minute) => () {
        final clock = formats.minutesAsClock(hour * 60 + minute);
        if (days == 0) return pick('Same day at $clock', '当天 $clock', 'Hari sama jam $clock');
        if (days == 1) {
          return pick('Day before at $clock', '前一天 $clock', 'Sehari sebelum jam $clock');
        }
        return pick(
          '$days days before at $clock',
          '提前 $days 天 $clock',
          '$days hari sebelum jam $clock',
        );
      }(),
  };
}

/// Editor for a list of reminder rules, used both per-appointment and for the
/// global defaults in Settings.
class ReminderRuleSheet extends ConsumerStatefulWidget {
  const ReminderRuleSheet({super.key, required this.initial});

  final List<ReminderRule> initial;

  @override
  ConsumerState<ReminderRuleSheet> createState() => _ReminderRuleSheetState();
}

class _ReminderRuleSheetState extends ConsumerState<ReminderRuleSheet> {
  late List<ReminderRule> _rules;

  static const List<ReminderRule> _presets = [
    RelativeReminder(Duration(minutes: 30)),
    RelativeReminder(Duration(hours: 1)),
    RelativeReminder(Duration(hours: 2)),
    RelativeReminder(Duration(hours: 3)),
    DaysBeforeAtReminder(days: 1, hour: 21, minute: 0),
    DaysBeforeAtReminder(days: 1, hour: 9, minute: 0),
    DaysBeforeAtReminder(days: 2, hour: 21, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _rules = List.of(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.reminders, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in _presets)
                  FilterChip(
                    label: Text(describeRule(preset, language)),
                    selected: _rules.contains(preset),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _rules.add(preset);
                      } else {
                        _rules.remove(preset);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(strings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final sorted = List.of(_rules);
                      Navigator.of(context).pop(sorted);
                    },
                    child: Text(strings.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
