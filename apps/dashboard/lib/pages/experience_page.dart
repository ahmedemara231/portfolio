import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../theme/dashboard_theme.dart';

class ExperiencePage extends StatelessWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Work Experience',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Manage your professional work history',
                        style: TextStyle(color: DashboardColors.mutedForeground)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showModal(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Experience'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Experience List
          StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
            stream: FirestoreService.collectionStreamWithIds('experiences'),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final experiences = snap.data ?? [];
              return Column(
                children: experiences
                    .map((e) => _ExperienceCard(
                          id: e.key,
                          data: e.value,
                          onEdit: () => _showModal(context, e.key, e.value),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Career Summary
          _CareerSummary(),
        ],
      ),
    );
  }

  void _showModal(BuildContext context, [String? docId, Map<String, dynamic>? data]) {
    showDialog(
      context: context,
      builder: (_) => _ExperienceFormModal(docId: docId, data: data),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  const _ExperienceCard({required this.id, required this.data, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? '';
    final company = data['company'] ?? '';
    final location = data['location'] ?? '';
    final period = data['period'] ?? '';
    final duration = data['duration'] ?? '';
    final desc = data['description'] ?? '';
    final achievements = List<String>.from(data['achievements'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DashboardColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline, color: DashboardColors.primary),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline, size: 18,
                          color: DashboardColors.destructive),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                Text(company,
                    style: const TextStyle(color: DashboardColors.mutedForeground)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (period.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14,
                              color: DashboardColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(period,
                              style: const TextStyle(
                                  fontSize: 13, color: DashboardColors.mutedForeground)),
                        ],
                      ),
                    if (location.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14,
                              color: DashboardColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(location,
                              style: const TextStyle(
                                  fontSize: 13, color: DashboardColors.mutedForeground)),
                        ],
                      ),
                    if (duration.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: DashboardColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(duration,
                            style: const TextStyle(
                                fontSize: 12, color: DashboardColors.primary)),
                      ),
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 13, color: DashboardColors.mutedForeground)),
                ],
                if (achievements.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Key Achievements:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...achievements.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('  ',
                                style: TextStyle(color: DashboardColors.primary)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(a, style: const TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Experience'),
        content: Text('Delete "${ data['title'] }" at "${data['company']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirestoreService.deleteDocument('experiences', id);
                await FirestoreService.logActivity(
                  action: 'deleted',
                  entity: 'experience',
                  target: data['title'] ?? '',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete experience: $e')),
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

class _CareerSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
      stream: FirestoreService.collectionStreamWithIds('experience_stats'),
      builder: (context, snap) {
        final stats = snap.data ?? [];
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DashboardColors.primary.withValues(alpha: 0.1),
                DashboardColors.accent,
              ],
            ),
            border: Border.all(color: DashboardColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text('Career Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth >= 600 ? 4 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: stats.length,
                    itemBuilder: (context, i) {
                      final s = stats[i].value;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['value'] ?? '',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: DashboardColors.primary)),
                          const SizedBox(height: 4),
                          Text(s['label'] ?? '',
                              style: const TextStyle(
                                  fontSize: 13, color: DashboardColors.mutedForeground)),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Experience Form Modal ──
class _ExperienceFormModal extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  const _ExperienceFormModal({this.docId, this.data});

  @override
  State<_ExperienceFormModal> createState() => _ExperienceFormModalState();
}

class _ExperienceFormModalState extends State<_ExperienceFormModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _periodCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _achievementCtrl;
  late final TextEditingController _color1Ctrl;
  late final TextEditingController _color2Ctrl;
  late List<String> _achievements;

  bool get isEditing => widget.docId != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data ?? {};
    _titleCtrl = TextEditingController(text: d['title'] ?? '');
    _companyCtrl = TextEditingController(text: d['company'] ?? '');
    _locationCtrl = TextEditingController(text: d['location'] ?? '');
    _periodCtrl = TextEditingController(text: d['period'] ?? '');
    _durationCtrl = TextEditingController(text: d['duration'] ?? '');
    _descCtrl = TextEditingController(text: d['description'] ?? '');
    _achievementCtrl = TextEditingController();
    _color1Ctrl = TextEditingController(text: d['gradientColor1'] ?? '');
    _color2Ctrl = TextEditingController(text: d['gradientColor2'] ?? '');
    _achievements = List<String>.from(d['achievements'] ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _periodCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    _achievementCtrl.dispose();
    _color1Ctrl.dispose();
    _color2Ctrl.dispose();
    super.dispose();
  }

  void _addAchievement() {
    final t = _achievementCtrl.text.trim();
    if (t.isNotEmpty) {
      setState(() => _achievements.add(t));
      _achievementCtrl.clear();
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty || _companyCtrl.text.trim().isEmpty) return;
    try {
      final title = _titleCtrl.text.trim();
      final map = {
        'title': title,
        'company': _companyCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'period': _periodCtrl.text.trim(),
        'duration': _durationCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'achievements': _achievements,
        'gradientColor1': _color1Ctrl.text.trim(),
        'gradientColor2': _color2Ctrl.text.trim(),
        'order': widget.data?['order'] ?? 0,
      };
      if (isEditing) {
        await FirestoreService.updateDocument('experiences', widget.docId!, map);
        await FirestoreService.logActivity(
          action: 'updated', entity: 'experience', target: title);
      } else {
        final count = await FirestoreService.collectionCount('experiences');
        map['order'] = count;
        await FirestoreService.addDocument('experiences', map);
        await FirestoreService.logActivity(
          action: 'added', entity: 'experience', target: title);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save experience: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEditing ? 'Edit Experience' : 'Add Work Experience',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),

              // Title & Company
              Row(
                children: [
                  Expanded(child: _field('Job Title *', _titleCtrl, 'e.g. Senior Flutter Developer')),
                  const SizedBox(width: 16),
                  Expanded(child: _field('Company *', _companyCtrl, 'e.g. Tech Solutions Inc.')),
                ],
              ),
              const SizedBox(height: 16),

              // Location & Period
              Row(
                children: [
                  Expanded(child: _field('Location', _locationCtrl, 'e.g. San Francisco, CA')),
                  const SizedBox(width: 16),
                  Expanded(child: _field('Period', _periodCtrl, 'e.g. 2022 - Present')),
                ],
              ),
              const SizedBox(height: 16),

              // Duration
              _field('Duration', _durationCtrl, 'e.g. 2 years'),
              const SizedBox(height: 16),

              // Description
              _field('Role Description', _descCtrl, 'Describe your responsibilities...', maxLines: 3),
              const SizedBox(height: 16),

              // Achievements
              const Text('Key Achievements',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _achievementCtrl,
                      decoration: const InputDecoration(
                          hintText: 'e.g. Led development of 5+ apps'),
                      onSubmitted: (_) => _addAchievement(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addAchievement, child: const Text('Add')),
                ],
              ),
              if (_achievements.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...List.generate(_achievements.length, (i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DashboardColors.accent.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('  ',
                            style: TextStyle(color: DashboardColors.primary)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_achievements[i],
                                style: const TextStyle(fontSize: 13))),
                        IconButton(
                          onPressed: () => setState(() => _achievements.removeAt(i)),
                          icon: const Icon(Icons.close, size: 16),
                          splashRadius: 16,
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'Save Changes' : 'Add Experience'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
