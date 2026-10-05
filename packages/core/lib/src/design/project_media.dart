import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import 'design_system.dart';

final _storageImages = <String, Future<Uint8List?>>{};

class PortfolioImage extends StatelessWidget {
  final String url, alt;
  final BoxFit fit;
  final bool thumbnail;
  const PortfolioImage({
    super.key,
    required this.url,
    required this.alt,
    this.fit = BoxFit.contain,
    this.thumbnail = true,
  });
  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: Design.tint,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Design.muted, size: 28),
    );
    if (url.isEmpty) return fallback;
    if (url.startsWith('storage://')) {
      return FutureBuilder<Uint8List?>(
        future: _storageImages.putIfAbsent(
          url,
          () => FirebaseStorage.instance
              .ref(url.substring(10))
              .getData(8 * 1024 * 1024),
        ),
        builder: (context, snapshot) => snapshot.hasData
            ? Image.memory(
                snapshot.data!,
                fit: fit,
                semanticLabel: alt,
                cacheWidth: thumbnail ? 420 : null,
              )
            : fallback,
      );
    }
    if (url.startsWith('data:image/')) {
      try {
        return Image.memory(
          base64Decode(url.split(',').last),
          fit: fit,
          semanticLabel: alt,
          cacheWidth: thumbnail ? 420 : null,
          errorBuilder: (_, e, s) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }
    if (url.startsWith('packages/') || url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        semanticLabel: alt,
        cacheWidth: thumbnail ? 420 : null,
        errorBuilder: (_, e, s) => fallback,
      );
    }
    return Image.network(
      url,
      fit: fit,
      semanticLabel: alt,
      cacheWidth: thumbnail ? 420 : null,
      errorBuilder: (_, e, s) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}

/// Store artwork already contains device framing; do not add a second phone.
class ProjectMedia extends StatefulWidget {
  final ProjectModel project;
  final bool compact;
  const ProjectMedia({super.key, required this.project, this.compact = false});
  @override
  State<ProjectMedia> createState() => _ProjectMediaState();
}

class _ProjectMediaState extends State<ProjectMedia> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final images = p.gallery
        .where((e) => (e['url'] ?? '').toString().isNotEmpty)
        .take(2)
        .toList();
    final color = switch (p.category) {
      'Services' => const Color(0xFFEFE6D4),
      'Marketplace' => const Color(0xFFE5ECF0),
      'Fitness' => const Color(0xFFE8E8E1),
      'Location & travel' => const Color(0xFFE1EBE3),
      _ => Design.tint,
    };
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Design.radius),
        child: AspectRatio(
          aspectRatio: widget.compact ? 1.35 : 1.52,
          child: Container(
            color: color,
            child: LayoutBuilder(
              builder: (context, c) {
                if (images.isEmpty) {
                  if (p.image.isNotEmpty && p.imageKind != 'placeholder')
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: c.maxWidth - 48,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Eyebrow(p.category),
                              const SizedBox(height: 12),
                              Text(
                                p.title,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Explore the product',
                                style: TextStyle(color: Design.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                }
                final height = c.maxHeight * (widget.compact ? .87 : .89);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 18,
                      left: 20,
                      child: Text(
                        p.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: Design.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (var i = 0; i < images.length; i++)
                      Align(
                        alignment: Alignment(
                          images.length == 1 ? 0 : (i == 0 ? -.42 : .42),
                          i == 0 ? .15 : .45,
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            end: hovering && !Design.reduced(context)
                                ? 1.035
                                : 1,
                          ),
                          duration: Design.reduced(context)
                              ? Duration.zero
                              : Design.motion,
                          curve: Curves.easeOutCubic,
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale,
                            child: Transform.rotate(
                              angle: images.length == 1
                                  ? 0
                                  : (i == 0 ? -3 : 3) * math.pi / 180,
                              child: child,
                            ),
                          ),
                          child: Container(
                            height: height,
                            width: height * .465,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [Design.shadow],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PortfolioImage(
                                url:
                                    ((images[i]['thumbnail'] ?? '')
                                                .toString()
                                                .isNotEmpty
                                            ? images[i]['thumbnail']
                                            : images[i]['url'])
                                        .toString(),
                                alt:
                                    (images[i]['alt'] ??
                                            '${p.title} screen ${i + 1}')
                                        .toString(),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
