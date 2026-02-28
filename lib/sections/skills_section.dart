import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';
import '../widgets/responsive_grid.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width >= 768 ? 36.0 : 28.0;
    final techSkillCols = width >= 1024 ? 4 : (width >= 640 ? 2 : 1);
    final softSkillCols = width >= 1024 ? 3 : (width >= 768 ? 2 : 1);

    const technicalSkills = [
      (icon: Icons.code, name: 'Flutter & Dart', level: 'Expert'),
      (icon: Icons.storage, name: 'Firebase', level: 'Advanced'),
      (icon: Icons.bolt, name: 'REST APIs', level: 'Advanced'),
      (icon: Icons.view_quilt, name: 'State Management', level: 'Expert'),
      (icon: Icons.smartphone, name: 'Native Integration', level: 'Advanced'),
      (icon: Icons.account_tree_outlined, name: 'Git & GitHub', level: 'Advanced'),
      (icon: Icons.palette_outlined, name: 'UI/UX Design', level: 'Intermediate'),
      (icon: Icons.data_object, name: 'SQLite & Hive', level: 'Advanced'),
    ];

    const softSkills = [
      (
        icon: Icons.chat_bubble_outline,
        name: 'Communication',
        desc: 'Clear and effective communication with team and stakeholders'
      ),
      (
        icon: Icons.people_outline,
        name: 'Team Leadership',
        desc: 'Leading and mentoring development teams to success'
      ),
      (
        icon: Icons.lightbulb_outline,
        name: 'Problem Solving',
        desc: 'Creative solutions to complex technical challenges'
      ),
      (
        icon: Icons.gps_fixed,
        name: 'Goal-Oriented',
        desc: 'Focused on delivering results and meeting objectives'
      ),
      (
        icon: Icons.access_time,
        name: 'Time Management',
        desc: 'Efficient prioritization and deadline management'
      ),
      (
        icon: Icons.bolt,
        name: 'Adaptability',
        desc: 'Quick learner, adapting to new technologies and methodologies'
      ),
    ];

    const technologies = [
      'Flutter', 'Dart', 'Firebase', 'REST API', 'GraphQL', 'BLoC',
      'Provider', 'Riverpod', 'GetX', 'SQLite', 'Hive', 'SharedPreferences',
      'Git', 'GitHub Actions', 'Fastlane', 'Android Studio', 'VS Code',
      'Xcode', 'Figma', 'Adobe XD', 'Postman', 'Jira', 'Slack', 'CI/CD',
    ];

    return SectionContainer(
      extraPadding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Skills & Expertise',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'A comprehensive toolkit of technical abilities and interpersonal skills refined through years of development.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.mutedForeground, height: 1.6, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64),

          // Technical Skills
          const Text(
            'Technical Skills',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground),
          ),
          const SizedBox(height: 32),
          ResponsiveGrid(
            columns: techSkillCols,
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final skill in technicalSkills)
                _TechSkillCard(
                    icon: skill.icon, name: skill.name, level: skill.level),
            ],
          ),
          const SizedBox(height: 64),

          // Soft Skills
          const Text(
            'Soft Skills',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground),
          ),
          const SizedBox(height: 32),
          ResponsiveGrid(
            columns: softSkillCols,
            children: [
              for (final skill in softSkills)
                _SoftSkillCard(
                    icon: skill.icon, name: skill.name, desc: skill.desc),
            ],
          ),
          const SizedBox(height: 64),

          // Technologies & Tools
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text(
                  'Technologies & Tools',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final tech in technologies) _TechChip(label: tech),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechSkillCard extends StatefulWidget {
  final IconData icon;
  final String name;
  final String level;

  const _TechSkillCard(
      {required this.icon, required this.name, required this.level});

  @override
  State<_TechSkillCard> createState() => _TechSkillCardState();
}

class _TechSkillCardState extends State<_TechSkillCard> {
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
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _hovering
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.icon,
                size: 32,
                color: _hovering
                    ? AppColors.primaryForeground
                    : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.foreground),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                widget.level,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftSkillCard extends StatefulWidget {
  final IconData icon;
  final String name;
  final String desc;

  const _SoftSkillCard(
      {required this.icon, required this.name, required this.desc});

  @override
  State<_SoftSkillCard> createState() => _SoftSkillCardState();
}

class _SoftSkillCardState extends State<_SoftSkillCard> {
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.card, Color(0x4DE9EBEF)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon,
                  size: 24, color: AppColors.primaryForeground),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.foreground),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.desc,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechChip extends StatefulWidget {
  final String label;

  const _TechChip({required this.label});

  @override
  State<_TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<_TechChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _hovering ? AppColors.primary : AppColors.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            color: _hovering
                ? AppColors.primaryForeground
                : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}
