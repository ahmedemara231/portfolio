import 'package:core/core.dart';
import 'package:flutter/material.dart';

class OverviewPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const OverviewPage({super.key, this.onNavigate});
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late final projects = FirestoreService.collectionStreamWithIds('projects');
  late final activity = FirestoreService.recentActivityStream(limit: 8);
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Your portfolio, thoughtfully maintained'),
        const SizedBox(height: 12),
        const Text(
          'Welcome to your studio.',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.3,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'A clear picture of your content, and a short path to keeping it current.',
          style: TextStyle(color: Design.muted, height: 1.7),
        ),
        const SizedBox(height: 36),
        StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
          stream: projects,
          builder: (context, snap) {
            if (snap.hasError) {
              return const StateMessage(
                title: 'Content unavailable',
                message: 'Check your connection and administrator access.',
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snap.data!;
            final counts = [
              ('Projects', list.length, 1),
              (
                'Published',
                list.where((e) => FirestoreService.isPublished(e.value)).length,
                1,
              ),
              (
                'Drafts',
                list
                    .where((e) => !FirestoreService.isPublished(e.value))
                    .length,
                1,
              ),
              (
                'Featured',
                list.where((e) => e.value['featured'] == true).length,
                2,
              ),
            ];
            return LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 900
                    ? 4
                    : c.maxWidth >= 300
                    ? 2
                    : 1;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: counts
                      .map(
                        (e) => SizedBox(
                          width: (c.maxWidth - 16 * (cols - 1)) / cols,
                          child: MotionSurface(
                            color: Design.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: const BorderSide(color: Design.line),
                            onTap: widget.onNavigate == null
                                ? null
                                : () => widget.onNavigate!(e.$3),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.$1,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Design.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    '${e.$2}',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            );
          },
        ),
        const SizedBox(height: 40),
        const Text(
          'Make it current.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 20),
        for (final item in [
          (
            Icons.folder_outlined,
            'Refine a case study',
            'Add screenshots, contribution details, or store links.',
            1,
          ),
          (
            Icons.star_outline,
            'Choose your strongest work',
            'Manage featured selection and its display order.',
            2,
          ),
          (
            Icons.person_outline,
            'Update your introduction',
            'Keep your availability, contact details, and CV up to date.',
            7,
          ),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Design.line),
              ),
              tileColor: Design.surface,
              leading: Icon(item.$1, color: Design.accent),
              title: Text(
                item.$2,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                item.$3,
                style: const TextStyle(
                  color: Design.muted,
                  fontSize: 12,
                  height: 1.8,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward, size: 18),
              onTap: () => widget.onNavigate?.call(item.$4),
            ),
          ),
        const SizedBox(height: 32),
        const Text(
          'Recent changes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: activity,
          builder: (context, snap) {
            if (snap.hasError) {
              return const Text(
                'Activity could not be loaded.',
                style: TextStyle(color: Design.muted),
              );
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return const Text(
                'Saved content changes will appear here.',
                style: TextStyle(color: Design.muted),
              );
            }
            return Column(
              children: list
                  .map(
                    (a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: Design.accent,
                        size: 20,
                      ),
                      title: Text(
                        '${a['target']} ${a['action']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        (a['entity'] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Design.muted,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    ),
  );
}
