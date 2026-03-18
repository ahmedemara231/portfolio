import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../theme/dashboard_theme.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTech = _tabCtrl.index == 0;

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
                    const Text('Skills',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Manage your technical and soft skills',
                        style: TextStyle(color: DashboardColors.mutedForeground)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (isTech) {
                    _showTechModal(context);
                  } else {
                    _showSoftModal(context);
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text('Add ${isTech ? "Technical" : "Soft"} Skill'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: TabBar(
              controller: _tabCtrl,
              labelColor: DashboardColors.primary,
              unselectedLabelColor: DashboardColors.mutedForeground,
              indicatorColor: DashboardColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.code, size: 18), text: 'Technical Skills'),
                Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Soft Skills'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content
          if (isTech) _TechnicalSkillsList(onEdit: _showTechModal),
          if (!isTech) _SoftSkillsList(onEdit: _showSoftModal),
          const SizedBox(height: 24),

          // Tools Section
          _ToolsSection(),
        ],
      ),
    );
  }

  void _showTechModal(BuildContext context, [String? docId, Map<String, dynamic>? data]) {
    showDialog(
      context: context,
      builder: (_) => _TechSkillModal(docId: docId, data: data),
    );
  }

  void _showSoftModal(BuildContext context, [String? docId, Map<String, dynamic>? data]) {
    showDialog(
      context: context,
      builder: (_) => _SoftSkillModal(docId: docId, data: data),
    );
  }
}

class _TechnicalSkillsList extends StatelessWidget {
  final void Function(BuildContext, [String?, Map<String, dynamic>?]) onEdit;
  const _TechnicalSkillsList({required this.onEdit});

  Color _levelColor(String level) {
    switch (level) {
      case 'Expert':
        return DashboardColors.green;
      case 'Advanced':
        return const Color(0xFF3B82F6);
      case 'Intermediate':
        return const Color(0xFFEAB308);
      default:
        return Colors.grey;
    }
  }

  Color _levelBg(String level) {
    switch (level) {
      case 'Expert':
        return DashboardColors.greenLight;
      case 'Advanced':
        return DashboardColors.blueLight;
      case 'Intermediate':
        return DashboardColors.yellowLight;
      default:
        return DashboardColors.accent;
    }
  }

