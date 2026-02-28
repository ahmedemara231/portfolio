import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';
import '../widgets/responsive_grid.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width >= 768 ? 36.0 : 28.0;
    final cols = width >= 1024 ? 4 : (width >= 768 ? 2 : 1);

    const features = [
      (
        icon: Icons.code,
        title: 'Clean Code',
        desc:
            'Writing maintainable, scalable, and well-documented code following best practices.'
      ),
      (
        icon: Icons.smartphone,
        title: 'Cross-Platform',
        desc:
            'Building beautiful apps for both iOS and Android from a single codebase.'
      ),
      (
        icon: Icons.bolt,
        title: 'Performance',
        desc:
            'Optimizing apps for smooth 60fps animations and minimal load times.'
      ),
      (
        icon: Icons.people_outline,
        title: 'User-Centric',
        desc: 'Creating intuitive interfaces that users love and enjoy using.'
      ),
    ];

    return Container(
      color: AppColors.accent.withValues(alpha: 0.3),
      child: SectionContainer(
        extraPadding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            // Section header
            Text(
              'About Me',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "I'm a passionate Flutter developer with a track record of delivering high-quality mobile applications. My expertise lies in transforming ideas into polished, production-ready apps that users love.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedForeground,
                height: 1.6,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 64),
            // Feature cards grid
            ResponsiveGrid(
              columns: cols,
              children: [
                for (final f in features)
                  _FeatureCard(icon: f.icon, title: f.title, desc: f.desc),
              ],
            ),
          ],
        ),
      ),
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
