import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = width >= 768;

    return Container(
      constraints: BoxConstraints(minHeight: screenHeight),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.background,
            Color(0x4DE9EBEF),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SectionContainer(
        extraPadding: const EdgeInsets.symmetric(vertical: 80),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _HeroContent()),
                  const SizedBox(width: 48),
                  Expanded(child: _HeroImage()),
                ],
              )
            : Column(
                children: [
                  _HeroContent(),
                  const SizedBox(height: 48),
                  _HeroImage(),
                ],
              ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Flutter Developer',
            style: TextStyle(fontSize: 14, color: AppColors.foreground),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 52 : 34,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
              height: 1.2,
            ),
            children: const [
              TextSpan(text: "Hi, I'm a\n"),
              TextSpan(
                text: ' Flutter Developer',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Description
        const Text(
          "With over 10+ published apps in stores, I specialize in creating beautiful, performant mobile applications using Flutter. Let's bring your ideas to life.",
          style: TextStyle(
            fontSize: 17,
            color: AppColors.mutedForeground,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        // Buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mail_outline, size: 20),
              label: const Text('Get In Touch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 20),
              label: const Text('Download CV'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.foreground,
                side: const BorderSide(color: AppColors.border),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Social icons
        Row(
          children: [
            _SocialIconButton(
              icon: FontAwesomeIcons.github,
              onTap: () => launchUrl(Uri.parse('https://github.com')),
            ),
            const SizedBox(width: 16),
            _SocialIconButton(
              icon: FontAwesomeIcons.linkedin,
              onTap: () => launchUrl(Uri.parse('https://linkedin.com')),
            ),
            const SizedBox(width: 16),
            _SocialIconButton(
              icon: FontAwesomeIcons.envelope,
              onTap: () =>
                  launchUrl(Uri.parse('mailto:your.email@example.com')),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIconButton({required this.icon, required this.onTap});

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton> {
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
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _hovering ? AppColors.primary : AppColors.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              widget.icon,
              size: 18,
              color:
                  _hovering ? AppColors.primaryForeground : AppColors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Main image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 420,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1719400471588-575b23e27bd7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwcm9mZXNzaW9uYWwlMjBkZXZlbG9wZXIlMjB3b3Jrc3BhY2UlMjBjb2Rpbmd8ZW58MXx8fHwxNzcyMjU0NjE2fDA&ixlib=rb-4.1.0&q=80&w=1080',
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.accent,
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary)),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating stats card
            Positioned(
              bottom: -28,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(value: '10+', label: 'Apps Published'),
                    _StatDivider(),
                    _StatItem(value: '5+', label: 'Years Experience'),
                    _StatDivider(),
                    _StatItem(value: '100K+', label: 'Downloads'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44), // offset for floating card
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: AppColors.mutedForeground),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}
