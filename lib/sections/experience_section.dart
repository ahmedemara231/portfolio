import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';
import '../widgets/responsive_grid.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width >= 768 ? 36.0 : 28.0;
    final cols = width >= 768 ? 2 : 1;

    final experiences = [
      (
        title: 'Senior Flutter Developer',
        company: 'Tech Solutions Inc.',
        location: 'San Francisco, CA',
        period: '2022 - Present',
        duration: '2 years',
        desc:
            'Lead Flutter developer responsible for architecture and delivery of multiple high-impact mobile applications. Mentor junior developers and establish best practices.',
        achievements: [
          'Led development of 5+ production apps with 200K+ combined downloads',
          'Improved app performance by 40% through optimization',
          'Established CI/CD pipeline reducing deployment time by 60%',
          'Mentored 5 junior developers',
        ],
        gradientColors: [Color(0x1A3B82F6), Color(0x1AA855F7)],
      ),
      (
        title: 'Flutter Developer',
        company: 'Mobile Apps Studio',
        location: 'Remote',
        period: '2020 - 2022',
        duration: '2 years',
        desc:
            'Developed and maintained Flutter applications for various clients across different industries including e-commerce, healthcare, and education.',
        achievements: [
          'Built 8+ client apps from scratch to store publication',
          'Integrated third-party APIs and payment gateways',
          'Collaborated with designers to create pixel-perfect UIs',
          'Maintained 4.5+ star rating across all published apps',
        ],
        gradientColors: [Color(0x1A22C55E), Color(0x1A14B8A6)],
      ),
      (
        title: 'Mobile Developer',
        company: 'Digital Innovations',
        location: 'New York, NY',
        period: '2019 - 2020',
        duration: '1 year',
        desc:
            'Worked on cross-platform mobile development projects, specializing in Flutter after starting with native development.',
        achievements: [
          'Successfully migrated 2 native apps to Flutter',
          'Reduced codebase by 50% through Flutter migration',
          'Contributed to 4 production apps',
          'Participated in agile development processes',
        ],
        gradientColors: [Color(0x1AF97316), Color(0x1AEF4444)],
      ),
      (
        title: 'Junior Mobile Developer',
        company: 'Startup Labs',
        location: 'Austin, TX',
        period: '2018 - 2019',
        duration: '1 year',
        desc:
            'Gained hands-on experience in mobile app development, working on both native and cross-platform projects.',
        achievements: [
          'Contributed to 3 production apps',
          'Learned Flutter and contributed to migration from native',
          'Fixed 100+ bugs and implemented new features',
          "Achieved 'Employee of the Quarter' award",
        ],
        gradientColors: [Color(0x1AEC4899), Color(0x1AF43F5E)],
      ),
    ];

    return SectionContainer(
      extraPadding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          // Header
          Text(
            'Work Experience',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'My professional journey in mobile app development, building impactful applications for users worldwide.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.mutedForeground, height: 1.6, fontSize: 16),
          ),
          const SizedBox(height: 64),
          // Experience cards
          ResponsiveGrid(
            columns: cols,
            children: [
              for (final exp in experiences)
                _ExperienceCard(
                  title: exp.title,
                  company: exp.company,
                  location: exp.location,
                  period: exp.period,
                  duration: exp.duration,
                  desc: exp.desc,
                  achievements: exp.achievements,
                  gradientColors: exp.gradientColors,
                ),
            ],
          ),
          const SizedBox(height: 48),
          // Summary stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              final statCols = constraints.maxWidth >= 600 ? 4 : 2;
              return _buildStats(statCols);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int cols) {
    const stats = [
      (value: '6+', label: 'Years Experience'),
      (value: '4', label: 'Companies'),
      (value: '20+', label: 'Projects Delivered'),
      (value: '200K+', label: 'Total Downloads'),
    ];

    return ResponsiveGrid(
      columns: cols,
      spacing: 0,
      children: [
        for (final s in stats)
          Column(
            children: [
              Text(
                s.value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.mutedForeground),
              ),
            ],
          ),
      ],
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final String title;
  final String company;
  final String location;
  final String period;
  final String duration;
  final String desc;
  final List<String> achievements;
  final List<Color> gradientColors;

  const _ExperienceCard({
    required this.title,
    required this.company,
    required this.location,
    required this.period,
    required this.duration,
    required this.desc,
    required this.achievements,
    required this.gradientColors,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
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
            colors: widget.gradientColors,
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
            // Header row
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
            // Meta info
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text(widget.period,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.mutedForeground)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text(widget.location,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.mutedForeground)),
                ]),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.duration,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              widget.desc,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.mutedForeground, height: 1.5),
            ),
            const SizedBox(height: 16),
            // Achievements
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
                  const Text('✓',
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
        ),
      ),
    );
  }
}
