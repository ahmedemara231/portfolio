import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/icon_mapper.dart';
import '../widgets/section_container.dart';
import '../widgets/responsive_grid.dart';

class AboutSection extends StatelessWidget {
  final Map<String, dynamic> profile;

  const AboutSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width >= 768 ? 36.0 : 28.0;
    final cols = width >= 1024 ? 4 : (width >= 768 ? 2 : 1);
    final aboutTitle = profile['aboutTitle'] as String? ?? 'About Me';
    final aboutDescription = profile['aboutDescription'] as String?;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.collectionStream('about_features'),
      builder: (context, snap) {
        final features = snap.data ?? [];

        return Container(
          color: AppColors.accent.withValues(alpha: 0.3),
          child: SectionContainer(
            extraPadding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              children: [
                Text(
                  aboutTitle,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (aboutDescription != null &&
                    aboutDescription.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    aboutDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                ],
                if (features.isNotEmpty) ...[
                  const SizedBox(height: 64),
                  ResponsiveGrid(
                    columns: cols,
                    children: [
                      for (final f in features)
                        _FeatureCard(
                          icon: mapIcon(f['icon'] as String?),
                          title: f['title'] as String? ?? '',
                          desc: f['description'] as String? ?? '',
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

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.foreground),
            ),
            const SizedBox(height: 8),
            Text(
              widget.desc,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
