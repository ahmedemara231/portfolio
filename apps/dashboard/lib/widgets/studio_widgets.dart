import 'package:core/core.dart';
import 'package:flutter/material.dart';

class StudioPageHeader extends StatelessWidget {
  final String eyebrow, title, description;
  final Widget? action;
  const StudioPageHeader({
    super.key,
    required this.title,
    required this.description,
    this.eyebrow = 'Portfolio content',
    this.action,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              title,
              style: Design.pageType.copyWith(
                fontSize: c.maxWidth < 600 ? 32 : 40,
                height: 1.15,
                letterSpacing: c.maxWidth < 600 ? -1.1 : -1.6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Text(
              description,
              style: Design.bodyType.copyWith(fontSize: 14),
            ),
          ),
        ],
      );
      if (action == null) return copy;
      if (c.maxWidth < 760) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [copy, const SizedBox(height: 20), action!],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: copy),
          const SizedBox(width: 32),
          action!,
        ],
      );
    },
  );
}

class StudioPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  const StudioPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = Design.surface,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Design.line),
      borderRadius: BorderRadius.circular(Design.radius),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class StudioSectionTitle extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;
  const StudioSectionTitle({
    super.key,
    required this.title,
    this.description,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(title, style: Design.groupType),
          if (action != null) action!,
        ],
      ),
      if (description != null) ...[
        const SizedBox(height: 8),
        Text(description!, style: Design.captionType),
      ],
    ],
  );
}

/// A private rendering of profile values; no separate demo copy is maintained.
class StudioProfilePreview extends StatelessWidget {
  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> indicators;
  final bool compact;
  const StudioProfilePreview({
    super.key,
    required this.profile,
    this.indicators = const [],
    this.compact = false,
  });
  String text(String key, [String fallback = '']) =>
      (profile[key] ?? fallback).toString();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Eyebrow(
        '${text('professionalTitle', text('badge'))} / ${text('contactLocation')}',
      ),
      const SizedBox(height: 20),
      Text(
        text('name', 'Your name'),
        style: TextStyle(
          fontSize: compact ? 30 : 44,
          fontWeight: FontWeight.w800,
          height: 1.12,
          letterSpacing: compact ? -1 : -1.8,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        text('heroTitle'),
        style: TextStyle(
          fontSize: compact ? 24 : 32,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: Design.accent,
          letterSpacing: -.8,
        ),
      ),
      if (text('heroHighlight').trim().isNotEmpty)
        Text(
          text('heroHighlight'),
          style: const TextStyle(fontSize: 20, color: Design.accent),
        ),
      const SizedBox(height: 16),
      Text(
        text('heroDescription'),
        style: Design.bodyType.copyWith(fontSize: 14),
      ),
      if (text('availabilityStatus').isNotEmpty) ...[
        const SizedBox(height: 20),
        StatusPill(
          text('availabilityNote').isNotEmpty
              ? text('availabilityNote')
              : switch (text('availabilityStatus')) {
                  'available' => 'Available for opportunities',
                  'open' => 'Open to opportunities',
                  _ => 'Currently engaged',
                },
          active: text('availabilityStatus') != 'unavailable',
        ),
      ],
      if (indicators.isNotEmpty) ...[
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: indicators
              .map(
                (entry) => SizedBox(
                  width: compact ? 88 : 126,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry['value'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry['label'] ?? ''}',
                        style: Design.captionType.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ],
  );
}

class StudioSocialPreview extends StatelessWidget {
  final Map<String, dynamic> profile;
  const StudioSocialPreview({super.key, required this.profile});
  String get imageUrl {
    final url = '${profile['socialImage'] ?? ''}';
    final origin = Uri.tryParse('${profile['siteUrl'] ?? ''}');
    if (url.startsWith('/') &&
        FirestoreService.useFirebase &&
        !FirestoreService.useEmulators &&
        origin != null &&
        {'https', 'http'}.contains(origin.scheme) &&
        origin.host.isNotEmpty) {
      return origin.resolve(url).toString();
    }
    return url;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 1.91,
          child: PortfolioImage(url: imageUrl, alt: 'Social sharing preview'),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        '${profile['siteUrl'] ?? ''}',
        style: Design.captionType.copyWith(color: Design.accent),
      ),
      const SizedBox(height: 8),
      Text(
        '${profile['seoTitle'] ?? ''}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        '${profile['seoDescription'] ?? ''}',
        style: Design.bodyType.copyWith(fontSize: 13),
      ),
    ],
  );
}

void showStudioProjectPreview(BuildContext context, ProjectModel project) =>
    showContentDialog(
      useRootNavigator: false,
      context: context,
      builder: (ctx) => ContentDialog(
        label: 'Project preview',
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Private project preview',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close preview',
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(child: ProjectDetail(project: project, preview: true)),
          ],
        ),
      ),
    );

void showStudioProfilePreview(
  BuildContext context,
  Map<String, dynamic> profile, {
  List<Map<String, dynamic>> indicators = const [],
  bool metadata = false,
}) {
  var phone = false;
  showContentDialog(
    useRootNavigator: false,
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => ContentDialog(
        label: metadata ? 'Sharing preview' : 'Introduction preview',
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * .82,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          metadata
                              ? 'Private sharing preview'
                              : 'Private introduction preview',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close preview',
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Desktop'),
                        selected: !phone,
                        onSelected: (_) => update(() => phone = false),
                      ),
                      ChoiceChip(
                        label: const Text('Phone'),
                        selected: phone,
                        onSelected: (_) => update(() => phone = true),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: phone ? 390 : 850,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: StudioPanel(
                            color: Design.paper,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PortfolioBrand(
                                  name: '${profile['name'] ?? 'Ahmed Emara'}',
                                  compact: phone,
                                ),
                                const SizedBox(height: 32),
                                if (metadata)
                                  StudioSocialPreview(profile: profile)
                                else
                                  StudioProfilePreview(
                                    profile: profile,
                                    indicators: indicators,
                                    compact:
                                        phone ||
                                        MediaQuery.sizeOf(ctx).width < 600,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
