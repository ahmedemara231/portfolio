import 'package:flutter/material.dart';
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

    final projects = [
      (
        title: 'E-Commerce App',
        desc:
            'A full-featured shopping app with payment integration, real-time inventory, and order tracking.',
        image:
            'https://images.unsplash.com/photo-1723705027411-9bfc3c99c2e9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
        tags: ['Flutter', 'Firebase', 'Stripe', 'BLoC'],
        downloads: '50K+',
        rating: 4.5,
      ),
      (
        title: 'Fitness Tracker',
        desc:
            'Track workouts, calories, and progress with beautiful charts and personalized workout plans.',
        image:
            'https://images.unsplash.com/photo-1591311630200-ffa9120a540f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
        tags: ['Flutter', 'SQLite', 'Provider', 'Charts'],
        downloads: '30K+',
        rating: 4.7,
      ),
      (
        title: 'Food Delivery',
        desc:
            'Real-time order tracking, restaurant discovery, and seamless checkout experience.',
        image:
            'https://images.unsplash.com/photo-1605108222700-0d605d9ebafe?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
        tags: ['Flutter', 'Google Maps', 'Firebase', 'Push Notifications'],
        downloads: '75K+',
        rating: 4.6,
      ),
      (
        title: 'Social Media App',
        desc:
            'Connect with friends, share moments, and engage with a vibrant community.',
        image:
            'https://images.unsplash.com/photo-1661246626039-5429b8f7488a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
        tags: ['Flutter', 'REST API', 'Riverpod', 'Camera'],
        downloads: '100K+',
        rating: 4.4,
      ),
      (
        title: 'Learning Platform',
        desc:
            'Online courses, video streaming, quizzes, and progress tracking for students.',
        image:
            'https://images.unsplash.com/photo-1646737554389-49329965ef01?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
        tags: ['Flutter', 'Video Player', 'Firebase', 'BLoC'],
        downloads: '40K+',
        rating: 4.8,
      ),
      (
        title: 'Task Management',
        desc:
            'Organize your life with intuitive task lists, reminders, and productivity analytics.',
        image:
            'https://images.unsplash.com/photo-1661246626039-5429b8f7488a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
        tags: ['Flutter', 'SQLite', 'Notifications', 'Provider'],
        downloads: '25K+',
        rating: 4.5,
      ),
    ];

    return Container(
      color: AppColors.accent.withValues(alpha: 0.3),
      child: SectionContainer(
        extraPadding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            // Header
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
              "A showcase of mobile applications I've built and published to the App Store and Google Play.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.mutedForeground, height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 64),
            // Grid
            ResponsiveGrid(
              columns: cols,
              children: [
                for (final p in projects)
                  _ProjectCard(
                    title: p.title,
                    desc: p.desc,
                    image: p.image,
                    tags: p.tags,
                    downloads: p.downloads,
                    rating: p.rating,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final String title;
  final String desc;
  final String image;
  final List<String> tags;
  final String downloads;
  final double rating;

  const _ProjectCard({
    required this.title,
    required this.desc,
    required this.image,
    required this.tags,
    required this.downloads,
    required this.rating,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
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
              // Image
              SizedBox(
                height: 192,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.image,
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
                          colors: [Colors.transparent, Color(0x99000000)],
                        ),
                      ),
                    ),
                    // Action buttons
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _ImageActionButton(
                              icon: Icons.code,
                              onTap: () {}),
                          const SizedBox(width: 8),
                          _ImageActionButton(
                              icon: Icons.open_in_new,
                              onTap: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
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
                    const SizedBox(height: 8),
                    Text(
                      widget.desc,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                          height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in widget.tags)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.downloads} downloads',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedForeground),
                        ),
                        Text(
                          '⭐ ${widget.rating}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground),
                        ),
                      ],
                    ),
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
            color: _hovering ? Colors.white : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 16, color: Colors.black),
        ),
      ),
    );
  }
}
