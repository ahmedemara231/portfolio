import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project_model.dart';
import 'design_system.dart';
import 'project_media.dart';

class ProjectDetail extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onBack;
  final bool preview;
  const ProjectDetail({
    super.key,
    required this.project,
    this.onBack,
    this.preview = false,
  });
  @override
  Widget build(BuildContext context) {
    final p = project;
    return SelectionArea(
      child: SingleChildScrollView(
        child: ContentWidth(
          vertical: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (onBack != null)
                    TextButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('All projects'),
                    ),
                  if (preview)
                    StatusPill(
                      p.status == 'draft'
                          ? 'Private draft preview'
                          : 'Published preview',
                    ),
                ],
              ),
              const SizedBox(height: 36),
              Eyebrow('${p.category}${p.date.isEmpty ? '' : ' / ${p.date}'}'),
              const SizedBox(height: 16),
              Text(
                p.title,
                style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).width < 600 ? 46 : 76,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Text(
                  p.description,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Design.muted,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ProjectStoreLinks(project: p),
              const SizedBox(height: 36),
              if (p.gallery.isNotEmpty || p.image.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 950),
                  child: ProjectMedia(project: p),
                ),
              const SizedBox(height: 48),
              _section('Product overview', p.overview),
              _section('Who it’s for', p.audience),
              _section('My role & contribution', p.role),
              if (p.features.isNotEmpty) ...[
                const Text(
                  'Features & user journeys',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 20),
                for (final feature in p.features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Design.accent,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 16, height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
              ],
              _section('Technical challenges', p.challenges),
              _section('Implementation decisions', p.decisions),
              if (p.technologies.isNotEmpty) ...[
                const Text(
                  'Technologies & integrations',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: p.technologies
                      .map((e) => Chip(label: Text(e)))
                      .toList(),
                ),
                const SizedBox(height: 40),
              ],
              if (p.gallery.isNotEmpty) ...[
                const Text(
                  'Inside the application',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a screen to take a closer look.',
                  style: TextStyle(color: Design.muted),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth < 500
                        ? 2
                        : c.maxWidth < 800
                        ? 3
                        : 4;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      children: [
                        for (var i = 0; i < p.gallery.length; i++)
                          SizedBox(
                            width: (c.maxWidth - 16 * (cols - 1)) / cols,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  button: true,
                                  label:
                                      'View ${(p.gallery[i]['alt'] ?? 'screen ${i + 1}')} full size',
                                  excludeSemantics: true,
                                  onTap: () => showDialog(
                                    useRootNavigator: false,
                                    context: context,
                                    builder: (_) => GalleryViewer(
                                      project: p,
                                      initialIndex: i,
                                    ),
                                  ),
                                  child: Material(
                                    color: Design.tint,
                                    borderRadius: BorderRadius.circular(12),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () => showDialog(
                                        useRootNavigator: false,
                                        context: context,
                                        builder: (_) => GalleryViewer(
                                          project: p,
                                          initialIndex: i,
                                        ),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: .5,
                                        child: PortfolioImage(
                                          url:
                                              (p.gallery[i]['thumbnail'] ??
                                                      p.gallery[i]['url'])
                                                  .toString(),
                                          alt:
                                              (p.gallery[i]['alt'] ??
                                                      '${p.title} screen ${i + 1}')
                                                  .toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  (p.gallery[i]['alt'] ?? 'Screen ${i + 1}')
                                      .toString(),
                                  style: Design.captionType,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 48),
              ],
              _section('Outcomes', p.outcomes),
              const Divider(),
              const SizedBox(height: 24),
              ProjectStoreLinks(project: p),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String body) => body.trim().isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Design.muted,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        );
}

class ProjectStoreLinks extends StatelessWidget {
  final ProjectModel project;
  const ProjectStoreLinks({super.key, required this.project});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 8,
    children: [
      if (project.googlePlayUrl.isNotEmpty)
        ExternalAction(
          label: 'Google Play',
          url: project.googlePlayUrl,
          outlined: true,
          icon: Icons.android,
        ),
      if (project.appStoreUrl.isNotEmpty)
        ExternalAction(
          label: 'App Store',
          url: project.appStoreUrl,
          outlined: true,
          icon: Icons.apple,
        ),
      if (project.liveUrl.isNotEmpty)
        ExternalAction(label: 'Website', url: project.liveUrl),
      if (project.codeUrl.isNotEmpty)
        ExternalAction(
          label: 'Source code',
          url: project.codeUrl,
          icon: Icons.code,
        ),
      for (final link in project.additionalLinks)
        if ((link['url'] ?? '').toString().isNotEmpty)
          ExternalAction(
            label: (link['label'] ?? 'View').toString(),
            url: link['url'].toString(),
          ),
    ],
  );
}

class GalleryViewer extends StatefulWidget {
  final ProjectModel project;
  final int initialIndex;
  const GalleryViewer({
    super.key,
    required this.project,
    this.initialIndex = 0,
  });
  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late int index = widget.initialIndex;
  void move(int delta) =>
      setState(() => index = (index + delta) % widget.project.gallery.length);
  @override
  Widget build(BuildContext context) {
    final item = widget.project.gallery[index];
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => move(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => move(1),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.pop(context),
      },
      child: Focus(
        autofocus: true,
        child: ContentDialog(
          label: 'Screenshot gallery',
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          container: true,
                          liveRegion: true,
                          label:
                              '${widget.project.title} · ${index + 1} / ${widget.project.gallery.length}',
                          excludeSemantics: true,
                          child: Text(
                            '${widget.project.title} · ${index + 1} / ${widget.project.gallery.length}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close gallery',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 3,
                      child: PortfolioImage(
                        url: item['url'].toString(),
                        alt: (item['alt'] ?? '').toString(),
                        thumbnail: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (item['alt'] ?? '').toString(),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Previous screen',
                        onPressed: () => move(-1),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        tooltip: 'Next screen',
                        onPressed: () => move(1),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
