import 'dart:async';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../theme/dashboard_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _badgeCtrl = TextEditingController();
  final _heroTitleCtrl = TextEditingController();
  final _heroHighlightCtrl = TextEditingController();
  final _heroDescCtrl = TextEditingController();
  final _heroImageCtrl = TextEditingController();
  final _cvUrlCtrl = TextEditingController();
  final _availabilityNoteCtrl = TextEditingController();
  String _availabilityStatus = '';
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _aboutTitleCtrl = TextEditingController();
  final _aboutDescCtrl = TextEditingController();
  final _footerBrandCtrl = TextEditingController();
  final _footerDescCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _heroTitleCtrl.dispose();
    _heroHighlightCtrl.dispose();
    _heroDescCtrl.dispose();
    _heroImageCtrl.dispose();
    _cvUrlCtrl.dispose();
    _availabilityNoteCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _aboutTitleCtrl.dispose();
    _aboutDescCtrl.dispose();
    _footerBrandCtrl.dispose();
    _footerDescCtrl.dispose();
    super.dispose();
  }

  void _loadFromProfile(Map<String, dynamic> data) {
    if (_loaded) return;
    _loaded = true;
    _badgeCtrl.text = data['badge'] ?? '';
    _heroTitleCtrl.text = data['heroTitle'] ?? '';
    _heroHighlightCtrl.text = data['heroHighlight'] ?? '';
    _heroDescCtrl.text = data['heroDescription'] ?? '';
    _heroImageCtrl.text = data['heroImage'] ?? '';
    _cvUrlCtrl.text = data['cvUrl'] ?? '';
    _availabilityStatus = data['availabilityStatus'] ?? '';
    _availabilityNoteCtrl.text = data['availabilityNote'] ?? '';
    _emailCtrl.text = data['contactEmail'] ?? '';
    _phoneCtrl.text = data['contactPhone'] ?? '';
    _locationCtrl.text = data['contactLocation'] ?? '';
    _aboutTitleCtrl.text = data['aboutTitle'] ?? '';
    _aboutDescCtrl.text = data['aboutDescription'] ?? '';
    _footerBrandCtrl.text = data['footerBrand'] ?? '';
    _footerDescCtrl.text = data['footerDescription'] ?? '';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirestoreService.updateProfile({
        'badge': _badgeCtrl.text.trim(),
        'heroTitle': _heroTitleCtrl.text,
        'heroHighlight': _heroHighlightCtrl.text,
        'heroDescription': _heroDescCtrl.text.trim(),
        'heroImage': _heroImageCtrl.text.trim(),
        'cvUrl': _cvUrlCtrl.text.trim(),
        'availabilityStatus': _availabilityStatus,
        'availabilityNote': _availabilityNoteCtrl.text.trim(),
        'contactEmail': _emailCtrl.text.trim(),
        'contactPhone': _phoneCtrl.text.trim(),
        'contactLocation': _locationCtrl.text.trim(),
        'aboutTitle': _aboutTitleCtrl.text.trim(),
        'aboutDescription': _aboutDescCtrl.text.trim(),
        'footerBrand': _footerBrandCtrl.text.trim(),
        'footerDescription': _footerDescCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.profileStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !_loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasData && snap.data != null) {
          _loadFromProfile(snap.data!);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Manage your portfolio settings and personal information',
                  style: TextStyle(color: DashboardColors.mutedForeground)),
              const SizedBox(height: 24),

              // Profile Picture & Personal Info
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 280, child: _profilePictureCard()),
                        const SizedBox(width: 24),
                        Expanded(child: _personalInfoCard()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _profilePictureCard(),
                      const SizedBox(height: 24),
                      _personalInfoCard(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Availability
              _availabilityCard(),
              const SizedBox(height: 24),

              // Contact Info
              _contactInfoCard(),
              const SizedBox(height: 24),

              // Social Links
              _socialLinksCard(),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _loaded = false),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 20),
                    label: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profilePictureCard() {
    return _card(
      'Profile Picture',
      Column(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [DashboardColors.primary, DashboardColors.primary.withValues(alpha: 0.5)],
              ),
            ),
            child: const Icon(Icons.person, size: 64, color: DashboardColors.primaryForeground),
          ),
          const SizedBox(height: 16),
          const Text('Hero Image URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: _heroImageCtrl,
            decoration: const InputDecoration(hintText: 'https://...'),
          ),
        ],
      ),
    );
  }

  Widget _personalInfoCard() {
    return _card(
      'Personal Information',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Professional Title (Badge)', _badgeCtrl, 'e.g. Flutter Developer'),
          const SizedBox(height: 16),
          _field('Hero Title', _heroTitleCtrl, "e.g. Hi, I'm a"),
          const SizedBox(height: 16),
          _field('Hero Highlight', _heroHighlightCtrl, 'e.g. Flutter Developer'),
          const SizedBox(height: 16),
          _field('Bio / Hero Description', _heroDescCtrl, 'Describe yourself...', maxLines: 3),
          const SizedBox(height: 16),
          _field('CV URL', _cvUrlCtrl, 'https://...'),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    const options = [
      ('', 'Hide'),
      ('available', 'Available'),
      ('open', 'Open to opportunities'),
      ('unavailable', 'Currently engaged'),
    ];
    return _card(
      'Availability',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shown as a colored pill at the top of your hero section. Recruiters use this to pre-screen.',
            style: TextStyle(
                fontSize: 12, color: DashboardColors.mutedForeground),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((o) {
              final selected = _availabilityStatus == o.$1;
              return ChoiceChip(
                label: Text(o.$2),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _availabilityStatus = o.$1),
                selectedColor:
                    DashboardColors.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: selected ? DashboardColors.primary : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
                side: BorderSide(
                  color: selected
                      ? DashboardColors.primary
                      : DashboardColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _field(
            'Custom note (optional)',
            _availabilityNoteCtrl,
            'e.g. Open to remote Flutter roles — EU/UAE',
          ),
        ],
      ),
    );
  }

  Widget _contactInfoCard() {
    return _card(
      'Contact Information',
      LayoutBuilder(
        builder: (context, constraints) {
          final cols = constraints.maxWidth >= 600 ? 2 : 1;
          final fields = [
            _fieldWithIcon(Icons.mail_outline, 'Email', _emailCtrl, 'your@email.com'),
            _fieldWithIcon(Icons.phone_outlined, 'Phone', _phoneCtrl, '+1 555 123-4567'),
            _fieldWithIcon(Icons.location_on_outlined, 'Location', _locationCtrl, 'City, Country'),
          ];
          if (cols == 2) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: fields.map((f) => SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: f,
                  )).toList(),
            );
          }
          return Column(
            children: fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: f,
                )).toList(),
          );
        },
      ),
    );
  }

  Widget _socialLinksCard() {
    return _card(
      'Social Links',
      StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
        stream: FirestoreService.collectionStreamWithIds('social_links'),
        builder: (context, snap) {
          final links = snap.data ?? [];
          return Column(
            children: [
              ...links.map((e) {
                final id = e.key;
                final d = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(mapIcon(d['icon']), size: 20, color: DashboardColors.mutedForeground),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InlineSocialEditor(id: id, data: d),
                      ),
                    ],
                  ),
                );
              }),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final count = await FirestoreService.collectionCount('social_links');
                    await FirestoreService.addDocument('social_links', {
                      'icon': 'link',
                      'url': '',
                      'order': count,
                    });
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add social link: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Social Link'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, maxLines: maxLines,
            decoration: InputDecoration(hintText: hint)),
      ],
    );
  }

  Widget _fieldWithIcon(IconData icon, String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: DashboardColors.mutedForeground),
          ),
        ),
      ],
    );
  }
}

