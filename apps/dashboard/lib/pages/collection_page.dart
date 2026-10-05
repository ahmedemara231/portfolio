import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../widgets/record_editor.dart';

class CollectionPage extends StatefulWidget {
  final ContentSchema schema;
  final bool featuredOnly;
  const CollectionPage({
    super.key,
    required this.schema,
    this.featuredOnly = false,
  });
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final search = TextEditingController();
  String status = 'All';
  bool busy = false;
  late Stream<List<MapEntry<String, Map<String, dynamic>>>> stream =
      FirestoreService.collectionStreamWithIds(widget.schema.collection);
  @override
  void didUpdateWidget(CollectionPage old) {
    super.didUpdateWidget(old);
    if (old.schema.collection != widget.schema.collection) {
      stream = FirestoreService.collectionStreamWithIds(
        widget.schema.collection,
      );
      search.clear();
      status = 'All';
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> edit([MapEntry<String, Map<String, dynamic>>? entry]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordEditor(
          schema: widget.schema,
          id: entry?.key,
          initial: entry?.value ?? {},
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> reorder(
    List<MapEntry<String, Map<String, dynamic>>> entries,
    int index,
    int delta,
  ) async {
    final ids = entries.map((e) => e.key).toList();
    final id = ids.removeAt(index);
    ids.insert(index + delta, id);
    setState(() => busy = true);
    try {
      await FirestoreService.reorder(
        widget.schema.collection,
        ids,
        field: widget.featuredOnly ? 'featuredOrder' : 'order',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Display order saved.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the order. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> feature(MapEntry<String, Map<String, dynamic>> entry) async {
    setState(() => busy = true);
    try {
      await FirestoreService.updateDocument('projects', entry.key, {
        'featured': entry.value['featured'] != true,
        'featuredOrder':
            entry.value['featuredOrder'] ?? entry.value['order'] ?? 0,
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Featured selection could not be saved.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> delete(MapEntry<String, Map<String, dynamic>> entry) async {
    final confirmed = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${widget.schema.singular}?'),
        content: Text(
          '“${entry.value[widget.schema.nameKey] ?? ''}” will be removed from the collection and public site. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Design.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete entry'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    try {
      await FirestoreService.deleteDocument(
        widget.schema.collection,
        entry.key,
      );
      await FirestoreService.logActivity(
        action: 'deleted',
        entity: widget.schema.singular,
        target: (entry.value[widget.schema.nameKey] ?? '').toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Entry deleted.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete this entry. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void preview(MapEntry<String, Map<String, dynamic>> e) => showDialog(
    useRootNavigator: false,
    context: context,
    builder: (ctx) => ContentDialog(
      label: 'Project preview',
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Private project preview',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Close preview',
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ProjectDetail(
              project: ProjectModel.fromMap(e.value, e.key),
              preview: true,
            ),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 20,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Portfolio content'),
                const SizedBox(height: 10),
                Text(
                  widget.featuredOnly ? 'Featured work' : widget.schema.title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
              ],
            ),
            if (!widget.featuredOnly)
              FilledButton.icon(
                onPressed: busy ? null : () => edit(),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add ${widget.schema.singular}'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.featuredOnly
              ? 'The first four published entries lead the portfolio. Use the arrows to change their order.'
              : widget.schema.description,
          style: const TextStyle(color: Design.muted, height: 1.7),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, c) {
            final query = TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Search entries',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            );
            final filter = DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Visibility'),
              items: [
                'All',
                'Published',
                'Draft',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (s) => setState(() => status = s ?? 'All'),
            );
            return c.maxWidth < 550
                ? Column(children: [query, const SizedBox(height: 16), filter])
                : Row(
                    children: [
                      Expanded(child: query),
                      const SizedBox(width: 16),
                      SizedBox(width: 180, child: filter),
                    ],
                  );
          },
        ),
        const SizedBox(height: 28),
        StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
          stream: stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return StateMessage(
                title: 'Could not load content',
                message: 'Check your connection and administrator access.',
                action: OutlinedButton(
                  onPressed: () => setState(
                    () => stream = FirestoreService.collectionStreamWithIds(
                      widget.schema.collection,
                    ),
                  ),
                  child: const Text('Try again'),
                ),
              );
            }
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            var all = snap.data!;
            if (widget.featuredOnly) {
              all = all.where((e) => e.value['featured'] == true).toList()
                ..sort(
                  (a, b) => ((a.value['featuredOrder'] as num?) ?? 0).compareTo(
                    (b.value['featuredOrder'] as num?) ?? 0,
                  ),
                );
            }
            final q = search.text.toLowerCase();
            final filtered = all
                .where(
                  (e) =>
                      (e.value[widget.schema.nameKey] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(q) &&
                      (status == 'All' ||
                          (FirestoreService.isPublished(e.value)
                                  ? 'Published'
                                  : 'Draft') ==
                              status),
                )
                .toList();
            if (filtered.isEmpty) {
              return StateMessage(
                title: all.isEmpty
                    ? 'Your collection starts here.'
                    : 'No matching entries.',
                message: widget.featuredOnly
                    ? 'Feature projects from the Projects page to add them here.'
                    : 'Add an entry or adjust your search.',
                action: widget.featuredOnly
                    ? null
                    : OutlinedButton(
                        onPressed: () => edit(),
                        child: Text('Add ${widget.schema.singular}'),
                      ),
              );
            }
            final canOrder = q.isEmpty && status == 'All';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${filtered.length} entries${canOrder ? ' · Arrows save display order immediately.' : ' · Clear filters to change order.'}',
                  style: const TextStyle(fontSize: 12, color: Design.muted),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < filtered.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Design.surface,
                      border: Border.all(color: Design.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final entry = filtered[i];
                        final p = entry.value;
                        final isProject =
                            widget.schema.collection == 'projects';
                        final detail = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  (p[widget.schema.nameKey] ?? 'Untitled')
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                StatusPill(
                                  FirestoreService.isPublished(p)
                                      ? 'Published'
                                      : 'Draft',
                                  active: FirestoreService.isPublished(p),
                                ),
                                if (p['featured'] == true)
                                  const Eyebrow('Featured'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              (p['description'] ??
                                      p['category'] ??
                                      p['label'] ??
                                      p['title'] ??
                                      '')
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Design.muted,
                                fontSize: 13,
                                height: 1.7,
                              ),
                            ),
                            if (isProject) ...[
                              const SizedBox(height: 8),
                              SelectableText(
                                'ID: ${entry.key}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Design.muted,
                                ),
                              ),
                            ],
                          ],
                        );
                        final actions = Wrap(
                          spacing: 2,
                          runSpacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Move up',
                              onPressed: busy || !canOrder || i == 0
                                  ? null
                                  : () => reorder(all, i, -1),
                              icon: const Icon(Icons.arrow_upward, size: 18),
                            ),
                            IconButton(
                              tooltip: 'Move down',
                              onPressed:
                                  busy || !canOrder || i == all.length - 1
                                  ? null
                                  : () => reorder(all, i, 1),
                              icon: const Icon(Icons.arrow_downward, size: 18),
                            ),
                            if (isProject)
                              IconButton(
                                tooltip: p['featured'] == true
                                    ? 'Remove from featured'
                                    : 'Feature project',
                                onPressed: busy ? null : () => feature(entry),
                                icon: Icon(
                                  p['featured'] == true
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Design.accent,
                                  size: 20,
                                ),
                              ),
                            if (isProject)
                              IconButton(
                                tooltip: 'Preview ${p['title']}',
                                onPressed: () => preview(entry),
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 19,
                                ),
                              ),
                            IconButton(
                              tooltip: 'Edit entry',
                              onPressed: busy ? null : () => edit(entry),
                              icon: const Icon(Icons.edit_outlined, size: 19),
                            ),
                            IconButton(
                              tooltip: 'Delete entry',
                              onPressed: busy ? null : () => delete(entry),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Design.error,
                                size: 19,
                              ),
                            ),
                          ],
                        );
                        return c.maxWidth >= 850
                            ? Row(
                                children: [
                                  Expanded(child: detail),
                                  const SizedBox(width: 16),
                                  actions,
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  detail,
                                  const SizedBox(height: 14),
                                  actions,
                                ],
                              );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
