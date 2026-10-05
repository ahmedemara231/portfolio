import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../services/studio_content.dart';
import '../widgets/record_editor.dart';
import '../widgets/studio_widgets.dart';

class OverviewPage extends StatefulWidget {
  final StudioContent content;
  final ValueChanged<int>? onNavigate;
  final ValueChanged<String>? onProjectFilter;
  const OverviewPage({
    super.key,
    required this.content,
    this.onNavigate,
    this.onProjectFilter,
  });
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late final activity = FirestoreService.recentActivityStream(limit: 6);
  late final unread = FirestoreService.unreadMessagesCountStream();

  void addProject() => Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const RecordEditor(schema: projectSchema),
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.content,
    builder: (context, _) {
      final content = widget.content;
      if (content.error != null) {
        return StateMessage(
          title: 'Content unavailable',
          message: content.error!,
          action: OutlinedButton(
            onPressed: content.reload,
            child: const Text('Try again'),
          ),
        );
      }
      if (content.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudioPageHeader(
              eyebrow: 'Your portfolio, thoughtfully maintained',
              title: 'Welcome to your studio.',
              description:
                  'Keep your story clear, your strongest work in view, and every public detail up to date.',
              action: FilledButton.icon(
                onPressed: addProject,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add project'),
              ),
            ),
            const SizedBox(height: 28),
            const Divider(),
            inventory(content),
            const Divider(),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, c) {
                final work = featuredWork(content);
                final profile = introduction(content);
                if (c.maxWidth < 920) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [work, const SizedBox(height: 28), profile],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: work),
                    const SizedBox(width: 28),
                    Expanded(flex: 2, child: profile),
                  ],
                );
              },
            ),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, c) {
                final sections = sectionLinks(content);
                final changes = recentChanges();
                if (c.maxWidth < 820) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [sections, const SizedBox(height: 32), changes],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: sections),
                    const SizedBox(width: 32),
                    Expanded(child: changes),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            StreamBuilder<int>(
              stream: unread,
              builder: (context, snap) => StudioPanel(
                color: Design.tint,
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      color: Design.accent,
                    ),
                    Text(
                      snap.hasData
                          ? '${snap.data} unread ${snap.data == 1 ? 'message' : 'messages'}'
                          : 'Your private inbox',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton.icon(
                      onPressed: () => widget.onNavigate?.call(11),
                      icon: const Icon(Icons.north_east, size: 16),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Review inbox'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );

  Widget inventory(StudioContent content) {
    final projects = content.projects;
    final counts = [
      ('Project pages', projects.length, 'All'),
      (
        'Published',
        projects.where((p) => p.status == 'published').length,
        'Published',
      ),
      (
        'Drafts',
        projects.where((p) => p.status != 'published').length,
        'Draft',
      ),
      ('Home page projects', content.featured.length, 'Featured'),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 760 ? 4 : 2;
        return Wrap(
          spacing: 16,
          runSpacing: 4,
          children: counts
              .map(
                (item) => SizedBox(
                  width: (c.maxWidth - 16 * (columns - 1)) / columns,
                  child: MotionSurface(
                    onTap: () => item.$3 == 'Featured'
                        ? widget.onNavigate?.call(2)
                        : widget.onProjectFilter?.call(item.$3),
                    color: Design.paper,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.$2}',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(item.$1, style: Design.captionType),
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
  }

  Widget featuredWork(StudioContent content) {
    final projects = content.featured;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioSectionTitle(
          title: 'The home page lineup',
          description:
              'The same published projects and order visitors see in selected work.',
          action: TextButton.icon(
            onPressed: () => widget.onNavigate?.call(2),
            icon: const Icon(Icons.tune, size: 16),
            label: const Text('Curate lineup'),
          ),
        ),
        const SizedBox(height: 20),
        if (projects.isEmpty)
          StateMessage(
            title: 'Choose work to lead with.',
            message:
                'Feature published projects to build the selected-work section.',
            action: OutlinedButton(
              onPressed: () => widget.onNavigate?.call(2),
              child: const Text('Choose projects'),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              final columns = c.maxWidth >= 450 ? 2 : 1;
              return Wrap(
                spacing: 18,
                runSpacing: 22,
                children: [
                  for (var i = 0; i < projects.length; i++)
                    SizedBox(
                      width: (c.maxWidth - 18 * (columns - 1)) / columns,
                      child: MotionSurface(
                        color: Design.paper,
                        borderRadius: BorderRadius.circular(Design.radius),
                        onTap: () =>
                            showStudioProjectPreview(context, projects[i]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProjectMedia(project: projects[i]),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${i + 1}'.padLeft(2, '0'),
                                  style: Design.captionType.copyWith(
                                    color: Design.accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    projects[i].title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.north_east,
                                  size: 16,
                                  color: Design.accent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              projects[i].category,
                              style: Design.captionType,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget introduction(StudioContent content) => StudioPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Your public introduction', color: Design.muted),
        const SizedBox(height: 24),
        StudioProfilePreview(
          profile: content.profile,
          indicators: content.published('stats'),
          compact: true,
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => widget.onNavigate?.call(7),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit introduction'),
        ),
      ],
    ),
  );

  Widget sectionLinks(StudioContent content) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StudioSectionTitle(
        title: 'Portfolio sections',
        description:
            'Maintain the experience and capabilities behind your work.',
      ),
      const SizedBox(height: 18),
      for (final section in [
        ('Experience', 'experiences', 3),
        ('Flutter packages', 'packages', 4),
        ('Capabilities', 'technical_skills', 5),
        ('Education', 'education', 6),
      ]) ...[
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            section.$1,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${content.published(section.$2).length} published entries',
            style: Design.captionType,
          ),
          trailing: const Icon(
            Icons.arrow_forward,
            color: Design.accent,
            size: 18,
          ),
          onTap: () => widget.onNavigate?.call(section.$3),
        ),
      ],
      const Divider(),
    ],
  );

  Widget recentChanges() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StudioSectionTitle(
        title: 'Recent changes',
        description: 'A record of saved content updates.',
      ),
      const SizedBox(height: 18),
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: activity,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Text(
              'Activity could not be loaded.',
              style: TextStyle(color: Design.muted),
            );
          }
          final entries = snap.data ?? [];
          if (entries.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Saved content changes will appear here.',
                style: TextStyle(color: Design.muted),
              ),
            );
          }
          return Column(
            children: entries
                .map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Design.accent,
                      size: 20,
                    ),
                    title: Text(
                      '${entry['target']} ${entry['action']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${entry['entity'] ?? ''}${activityDate(entry['createdAt'])}',
                      style: Design.captionType,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    ],
  );

  String activityDate(dynamic value) {
    final date = value is Timestamp
        ? value.toDate()
        : DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return ' · ${date.day} ${months[date.month - 1]}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
