import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../theme/dashboard_theme.dart';


class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  String _search = '';

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
                    const Text('Projects',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Manage your portfolio projects',
                        style: TextStyle(color: DashboardColors.mutedForeground)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showProjectModal(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Project'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search projects...',
              prefixIcon: const Icon(Icons.search, color: DashboardColors.mutedForeground),
              fillColor: DashboardColors.card,
            ),
          ),
          const SizedBox(height: 24),

          // Projects Grid
          StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
            stream: FirestoreService.collectionStreamWithIds('projects'),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snap.data ?? [];
              final filtered = all.where((e) {
                final p = e.value;
                final q = _search.toLowerCase();
                return q.isEmpty ||
                    (p['title'] ?? '').toString().toLowerCase().contains(q) ||
                    (p['description'] ?? '').toString().toLowerCase().contains(q);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: Text('No projects found',
                        style: TextStyle(color: DashboardColors.mutedForeground)),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth >= 1000
                      ? 3
                      : constraints.maxWidth >= 600
                          ? 2
                          : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _ProjectCard(id: filtered[i].key, data: filtered[i].value),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProjectModal(BuildContext context, [String? docId, Map<String, dynamic>? data]) {
    showDialog(
      context: context,
      builder: (_) => _ProjectFormModal(docId: docId, data: data),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  const _ProjectCard({required this.id, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? '';
    final desc = data['description'] ?? '';
    final tags = List<String>.from(data['tags'] ?? []);
    final downloads = data['downloads'] ?? '';
    final rating = (data['rating'] ?? 0).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DashboardColors.primary.withValues(alpha: 0.2),
                  DashboardColors.accent,
                ],
              ),
            ),
            child: Center(
              child: Text(title.isNotEmpty ? title[0] : '?',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: DashboardColors.primary.withValues(alpha: 0.3))),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 13, color: DashboardColors.mutedForeground),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.take(3).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DashboardColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t,
                            style: const TextStyle(
                                fontSize: 11, color: DashboardColors.primary)),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  // Stats
                  Row(
                    children: [
                      const Icon(Icons.download_outlined, size: 16,
                          color: DashboardColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(downloads.isEmpty ? '-' : downloads,
                          style: const TextStyle(
                              fontSize: 12, color: DashboardColors.mutedForeground)),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Color(0xFFFACC15)),
                      const SizedBox(width: 4),
                      Text(rating > 0 ? rating.toStringAsFixed(1) : '-',
                          style: const TextStyle(
                              fontSize: 12, color: DashboardColors.mutedForeground)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => _ProjectFormModal(docId: id, data: data),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _confirmDelete(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          side: const BorderSide(color: DashboardColors.destructive),
                          foregroundColor: DashboardColors.destructive,
                        ),
                        child: const Icon(Icons.delete_outline, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
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
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${data['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              FirestoreService.deleteDocument('projects', id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: DashboardColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ProjectFormModal extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  const _ProjectFormModal({this.docId, this.data});

  @override
  State<_ProjectFormModal> createState() => _ProjectFormModalState();
}

class _ProjectFormModalState extends State<_ProjectFormModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _downloadsCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _codeUrlCtrl;
  late final TextEditingController _liveUrlCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _tagCtrl;
  late List<String> _tags;

  bool get isEditing => widget.docId != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data ?? {};
    _titleCtrl = TextEditingController(text: d['title'] ?? '');
    _descCtrl = TextEditingController(text: d['description'] ?? '');
    _downloadsCtrl = TextEditingController(text: d['downloads'] ?? '');
    _ratingCtrl = TextEditingController(
        text: (d['rating'] ?? 0).toDouble() > 0 ? d['rating'].toString() : '');
    _codeUrlCtrl = TextEditingController(text: d['codeUrl'] ?? '');
    _liveUrlCtrl = TextEditingController(text: d['liveUrl'] ?? '');
    _imageCtrl = TextEditingController(text: d['image'] ?? '');
    _tagCtrl = TextEditingController();
    _tags = List<String>.from(d['tags'] ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _downloadsCtrl.dispose();
    _ratingCtrl.dispose();
    _codeUrlCtrl.dispose();
    _liveUrlCtrl.dispose();
    _imageCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final t = _tagCtrl.text.trim();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() => _tags.add(t));
      _tagCtrl.clear();
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final map = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'downloads': _downloadsCtrl.text.trim(),
      'rating': double.tryParse(_ratingCtrl.text) ?? 0,
      'codeUrl': _codeUrlCtrl.text.trim(),
      'liveUrl': _liveUrlCtrl.text.trim(),
      'image': _imageCtrl.text.trim(),
      'tags': _tags,
      'tagColor': '',
      'order': widget.data?['order'] ?? 0,
    };
    if (isEditing) {
      await FirestoreService.updateDocument('projects', widget.docId!, map);
    } else {
      // Get count for order
      final count = await FirestoreService.collectionCount('projects');
      map['order'] = count;
      await FirestoreService.addDocument('projects', map);
    }
    if (mounted) Navigator.pop(context);
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
                  Text(isEditing ? 'Edit Project' : 'Add New Project',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),

              // Image URL
              _label('Cover Image URL'),
              TextField(controller: _imageCtrl,
                  decoration: const InputDecoration(hintText: 'https://...')),
              const SizedBox(height: 16),

              // Title
              _label('Project Title *'),
              TextField(controller: _titleCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. E-Commerce App')),
              const SizedBox(height: 16),

              // Description
              _label('Description'),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Briefly describe the project...'),
              ),
              const SizedBox(height: 16),

              // Rating & Downloads
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Rating (0-5)'),
                        TextField(controller: _ratingCtrl,
                            decoration: const InputDecoration(hintText: '4.5'),
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Downloads'),
                        TextField(controller: _downloadsCtrl,
                            decoration: const InputDecoration(hintText: '50K+')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tags
              _label('Tech Tags'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagCtrl,
                      decoration: const InputDecoration(hintText: 'e.g. Flutter'),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addTag, child: const Text('Add')),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tags.map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _tags.remove(t)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                ),
              ],
              const SizedBox(height: 16),

              // Links
              Text('STORE & REPOSITORY LINKS',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DashboardColors.mutedForeground,
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Code URL'),
                        TextField(controller: _codeUrlCtrl,
                            decoration: const InputDecoration(hintText: 'https://github.com/...')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Live URL'),
                        TextField(controller: _liveUrlCtrl,
                            decoration: const InputDecoration(hintText: 'https://...')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Actions
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _titleCtrl.text.trim().isEmpty ? null : _save,
                      child: Text(isEditing ? 'Save Changes' : 'Add Project'),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      );
}
