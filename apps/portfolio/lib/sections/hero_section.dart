import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/core.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';

class HeroSection extends StatelessWidget {
  final Map<String, dynamic> profile;

  const HeroSection({super.key, required this.profile});

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
                  Expanded(child: _HeroContent(profile: profile)),
                  const SizedBox(width: 48),
                  Expanded(child: _HeroImage(profile: profile)),
                ],
              )
            : Column(
                children: [
                  _HeroContent(profile: profile),
                  const SizedBox(height: 48),
                  _HeroImage(profile: profile),
                ],
              ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _HeroContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;
    final badge = profile['badge'] as String?;
    final heroTitle = profile['heroTitle'] as String? ?? "Hi, I'm a\n Developer";
    final heroHighlight = profile['heroHighlight'] as String?;
    final heroDescription = profile['heroDescription'] as String? ?? '';
    final cvUrl = profile['cvUrl'] as String?;
    final contactEmail = profile['contactEmail'] as String?;
    final availabilityStatus = profile['availabilityStatus'] as String? ?? '';
    final availabilityNote = profile['availabilityNote'] as String? ?? '';
    final availability = _AvailabilityPalette.from(availabilityStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (availability != null) ...[
          _AvailabilityPill(
            palette: availability,
            note: availabilityNote.isEmpty
                ? availability.defaultLabel
                : availabilityNote,
          ),
          const SizedBox(height: 16),
        ],
        if (badge != null && badge.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: const TextStyle(fontSize: 14, color: AppColors.foreground),
            ),
          ),
        if (badge != null && badge.isNotEmpty) const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 52 : 34,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
              height: 1.2,
            ),
            children: [
              TextSpan(text: heroTitle),
              if (heroHighlight != null && heroHighlight.isNotEmpty)
                TextSpan(
                  text: heroHighlight,
                  style: const TextStyle(color: AppColors.primary),
                ),
            ],
          ),
        ),
        if (heroDescription.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            heroDescription,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.mutedForeground,
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            if (contactEmail != null && contactEmail.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('mailto:$contactEmail')),
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
            if (cvUrl != null && cvUrl.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(cvUrl)),
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
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.collectionStream('social_links'),
          builder: (context, snap) {
            final links = snap.data ?? [];
            if (links.isEmpty) return const SizedBox.shrink();
            return Row(
              children: [
                for (int i = 0; i < links.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  _SocialIconButton(
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
            );
          },
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
  final Map<String, dynamic> profile;

  const _HeroImage({required this.profile});

  @override
  Widget build(BuildContext context) {
    final heroImage = profile['heroImage'] as String?;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 420,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (heroImage != null && heroImage.isNotEmpty)
                      Image.network(
                        heroImage,
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
                      )
                    else
                      Container(color: AppColors.accent),
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
            Positioned(
              bottom: -28,
              left: 16,
              right: 16,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirestoreService.collectionStream('stats'),
                builder: (context, snap) {
                  final stats = snap.data ?? [];
                  if (stats.isEmpty) return const SizedBox.shrink();
                  return Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (int i = 0; i < stats.length; i++) ...[
                          if (i > 0) _StatDivider(),
                          _StatItem(
                            value: stats[i]['value'] as String? ?? '',
                            label: stats[i]['label'] as String? ?? '',
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
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
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}

class _AvailabilityPalette {
  final Color background;
  final Color foreground;
  final Color dot;
  final String defaultLabel;

  const _AvailabilityPalette({
    required this.background,
    required this.foreground,
    required this.dot,
    required this.defaultLabel,
  });

  static _AvailabilityPalette? from(String status) {
    switch (status) {
      case 'available':
        return const _AvailabilityPalette(
          background: Color(0x1A22C55E),
          foreground: Color(0xFF15803D),
          dot: Color(0xFF22C55E),
          defaultLabel: 'Available for work',
        );
      case 'open':
        return const _AvailabilityPalette(
          background: Color(0x1AEAB308),
          foreground: Color(0xFF854D0E),
          dot: Color(0xFFEAB308),
          defaultLabel: 'Open to opportunities',
        );
      case 'unavailable':
        return const _AvailabilityPalette(
          background: Color(0x1A6B7280),
          foreground: Color(0xFF374151),
          dot: Color(0xFF6B7280),
          defaultLabel: 'Currently engaged',
        );
      default:
        return null;
    }
  }
}

class _AvailabilityPill extends StatelessWidget {
  final _AvailabilityPalette palette;
  final String note;
  const _AvailabilityPill({required this.palette, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: palette.dot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: palette.dot.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            note,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
