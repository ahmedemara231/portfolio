import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../widgets/record_editor.dart';

class SettingsPage extends StatefulWidget {
  final bool metadata;
  const SettingsPage({super.key, this.metadata = false});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final stream = FirestoreService.profileStream();
  bool exporting = false;
  Future<void> export() async {
    setState(() => exporting = true);
    try {
      final content = await FirestoreService.exportPublishedContent();
      downloadFile(
        'data:application/json;base64,${base64Encode(utf8.encode(const JsonEncoder.withIndent('  ').convert(content)))}',
        'portfolio-content.json',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content export failed. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<Map<String, dynamic>?>(
    stream: stream,
    builder: (context, snap) {
      if (snap.hasError) {
        return const StateMessage(
          title: 'Could not load your profile',
          message: 'Check your connection and administrator access.',
        );
      }
      if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final p = snap.data ?? {};
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Your public presence'),
            const SizedBox(height: 10),
            Text(
              widget.metadata ? 'Search & sharing' : 'Profile & contact',
              style: Design.pageType,
            ),
            const SizedBox(height: 16),
            Text(
              widget.metadata
                  ? 'Manage the page title, description, canonical origin, and social image.'
                  : 'Keep your introduction, availability, contact details, and CV current.',
              style: const TextStyle(color: Design.muted, height: 1.7),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Design.surface,
                border: Border.all(color: Design.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.metadata) ...[
                    Text(
                      (p['seoTitle'] ?? 'Page title not set').toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      (p['seoDescription'] ?? '').toString(),
                      style: const TextStyle(color: Design.muted, height: 1.8),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      (p['siteUrl'] ?? '').toString(),
                      style: const TextStyle(color: Design.accent),
                    ),
                    if ((p['socialImage'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 160,
                        child: PortfolioImage(
                          url: p['socialImage'].toString(),
                          alt: 'Social sharing preview',
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      (p['name'] ?? 'Your name').toString(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${p['professionalTitle'] ?? p['badge'] ?? ''} · ${p['contactLocation'] ?? ''}',
                      style: const TextStyle(color: Design.accent),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      (p['heroDescription'] ?? '').toString(),
                      style: const TextStyle(color: Design.muted, height: 1.8),
                    ),
                    const SizedBox(height: 24),
                    SelectableText((p['contactEmail'] ?? '').toString()),
                    const SizedBox(height: 8),
                    SelectableText((p['contactPhone'] ?? '').toString()),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        StatusPill(
                          (p['availabilityNote'] ??
                                  p['availabilityStatus'] ??
                                  'Availability hidden')
                              .toString(),
                        ),
                        if ((p['cvUrl'] ?? '').toString().isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () {
                              var url = p['cvUrl'].toString();
                              if (FirestoreService.useFirebase &&
                                  !FirestoreService.useEmulators &&
                                  url.startsWith('/')) {
                                url = Uri.parse(
                                  (p['siteUrl'] ?? '').toString(),
                                ).resolve(url).toString();
                              }
                              downloadFile(url, 'Ahmed-Emara-CV.pdf');
                            },
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: const Text('Test CV download'),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => RecordEditor(
                          profile: true,
                          id: 'main',
                          initial: p,
                          schema: ContentSchema(
                            'profile',
                            widget.metadata ? 'Search & sharing' : 'Profile',
                            widget.metadata ? 'metadata' : 'profile',
                            'name',
                            widget.metadata
                                ? 'Metadata updates appear in the running site. Generate static sharing files before publishing.'
                                : 'These fields drive the public portfolio. Keep every claim factual and concise.',
                            widget.metadata ? metadataFields : profileFields,
                          ),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      widget.metadata ? 'Edit metadata' : 'Edit profile',
                    ),
                  ),
                ],
              ),
            ),
            if (widget.metadata) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: exporting ? null : export,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text(
                  exporting ? 'Preparing export…' : 'Export published content',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Flutter renders the portfolio in the browser. Static social previews and sitemap files are generated from published content at build time; rebuild them after content changes.',
                style: TextStyle(
                  color: Design.muted,
                  fontSize: 13,
                  height: 1.8,
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
