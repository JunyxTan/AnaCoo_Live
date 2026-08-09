import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/message_templates.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';

/// One editable set of WhatsApp reply templates per language.
class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  late String _language;

  @override
  void initState() {
    super.initState();
    _language = 'en';
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final templates = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.messageTemplates)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('EN')),
              ButtonSegment(value: 'zh', label: Text('中文')),
              ButtonSegment(value: 'ms', label: Text('BM')),
            ],
            selected: {_language},
            onSelectionChanged: (value) =>
                setState(() => _language = value.first),
          ),
          const SizedBox(height: 8),
          Text(
            '${strings.placeholders}: ${templatePlaceholders.join('  ')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          for (final kind in TemplateKind.values) ...[
            SectionHeader(
              switch (kind) {
                TemplateKind.confirm => strings.whatsappConfirm,
                TemplateKind.ready => strings.whatsappReady,
                TemplateKind.reschedule => strings.whatsappReschedule,
              },
              icon: switch (kind) {
                TemplateKind.confirm => Icons.check_circle_outline,
                TemplateKind.ready => Icons.inventory_2_outlined,
                TemplateKind.reschedule => Icons.event_repeat_outlined,
              },
              trailing: IconButton(
                tooltip: strings.resetToDefault,
                onPressed: () => _write(
                  templates.resetToDefault(kind, _language),
                ),
                icon: const Icon(Icons.restart_alt, size: 18),
              ),
            ),
            _TemplateField(
              // Rebuild the field when the language tab changes.
              key: ValueKey('$kind-$_language'),
              initial: templates.bodyFor(kind, _language),
              onSaved: (body) =>
                  _write(templates.withBody(kind, _language, body)),
            ),
          ],
        ],
      ),
    );
  }

  void _write(MessageTemplates next) {
    ref.read(databaseProvider).saveSettings(
          AppSettingsCompanion(templates: Value(next.encode())),
        );
  }
}

class _TemplateField extends StatefulWidget {
  const _TemplateField({
    super.key,
    required this.initial,
    required this.onSaved,
  });

  final String initial;
  final ValueChanged<String> onSaved;

  @override
  State<_TemplateField> createState() => _TemplateFieldState();
}

class _TemplateFieldState extends State<_TemplateField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void didUpdateWidget(covariant _TemplateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial &&
        _controller.text == oldWidget.initial) {
      _controller.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        minLines: 4,
        maxLines: 12,
        onChanged: widget.onSaved,
      );
}
