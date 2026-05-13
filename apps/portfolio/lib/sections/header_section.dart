import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class HeaderSection extends StatefulWidget {
  final VoidCallback onAbout;
  final VoidCallback onSkills;
  final VoidCallback onProjects;
  final VoidCallback onExperience;
  final VoidCallback onContact;
  final String cvUrl;

  const HeaderSection({
    super.key,
    required this.onAbout,
    required this.onSkills,
    required this.onProjects,
    required this.onExperience,
    required this.onContact,
    this.cvUrl = '',
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xCCFFFFFF), // white ~80% opacity
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    // Logo
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/logo.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    // Desktop nav
                    if (!isMobile) ...[
                      _NavButton('About', widget.onAbout),
                      const SizedBox(width: 32),
                      _NavButton('Skills', widget.onSkills),
                      const SizedBox(width: 32),
                      _NavButton('Projects', widget.onProjects),
                      const SizedBox(width: 32),
                      _NavButton('Experience', widget.onExperience),
                      const SizedBox(width: 32),
                      if (widget.cvUrl.isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: () => launchUrl(Uri.parse(widget.cvUrl)),
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: const Text('CV'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.foreground,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      ElevatedButton(
                        onPressed: widget.onContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Contact'),
                      ),
                    ] else ...[
                      IconButton(
                        icon: Icon(
                          _isMenuOpen ? Icons.close : Icons.menu,
                          color: AppColors.foreground,
                        ),
                        onPressed: () =>
                            setState(() => _isMenuOpen = !_isMenuOpen),
                      ),
                    ],
                  ],
                ),
              ),
              // Mobile dropdown
              if (isMobile && _isMenuOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MobileNavButton('About', () {
                        widget.onAbout();
                        setState(() => _isMenuOpen = false);
                      }),
                      _MobileNavButton('Skills', () {
                        widget.onSkills();
                        setState(() => _isMenuOpen = false);
                      }),
                      _MobileNavButton('Projects', () {
                        widget.onProjects();
                        setState(() => _isMenuOpen = false);
                      }),
                      _MobileNavButton('Experience', () {
                        widget.onExperience();
                        setState(() => _isMenuOpen = false);
                      }),
                      if (widget.cvUrl.isNotEmpty)
                        _MobileNavButton('Download CV', () {
                          launchUrl(Uri.parse(widget.cvUrl));
                          setState(() => _isMenuOpen = false);
                        }),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onContact();
                            setState(() => _isMenuOpen = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryForeground,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Contact'),
                        ),
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

class _NavButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton(this.label, this.onTap);

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hovering ? AppColors.primary : AppColors.foreground,
            fontSize: 15,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _MobileNavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MobileNavButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.foreground,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
