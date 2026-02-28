import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;
    final year = DateTime.now().year;

    return Container(
      color: AppColors.primary,
      child: SectionContainer(
        extraPadding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildBrand()),
                      Expanded(child: _buildLinks()),
                      Expanded(child: _buildSocial()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrand(),
                      const SizedBox(height: 32),
                      _buildLinks(),
                      const SizedBox(height: 32),
                      _buildSocial(),
                    ],
                  ),
            const SizedBox(height: 32),
            const Divider(color: Color(0x33FFFFFF)),
            const SizedBox(height: 24),
            Text(
              '© $year Flutter Developer Portfolio. All rights reserved.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xCCFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            Icon(Icons.code, size: 24, color: AppColors.primaryForeground),
            SizedBox(width: 8),
            Text(
              'Flutter Developer',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.primaryForeground,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Creating beautiful, performant mobile applications with passion and precision.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xCCFFFFFF),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLinks() {
    const links = ['About', 'Skills', 'Projects', 'Experience', 'Contact'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.primaryForeground),
        ),
        const SizedBox(height: 16),
        for (final link in links) ...[
          _FooterLink(label: link),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.primaryForeground),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _SocialBtn(
              icon: FontAwesomeIcons.github,
              onTap: () => launchUrl(Uri.parse('https://github.com')),
            ),
            const SizedBox(width: 12),
            _SocialBtn(
              icon: FontAwesomeIcons.linkedin,
              onTap: () => launchUrl(Uri.parse('https://linkedin.com')),
            ),
            const SizedBox(width: 12),
            _SocialBtn(
              icon: FontAwesomeIcons.twitter,
              onTap: () => launchUrl(Uri.parse('https://twitter.com')),
            ),
            const SizedBox(width: 12),
            _SocialBtn(
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

class _FooterLink extends StatefulWidget {
  final String label;

  const _FooterLink({required this.label});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 13,
            color: _hovering
                ? AppColors.primaryForeground
                : const Color(0xCCFFFFFF),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialBtn({required this.icon, required this.onTap});

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0x33FFFFFF)
                : const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              widget.icon,
              size: 16,
              color: AppColors.primaryForeground,
            ),
          ),
        ),
      ),
    );
  }
}