class _InlineSocialEditor extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const _InlineSocialEditor({required this.id, required this.data});

  @override
  State<_InlineSocialEditor> createState() => _InlineSocialEditorState();
}

class _InlineSocialEditorState extends State<_InlineSocialEditor> {
  late final TextEditingController _iconCtrl;
  late final TextEditingController _urlCtrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _iconCtrl = TextEditingController(text: widget.data['icon'] ?? '');
    _urlCtrl = TextEditingController(text: widget.data['url'] ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _iconCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: TextField(
            controller: _iconCtrl,
            decoration: const InputDecoration(hintText: 'icon name', isDense: true),
            onChanged: (_) => _debouncedSave(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(hintText: 'URL', isDense: true),
            onChanged: (_) => _debouncedSave(),
          ),
        ),
        IconButton(
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline, size: 18, color: DashboardColors.destructive),
          splashRadius: 18,
        ),
      ],
    );
  }

  void _debouncedSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _save);
  }

  void _save() {
    FirestoreService.updateDocument('social_links', widget.id, {
      'icon': _iconCtrl.text.trim(),
      'url': _urlCtrl.text.trim(),
      'order': widget.data['order'] ?? 0,
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Social Link'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirestoreService.deleteDocument('social_links', widget.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete link: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: DashboardColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
