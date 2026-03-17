import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/core.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';
import '../widgets/responsive_grid.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width >= 768 ? 36.0 : 28.0;
    final cols = width >= 1024 ? 3 : (width >= 768 ? 2 : 1);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.collectionStream('projects'),
      builder: (context, snap) {
        final projects = snap.data ?? [];
        if (projects.isEmpty &&
            snap.connectionState != ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        return Container(
          color: AppColors.accent.withValues(alpha: 0.3),
          child: SectionContainer(
            extraPadding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              children: [
                Text(
                  'Featured Projects',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "A showcase of applications I've built and published.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.mutedForeground,
                      height: 1.6,
                      fontSize: 16),
                ),
                if (projects.isNotEmpty) ...[
                  const SizedBox(height: 64),
                  ResponsiveGrid(
                    columns: cols,
                    children: [
                      for (final p in projects)
                        _ProjectCard(
                          title: p['title'] as String? ?? '',
                          desc: p['description'] as String? ?? '',
                          image: p['image'] as String?,
                          tags: List<String>.from(p['tags'] ?? []),
                          downloads: p['downloads'] as String?,
                          rating: (p['rating'] as num?)?.toDouble(),
                          codeUrl: p['codeUrl'] as String?,
                          liveUrl: p['liveUrl'] as String?,
                          tagColor: p['tagColor'] as String?,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final String title;
  final String desc;
  final String? image;
  final List<String> tags;
  final String? downloads;
  final double? rating;
  final String? codeUrl;
  final String? liveUrl;
  final String? tagColor;

  const _ProjectCard({
    required this.title,
    required this.desc,
    this.image,
    required this.tags,
    this.downloads,
    this.rating,
    this.codeUrl,
    this.liveUrl,
    this.tagColor,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final tagBg = widget.tagColor != null
        ? parseColor(widget.tagColor).withValues(alpha: 0.1)
        : AppColors.primary.withValues(alpha: 0.1);
    final tagFg =
        widget.tagColor != null ? parseColor(widget.tagColor) : AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.image != null && widget.image!.isNotEmpty)
                SizedBox(
                  height: 192,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.image!,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(color: AppColors.accent);
                        },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x99000000)
                            ],
                          ),
                        ),
                      ),
                      if (widget.codeUrl != null || widget.liveUrl != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            children: [
                              if (widget.codeUrl != null &&
                                  widget.codeUrl!.isNotEmpty) ...[
                                _ImageActionButton(
                                    icon: Icons.code,
                                    onTap: () => launchUrl(
                                        Uri.parse(widget.codeUrl!))),
                              ],
                              if (widget.codeUrl != null &&
                                  widget.liveUrl != null)
                                const SizedBox(width: 8),
                              if (widget.liveUrl != null &&
                                  widget.liveUrl!.isNotEmpty)
                                _ImageActionButton(
                                    icon: Icons.open_in_new,
                                    onTap: () => launchUrl(
                                        Uri.parse(widget.liveUrl!))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.foreground),
                    ),
                    if (widget.desc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.desc,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            height: 1.5),
                      ),
                    ],
                    if (widget.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in widget.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tagBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: tagFg,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (widget.downloads != null || widget.rating != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.downloads != null)
                            Text(
                              '${widget.downloads} downloads',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedForeground),
                            ),
                          if (widget.rating != null)
                            Text(
                              '\u2b50 ${widget.rating}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ImageActionButton({required this.icon, required this.onTap});

  @override
  State<_ImageActionButton> createState() => _ImageActionButtonState();
}

class _ImageActionButtonState extends State<_ImageActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovering
                ? Colors.white
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 16, color: Colors.black),
        ),
      ),
    );
  }
}
