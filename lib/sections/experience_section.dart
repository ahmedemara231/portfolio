import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/color_parser.dart';
import '../widgets/section_container.dart';
import '../widgets/responsive_grid.dart';

class ExperienceSection extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ExperienceSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width >= 768 ? 36.0 : 28.0;
    final cols = width >= 768 ? 2 : 1;
    final experienceTitle =
        profile['experienceTitle'] as String? ?? 'Work Experience';
    final experienceDescription = profile['experienceDescription'] as String?;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.collectionStream('experiences'),
      builder: (context, snap) {
        final experiences = snap.data ?? [];
        if (experiences.isEmpty &&
            snap.connectionState != ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        return SectionContainer(
          extraPadding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Text(
                experienceTitle,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              if (experienceDescription != null &&
                  experienceDescription.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  experienceDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.mutedForeground,
                      height: 1.6,
                      fontSize: 16),
                ),
              ],
              if (experiences.isNotEmpty) ...[
                const SizedBox(height: 64),
                ResponsiveGrid(
                  columns: cols,
                  children: [
                    for (final exp in experiences)
                      _ExperienceCard(
                        title: exp['title'] as String? ?? '',
                        company: exp['company'] as String? ?? '',
                        location: exp['location'] as String?,
                        period: exp['period'] as String?,
                        duration: exp['duration'] as String?,
                        desc: exp['description'] as String? ?? '',
                        achievements:
                            List<String>.from(exp['achievements'] ?? []),
                        gradientColor1: exp['gradientColor1'] as String?,
                        gradientColor2: exp['gradientColor2'] as String?,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream:
                    FirestoreService.collectionStream('experience_stats'),
                builder: (context, statSnap) {
                  final stats = statSnap.data ?? [];
                  if (stats.isEmpty) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final statCols =
                          constraints.maxWidth >= 600 ? stats.length : 2;
                      return ResponsiveGrid(
                        columns: statCols,
                        spacing: 0,
                        children: [
                          for (final s in stats)
                            Column(
                              children: [
                                Text(
                                  s['value'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s['label'] as String? ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.mutedForeground),
                                ),
                              ],
                            ),
                        ],
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final String title;
  final String company;
  final String? location;
  final String? period;
  final String? duration;
  final String desc;
  final List<String> achievements;
  final String? gradientColor1;
  final String? gradientColor2;

  const _ExperienceCard({
    required this.title,
    required this.company,
    this.location,
    this.period,
    this.duration,
    required this.desc,
    required this.achievements,
    this.gradientColor1,
    this.gradientColor2,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color1 = parseColor(
        widget.gradientColor1, const Color(0x1A3B82F6));
    final color2 = parseColor(
        widget.gradientColor2, const Color(0x1AA855F7));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _hovering
                              ? AppColors.primary
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.work_outline,
                              size: 16, color: AppColors.mutedForeground),
                          const SizedBox(width: 6),
                          Text(
                            widget.company,
                            style: const TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up,
                      size: 24, color: AppColors.primaryForeground),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (widget.period != null && widget.period!.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(widget.period!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground)),
                  ]),
                if (widget.location != null && widget.location!.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(widget.location!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground)),
                  ]),
                if (widget.duration != null && widget.duration!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.duration!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            if (widget.desc.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.desc,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                    height: 1.5),
              ),
            ],
            if (widget.achievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Key Achievements:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground),
              ),
              const SizedBox(height: 8),
              for (final a in widget.achievements) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u2713',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.foreground,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