  double _levelValue(String level) {
    switch (level) {
      case 'Expert':
        return 1.0;
      case 'Advanced':
        return 0.75;
      case 'Intermediate':
        return 0.5;
      default:
        return 0.25;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
      stream: FirestoreService.collectionStreamWithIds('technical_skills'),
      builder: (context, snap) {
        final skills = snap.data ?? [];
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth >= 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: skills.length,
              itemBuilder: (context, i) {
                final id = skills[i].key;
                final d = skills[i].value;
                final level = d['level'] ?? '';
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DashboardColors.card,
                    border: Border.all(color: DashboardColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(mapIcon(d['icon']), size: 24, color: DashboardColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(d['name'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          _HoverActions(
                            onEdit: () => onEdit(context, id, d),
                            onDelete: () async {
                              try {
                                await FirestoreService.deleteDocument('technical_skills', id);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete skill: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _levelBg(level),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(level,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                                color: _levelColor(level))),
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _levelValue(level),
                          minHeight: 6,
                          backgroundColor: DashboardColors.accent,
                          valueColor: AlwaysStoppedAnimation(_levelColor(level)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SoftSkillsList extends StatelessWidget {
  final void Function(BuildContext, [String?, Map<String, dynamic>?]) onEdit;
  const _SoftSkillsList({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
      stream: FirestoreService.collectionStreamWithIds('soft_skills'),
      builder: (context, snap) {
        final skills = snap.data ?? [];
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth >= 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3.0,
              ),
              itemCount: skills.length,
              itemBuilder: (context, i) {
                final id = skills[i].key;
                final d = skills[i].value;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DashboardColors.card,
                    border: Border.all(color: DashboardColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(d['name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          _HoverActions(
                            onEdit: () => onEdit(context, id, d),
                            onDelete: () async {
                              try {
                                await FirestoreService.deleteDocument('soft_skills', id);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete skill: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(d['description'] ?? '',
                          style: const TextStyle(
                              fontSize: 13, color: DashboardColors.mutedForeground),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ToolsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Technologies & Tools',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const _ToolsEditModal(),
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
            stream: FirestoreService.collectionStreamWithIds('tools'),
            builder: (context, snap) {
              final tools = snap.data ?? [];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tools.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DashboardColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(e.value['name'] ?? '',
                        style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HoverActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _HoverActions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          splashRadius: 20,
          tooltip: 'Edit',
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete'),
                content: const Text('Are you sure?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      onDelete();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: DashboardColors.destructive),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.delete_outline, size: 18,
              color: DashboardColors.destructive),
          splashRadius: 20,
          tooltip: 'Delete',
        ),
      ],
    );
  }
}

// ── Tech Skill Modal ──
class _TechSkillModal extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  const _TechSkillModal({this.docId, this.data});

  @override
  State<_TechSkillModal> createState() => _TechSkillModalState();
}

class _TechSkillModalState extends State<_TechSkillModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iconCtrl;
  late String _level;
  bool get isEditing => widget.docId != null;

  static const _levels = ['Expert', 'Advanced', 'Intermediate', 'Beginner'];

  @override
  void initState() {
    super.initState();
    final d = widget.data ?? {};
    _nameCtrl = TextEditingController(text: d['name'] ?? '');
    _iconCtrl = TextEditingController(text: d['icon'] ?? '');
    _level = d['level'] ?? 'Intermediate';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    try {
      final map = {
        'name': _nameCtrl.text.trim(),
        'icon': _iconCtrl.text.trim(),
        'level': _level,
        'order': widget.data?['order'] ?? 0,
      };
      if (isEditing) {
        await FirestoreService.updateDocument('technical_skills', widget.docId!, map);
      } else {
        final count = await FirestoreService.collectionCount('technical_skills');
        map['order'] = count;
        await FirestoreService.addDocument('technical_skills', map);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save skill: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEditing ? 'Edit Technical Skill' : 'Add Technical Skill',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Icon & Name
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(controller: _iconCtrl,
                            decoration: const InputDecoration(hintText: 'code')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Skill Name *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(controller: _nameCtrl,
                            decoration: const InputDecoration(hintText: 'e.g. Flutter & Dart')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Level
              const Text('Proficiency Level',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _levels.map((lvl) {
                  final selected = _level == lvl;
                  return ChoiceChip(
                    label: Text(lvl),
                    selected: selected,
                    onSelected: (_) => setState(() => _level = lvl),
                    selectedColor: DashboardColors.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: selected ? DashboardColors.primary : null,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                    side: BorderSide(
                      color: selected ? DashboardColors.primary : DashboardColors.border,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
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
                      onPressed: _save,
                      child: Text(isEditing ? 'Save Changes' : 'Add Skill'),
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
}

// ── Soft Skill Modal ──
class _SoftSkillModal extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  const _SoftSkillModal({this.docId, this.data});

  @override
  State<_SoftSkillModal> createState() => _SoftSkillModalState();
}

class _SoftSkillModalState extends State<_SoftSkillModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _iconCtrl;
  bool get isEditing => widget.docId != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data ?? {};
    _nameCtrl = TextEditingController(text: d['name'] ?? '');
    _descCtrl = TextEditingController(text: d['description'] ?? '');
    _iconCtrl = TextEditingController(text: d['icon'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    try {
      final map = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'icon': _iconCtrl.text.trim(),
        'order': widget.data?['order'] ?? 0,
      };
      if (isEditing) {
        await FirestoreService.updateDocument('soft_skills', widget.docId!, map);
      } else {
        final count = await FirestoreService.collectionCount('soft_skills');
        map['order'] = count;
        await FirestoreService.addDocument('soft_skills', map);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save skill: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEditing ? 'Edit Soft Skill' : 'Add Soft Skill',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Skill Name *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(controller: _nameCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. Communication')),
              const SizedBox(height: 16),
              const Text('Icon',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(controller: _iconCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. chat_bubble_outline')),
              const SizedBox(height: 16),
              const Text('Description',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Describe this skill...'),
              ),
              const SizedBox(height: 24),
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
                      onPressed: _save,
                      child: Text(isEditing ? 'Save Changes' : 'Add Skill'),
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
}

// ── Tools Edit Modal ──
class _ToolsEditModal extends StatefulWidget {
  const _ToolsEditModal();

  @override
  State<_ToolsEditModal> createState() => _ToolsEditModalState();
}

class _ToolsEditModalState extends State<_ToolsEditModal> {
  final _ctrl = TextEditingController();

  Future<void> _addTool() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    try {
      final count = await FirestoreService.collectionCount('tools');
      await FirestoreService.addDocument('tools', {'name': name, 'order': count});
      _ctrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add tool: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Tools',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'New tool name'),
                      onSubmitted: (_) => _addTool(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addTool, child: const Text('Add')),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
                  stream: FirestoreService.collectionStreamWithIds('tools'),
                  builder: (context, snap) {
                    final tools = snap.data ?? [];
                    return ListView.builder(
                      itemCount: tools.length,
                      itemBuilder: (context, i) {
                        final id = tools[i].key;
                        final name = tools[i].value['name'] ?? '';
                        return ListTile(
                          dense: true,
                          title: Text(name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18,
                                color: DashboardColors.destructive),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Tool'),
                                  content: Text('Delete "$name"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        try {
                                          await FirestoreService.deleteDocument('tools', id);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to delete tool: $e')),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: DashboardColors.destructive),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
