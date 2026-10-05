import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../services/studio_content.dart';
import '../widgets/record_editor.dart';
import '../widgets/studio_widgets.dart';

class SettingsPage extends StatefulWidget {
  final StudioContent content;
  final bool metadata;
  const SettingsPage({super.key, required this.content, this.metadata = false});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool exporting = false;
  Future<void> export() async {
    setState(() => exporting = true);
    try {
      final content = await FirestoreService.exportPublishedContent();
      downloadFile(
        'data:application/json;base64,${base64Encode(utf8.encode(const JsonEncoder.withIndent('  ').convert(content)))}',
        'portfolio-content.json',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content export failed. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  void edit([String? group]) => Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => RecordEditor(
        profile: true,
        id: 'main',
        initial: widget.content.profile,
        initialGroup: group,
        profileIndicators: widget.content.published('stats'),
        schema: ContentSchema(
          'profile',
          widget.metadata ? 'Search & sharing' : 'Profile',
          widget.metadata ? 'metadata' : 'profile',
          'name',
          widget.metadata
              ? 'Keep search and sharing details consistent with your public portfolio.'
              : 'These fields drive your public introduction, contact section, and CV. Keep every claim factual and concise.',
          widget.metadata ? metadataFields : profileFields,
        ),
      ),
    ),
  );

  void testCv() {
    var url = widget.content.text('cvUrl');
    if (FirestoreService.useFirebase &&
        !FirestoreService.useEmulators &&
        url.startsWith('/')) {
      url = Uri.parse(widget.content.text('siteUrl')).resolve(url).toString();
    }
    downloadFile(url, 'Ahmed-Emara-CV.pdf');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.content,
    builder: (context, _) {
      final c = widget.content;
      if (c.error != null) {
        return StateMessage(
          title: 'Could not load your profile',
          message: c.error!,
          action: OutlinedButton(
            onPressed: c.reload,
            child: const Text('Try again'),
          ),
        );
      }
      if (c.loading) return const Center(child: CircularProgressIndicator());
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudioPageHeader(
              eyebrow: widget.metadata
                  ? 'Publishing / Search & sharing'
                  : '01 / Your public presence',
              title: widget.metadata ? 'Search & sharing' : 'Profile & contact',
              description: widget.metadata
                  ? 'Set the details recruiters see in search results and shared links.'
                  : 'The introduction, availability, and contact details behind your portfolio.',
              action: FilledButton.icon(
                onPressed: edit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(widget.metadata ? 'Edit metadata' : 'Edit profile'),
              ),
            ),
            const SizedBox(height: 32),
            if (widget.metadata) metadata(c) else profile(c),
            const SizedBox(height: 28),
            if (!widget.metadata) ...[
              const StudioSectionTitle(
                title: 'Section introductions',
                description:
                    'Headings and concise copy for selected work, experience, packages, and capabilities.',
              ),
              const SizedBox(height: 18),
              StudioPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final section in [
                      ('Selected work', 'projectsTitle', 'projectsDescription'),
                      (
                        'Experience',
                        'experienceTitle',
                        'experienceDescription',
                      ),
                      (
                        'Flutter packages',
                        'packagesTitle',
                        'packagesDescription',
                      ),
                      ('Capabilities', 'skillsTitle', 'skillsDescription'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Eyebrow(section.$1, color: Design.muted),
                            const SizedBox(height: 8),
                            Text(
                              c.text(section.$2),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(c.text(section.$3), style: Design.captionType),
                          ],
                        ),
                      ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => edit('Section introductions'),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit section copy'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );

  Widget profile(StudioContent c) => LayoutBuilder(
    builder: (context, constraints) {
      final intro = StudioPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow('Introduction preview', color: Design.muted),
            const SizedBox(height: 28),
            StudioProfilePreview(
              profile: c.profile,
              indicators: c.published('stats'),
              compact: constraints.maxWidth < 900,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => showStudioProfilePreview(
                    context,
                    c.profile,
                    indicators: c.published('stats'),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Preview introduction'),
                ),
                TextButton.icon(
                  onPressed: () => edit('Introduction'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit hero copy'),
                ),
              ],
            ),
          ],
        ),
      );
      final details = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudioPanel(
            color: Design.ink,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Contact', color: Design.tint),
                const SizedBox(height: 20),
                Text(
                  c.text('contactTitle'),
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Design.paper,
                  ),
                ),
                const SizedBox(height: 18),
                SelectableText(
                  c.text('contactEmail'),
                  style: const TextStyle(color: Design.paper, fontSize: 13),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  c.text('contactPhone'),
                  style: const TextStyle(color: Design.paper, fontSize: 13),
                ),
                const SizedBox(height: 18),
                Text(
                  c.profile['contactFormEnabled'] == true
                      ? 'Contact form enabled · Messages arrive in your private inbox.'
                      : 'Visitors can contact you by email.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.7,
                    color: Design.tint,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => edit('CV & contact'),
                  style: TextButton.styleFrom(foregroundColor: Design.paper),
                  child: const Text('Edit contact details'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StudioPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: Design.accent,
                  size: 26,
                ),
                const SizedBox(height: 16),
                Text(
                  c.text('cvLabel').isEmpty
                      ? 'Curriculum vitae'
                      : c.text('cvLabel'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  c.text('cvUrl').isEmpty
                      ? 'Add a PDF to enable Download CV on your portfolio.'
                      : 'This file powers the Download CV action on your portfolio.',
                  style: Design.captionType,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: c.text('cvUrl').isEmpty ? null : testCv,
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text('Test CV download'),
                    ),
                    TextButton(
                      onPressed: () => edit('CV & contact'),
                      child: const Text('Manage CV'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
      if (constraints.maxWidth < 900) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [intro, const SizedBox(height: 24), details],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: intro),
          const SizedBox(width: 28),
          Expanded(flex: 2, child: details),
        ],
      );
    },
  );

  Widget metadata(StudioContent c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final preview = StudioPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Eyebrow('Sharing preview', color: Design.muted),
                const SizedBox(height: 22),
                StudioSocialPreview(profile: c.profile),
                const SizedBox(height: 18),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => showStudioProfilePreview(
                      context,
                      c.profile,
                      metadata: true,
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Preview sharing'),
                  ),
                ),
              ],
            ),
          );
          final publishing = StudioPanel(
            color: Design.tint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.travel_explore,
                  color: Design.accent,
                  size: 28,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Publish a complete snapshot.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Content edits update the live portfolio. Search and social-sharing previews need a new site build after changes. Export your current published content for that build.',
                  style: Design.captionType,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: exporting ? null : export,
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: Text(
                    exporting
                        ? 'Preparing export…'
                        : 'Export published content',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Drafts and private messages are excluded from this export.',
                  style: Design.captionType,
                ),
              ],
            ),
          );
          if (constraints.maxWidth < 820) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [preview, const SizedBox(height: 24), publishing],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: preview),
              const SizedBox(width: 28),
              Expanded(flex: 2, child: publishing),
            ],
          );
        },
      ),
    ],
  );
}
