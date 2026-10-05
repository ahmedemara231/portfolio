import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ProjectReferencePicker extends StatefulWidget {
  final TextEditingController controller;
  const ProjectReferencePicker({super.key, required this.controller});
  @override
  State<ProjectReferencePicker> createState() => _ProjectReferencePickerState();
}

class _ProjectReferencePickerState extends State<ProjectReferencePicker> {
  late final projects = FirestoreService.collectionStreamWithIds('projects');
  Set<String> get selected => widget.controller.text
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();
  void toggle(String id, bool include) {
    final ids = selected;
    include ? ids.add(id) : ids.remove(id);
    widget.controller.text = ids.join('\n');
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Related projects',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      const Text(
        'Choose work that demonstrates this capability. Draft relationships become visible after their project is published.',
        style: Design.captionType,
      ),
      const SizedBox(height: 14),
      StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
        stream: projects,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Text(
              'Project references could not be loaded. Existing selections will be kept.',
              style: TextStyle(color: Design.error),
            );
          }
          if (!snap.hasData) return const LinearProgressIndicator();
          final entries = snap.data!;
          final missing = selected.difference(
            entries.map((e) => e.key).toSet(),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (entries.isEmpty)
                const Text(
                  'Add project pages to connect them to this capability.',
                  style: Design.captionType,
                ),
              for (final entry in entries)
                CheckboxListTile(
                  key: ValueKey(entry.key),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    '${entry.value['title'] ?? 'Untitled'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${entry.value['category'] ?? ''}${FirestoreService.isPublished(entry.value) ? '' : ' · Private draft'}',
                    style: Design.captionType,
                  ),
                  value: selected.contains(entry.key),
                  onChanged: (value) => toggle(entry.key, value == true),
                ),
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Unavailable project references are preserved until you remove them.',
                  style: Design.captionType,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final id in missing)
                      InputChip(
                        label: Text(id),
                        onDeleted: () => toggle(id, false),
                        deleteButtonTooltipMessage:
                            'Remove unavailable reference $id',
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    ],
  );
}
