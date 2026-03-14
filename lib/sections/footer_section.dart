import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/icon_mapper.dart';
import '../widgets/section_container.dart';

class FooterSection extends StatelessWidget {
  final Map<String, dynamic> profile;

  const FooterSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;
    final year = DateTime.now().year;
    final footerBrand = profile['footerBrand'] as String? ?? 'Portfolio';
    final footerDescription = profile['footerDescription'] as String?;
    final copyright = profile['copyright'] as String?;

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
                      Expanded(
                          child: _buildBrand(
                              footerBrand, footerDescription)),
                      Expanded(child: _buildLinks()),
                      Expanded(child: _buildSocial()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrand(footerBrand, footerDescription),
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
              copyright ??
                  '\u00a9 $year $footerBrand. All rights reserved.',
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

  Widget _buildBrand(String brand, String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
                Icons.code, size: 24, color: AppColors.primaryForeground),
            const SizedBox(width: 8),
            Text(
              brand,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.primaryForeground,
              ),
            ),
          ],
        ),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xCCFFFFFF),
              height: 1.6,
            ),
          ),
        ],
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.collectionStream('social_links'),
      builder: (context, snap) {
        final links = snap.data ?? [];
        if (links.isEmpty) return const SizedBox.shrink();
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
                for (int i = 0; i < links.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _SocialBtn(
                    icon: mapIcon(links[i]['icon'] as String?),
                    onTap: () {
                      final url = links[i]['url'] as String?;
                      if (url != null && url.isNotEmpty) {
                        launchUrl(Uri.parse(url));
                      }
                    },
                  ),
                ],
              ],
            ),
          ],
        );
      },
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
