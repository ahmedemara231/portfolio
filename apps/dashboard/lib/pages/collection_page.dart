import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../widgets/record_editor.dart';
import '../widgets/studio_widgets.dart';

class CollectionPage extends StatefulWidget {
  final ContentSchema schema;
  final bool featuredOnly;
  final String initialStatus;
  final VoidCallback? onManageProjects;
  const CollectionPage({
    super.key,
    required this.schema,
    this.featuredOnly = false,
    this.initialStatus = 'All',
    this.onManageProjects,
  });
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final search = TextEditingController();
  String status = 'All';
  String category = 'All categories';
  bool busy = false;
  late Stream<List<MapEntry<String, Map<String, dynamic>>>> stream =
      FirestoreService.collectionStreamWithIds(widget.schema.collection);
  @override
  void initState() {
    super.initState();
    status = widget.initialStatus;
  }

  @override
  void didUpdateWidget(CollectionPage old) {
    super.didUpdateWidget(old);
    if (old.schema.collection != widget.schema.collection ||
        old.featuredOnly != widget.featuredOnly) {
      stream = FirestoreService.collectionStreamWithIds(
        widget.schema.collection,
      );
      search.clear();
      status = 'All';
      category = 'All categories';
    }
    if (old.initialStatus != widget.initialStatus) {
      status = widget.initialStatus;
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

  Future<bool> feature(MapEntry<String, Map<String, dynamic>> entry) async {
    if (busy) return false;
    setState(() => busy = true);
    try {
      final selected = entry.value['featured'] != true;
      final records = await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first;
      final positions = records
          .where((e) => e.value['featured'] == true)
          .map((e) => (e.value['featuredOrder'] as num?)?.toInt() ?? 0);
      final position = positions.isEmpty
          ? 0
          : positions.reduce((a, b) => a > b ? a : b) + 1;
      await FirestoreService.updateDocument('projects', entry.key, {
        'featured': selected,
        if (selected) 'featuredOrder': position,
      });
      await FirestoreService.logActivity(
        action: selected ? 'featured' : 'unfeatured',
        entity: 'project',
        target: (entry.value['title'] ?? '').toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selected
                  ? 'Added to featured work.'
                  : 'Removed from featured work.',
            ),
          ),
        );
      }
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Featured selection could not be saved.'),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> delete(MapEntry<String, Map<String, dynamic>> entry) async {
    final confirmed = await showContentDialog<bool>(
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

  void preview(MapEntry<String, Map<String, dynamic>> entry) =>
      showStudioProjectPreview(
        context,
        ProjectModel.fromMap(entry.value, entry.key),
      );

  void chooseProjects() => showContentDialog(
    useRootNavigator: false,
    context: context,
    builder: (_) => _FeaturedPicker(onToggle: feature),
  );

  String get sectionLabel => switch (widget.schema.collection) {
    'projects' => '01 / Selected work',
    'experiences' => '02 / Professional experience',
    'packages' => '03 / Open source',
    'technical_skills' => '04 / Technical capabilities',
    'education' => '05 / About & education',
    'social_links' => '06 / Contact',
    'stats' => 'Introduction / Credibility',
    _ => 'Existing portfolio content',
  };

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioPageHeader(
          eyebrow: sectionLabel,
          title: widget.featuredOnly ? 'Featured work' : widget.schema.title,
          description: widget.featuredOnly
              ? 'Curate the projects that introduce your work. The first four published selections appear on the home page.'
              : widget.schema.description,
          action: widget.featuredOnly
              ? FilledButton.icon(
                  onPressed: busy ? null : chooseProjects,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Choose projects'),
                )
              : FilledButton.icon(
                  onPressed: busy ? null : () => edit(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add ${widget.schema.singular}'),
                ),
        ),
        const SizedBox(height: 28),
        StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return StateMessage(
                title: 'Could not load content',
                message: 'Check your connection and Firebase permissions.',
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
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final records = snapshot.data!;
            final all = widget.featuredOnly
                ? (records.where((e) => e.value['featured'] == true).toList()
                    ..sort(
                      (a, b) => ((a.value['featuredOrder'] as num?) ?? 0)
                          .compareTo((b.value['featuredOrder'] as num?) ?? 0),
                    ))
                : records;
            final categories = [
              'All categories',
              ...records
                  .map((e) => (e.value['category'] ?? '').toString())
                  .where((c) => c.isNotEmpty)
                  .toSet(),
            ];
            final activeCategory = categories.contains(category)
                ? category
                : 'All categories';
            final query = search.text.trim().toLowerCase();
            final filtered = all.where((entry) {
              final value = entry.value;
              final searchable = [
                value[widget.schema.nameKey],
                value['description'],
                value['category'],
                value['title'],
                value['company'],
                value['subtitle'],
                ...(value['items'] as List? ?? []),
                ...(value['capabilities'] as List? ?? []),
              ].join(' ').toLowerCase();
              return searchable.contains(query) &&
                  (status == 'All' ||
                      (FirestoreService.isPublished(value)
                              ? 'Published'
                              : 'Draft') ==
                          status) &&
                  (activeCategory == 'All categories' ||
                      value['category'] == activeCategory);
            }).toList();
            final canOrder =
                query.isEmpty &&
                status == 'All' &&
                activeCategory == 'All categories';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.featuredOnly) ...[
                  lineupSummary(all),
                  const SizedBox(height: 24),
                ],
                filters(categories, activeCategory),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${filtered.length} entries',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      canOrder
                          ? 'Arrows save display order immediately.'
                          : 'Clear filters to change display order.',
                      style: Design.captionType,
                    ),
                    if (!canOrder)
                      TextButton(
                        onPressed: () => setState(() {
                          search.clear();
                          status = 'All';
                          category = 'All categories';
                        }),
                        child: const Text('Clear filters'),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  StateMessage(
                    title: all.isEmpty
                        ? 'Your collection starts here.'
                        : 'No matching entries.',
                    message: widget.featuredOnly
                        ? 'Choose projects to add to the home page lineup. Draft selections will stay private.'
                        : 'Add an entry or adjust your search and filters.',
                    action: OutlinedButton(
                      onPressed: widget.featuredOnly
                          ? chooseProjects
                          : () => edit(),
                      child: Text(
                        widget.featuredOnly
                            ? 'Choose projects'
                            : 'Add ${widget.schema.singular}',
                      ),
                    ),
                  ),
                for (var i = 0; i < filtered.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: entryCard(filtered[i], all, i, canOrder),
                  ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ],
    ),
  );

  Widget lineupSummary(List<MapEntry<String, Map<String, dynamic>>> entries) {
    final visible = entries
        .where((e) => FirestoreService.isPublished(e.value))
        .length;
    final drafts = entries.length - visible;
    return StudioPanel(
      color: Design.tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.star_outline, color: Design.accent),
              Text(
                '${visible > 4 ? 4 : visible} of 4 home page slots',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (drafts > 0)
                StatusPill(
                  '$drafts private ${drafts == 1 ? 'draft' : 'drafts'}',
                  active: false,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            visible > 4
                ? '${visible - 4} additional published selections follow the first four. Move a project up to bring it onto the home page.'
                : 'Choose projects for breadth of experience, then arrange the sequence with the arrows.',
            style: Design.captionType,
          ),
          if (widget.onManageProjects != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: widget.onManageProjects,
              icon: const Icon(Icons.folder_outlined, size: 16),
              label: const Text('Manage all projects'),
            ),
          ],
        ],
      ),
    );
  }

  Widget filters(List<String> categories, String activeCategory) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LayoutBuilder(
        builder: (context, c) {
          final input = TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Search entries',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          );
          final filter = DropdownButtonFormField<String>(
            key: ValueKey(activeCategory),
            initialValue: activeCategory,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Product category'),
            items: categories
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => category = value ?? 'All categories'),
          );
          if (widget.schema.collection != 'projects' || widget.featuredOnly) {
            return input;
          }
          if (c.maxWidth < 600) {
            return Column(
              children: [input, const SizedBox(height: 14), filter],
            );
          }
          return Row(
            children: [
              Expanded(child: input),
              const SizedBox(width: 16),
              SizedBox(width: 230, child: filter),
            ],
          );
        },
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in ['All', 'Published', 'Draft'])
            ChoiceChip(
              label: Text(option),
              selected: status == option,
              onSelected: (_) => setState(() => status = option),
            ),
        ],
      ),
    ],
  );

  Widget entryCard(
    MapEntry<String, Map<String, dynamic>> entry,
    List<MapEntry<String, Map<String, dynamic>>> all,
    int index,
    bool canOrder,
  ) {
    final value = entry.value;
    final isProject = widget.schema.collection == 'projects';
    final project = isProject ? ProjectModel.fromMap(value, entry.key) : null;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isProject && project!.category.isNotEmpty) ...[
          Eyebrow(project.category, color: Design.muted),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              (value[widget.schema.nameKey] ?? 'Untitled').toString(),
              style: TextStyle(
                fontSize: isProject ? 25 : 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -.6,
              ),
            ),
            StatusPill(
              FirestoreService.isPublished(value) ? 'Published' : 'Draft',
              active: FirestoreService.isPublished(value),
            ),
            if (isProject && value['featured'] == true)
              const Icon(Icons.star, color: Design.accent, size: 18),
          ],
        ),
        const SizedBox(height: 12),
        summary(entry),
        if (isProject) ...[
          const SizedBox(height: 12),
          Text(
            '${project!.gallery.length} screenshots${project.googlePlayUrl.isNotEmpty ? ' · Google Play' : ''}${project.appStoreUrl.isNotEmpty ? ' · App Store' : ''}',
            style: Design.captionType.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 8),
          SelectableText(
            '/projects/${project.slug.isEmpty ? entry.key : project.slug}',
            style: Design.captionType.copyWith(
              color: Design.accent,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 12),
        actions(entry, all, index, canOrder),
      ],
    );
    return StudioPanel(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, c) {
          if (project == null) return details;
          final media = Semantics(
            button: true,
            label: 'Preview ${project.title} imagery',
            child: MotionSurface(
              borderRadius: BorderRadius.circular(Design.radius),
              onTap: () => preview(entry),
              child: ProjectMedia(project: project),
            ),
          );
          if (c.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [media, const SizedBox(height: 20), details],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: c.maxWidth >= 900 ? 220 : 170, child: media),
              const SizedBox(width: 24),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }

  Widget summary(MapEntry<String, Map<String, dynamic>> entry) {
    final value = entry.value;
    final collection = widget.schema.collection;
    final text = Text(
      (value['description'] ?? value['label'] ?? '').toString(),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Design.bodyType.copyWith(fontSize: 13),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (collection == 'experiences' || collection == 'education') ...[
          Text(
            '${value[collection == 'experiences' ? 'title' : 'institution'] ?? ''} · ${value['period'] ?? ''}',
            style: const TextStyle(
              fontSize: 13,
              color: Design.accent,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (collection == 'stats')
          Text(
            '${value['value'] ?? ''}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
        if (collection != 'stats' && collection != 'social_links') text,
        if (collection == 'technical_skills') ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in value['items'] as List? ?? [])
                Chip(
                  label: Text(
                    item.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
          if ((value['projectIds'] as List? ?? []).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${(value['projectIds'] as List).length} related projects',
              style: Design.captionType,
            ),
          ],
        ],
        if (collection == 'packages' &&
            (value['url'] ?? '').toString().isNotEmpty)
          TextButton.icon(
            onPressed: () => openLink(context, value['url'].toString()),
            icon: const Icon(Icons.north_east, size: 15),
            iconAlignment: IconAlignment.end,
            label: const Text('View on pub.dev'),
          ),
        if (collection == 'social_links') ...[
          SelectableText(
            (value['url'] ?? '').toString(),
            style: Design.captionType.copyWith(color: Design.accent),
          ),
          TextButton.icon(
            onPressed: () => openLink(context, (value['url'] ?? '').toString()),
            icon: const Icon(Icons.north_east, size: 15),
            iconAlignment: IconAlignment.end,
            label: const Text('Test link'),
          ),
        ],
      ],
    );
  }

  Widget actions(
    MapEntry<String, Map<String, dynamic>> entry,
    List<MapEntry<String, Map<String, dynamic>>> all,
    int index,
    bool canOrder,
  ) => Wrap(
    spacing: 2,
    runSpacing: 4,
    children: [
      IconButton(
        tooltip: 'Move up',
        onPressed: busy || !canOrder || index == 0
            ? null
            : () => reorder(all, index, -1),
        icon: const Icon(Icons.arrow_upward, size: 18),
      ),
      IconButton(
        tooltip: 'Move down',
        onPressed: busy || !canOrder || index == all.length - 1
            ? null
            : () => reorder(all, index, 1),
        icon: const Icon(Icons.arrow_downward, size: 18),
      ),
      if (widget.schema.collection == 'projects') ...[
        IconButton(
          tooltip: entry.value['featured'] == true
              ? 'Remove from featured'
              : 'Feature project',
          onPressed: busy ? null : () => feature(entry),
          icon: Icon(
            entry.value['featured'] == true ? Icons.star : Icons.star_border,
            color: Design.accent,
            size: 20,
          ),
        ),
        IconButton(
          tooltip: 'Preview ${entry.value['title']}',
          onPressed: () => preview(entry),
          icon: const Icon(Icons.visibility_outlined, size: 19),
        ),
      ],
      IconButton(
        tooltip: 'Edit entry',
        onPressed: busy ? null : () => edit(entry),
        icon: const Icon(Icons.edit_outlined, size: 19),
      ),
      IconButton(
        tooltip: 'Delete entry',
        onPressed: busy ? null : () => delete(entry),
        icon: const Icon(Icons.delete_outline, color: Design.error, size: 19),
      ),
    ],
  );
}

class _FeaturedPicker extends StatefulWidget {
  final Future<bool> Function(MapEntry<String, Map<String, dynamic>>) onToggle;
  const _FeaturedPicker({required this.onToggle});
  @override
  State<_FeaturedPicker> createState() => _FeaturedPickerState();
}

class _FeaturedPickerState extends State<_FeaturedPicker> {
  late final projects = FirestoreService.collectionStreamWithIds('projects');
  bool busy = false;
  String? error, feedback;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: ContentDialog(
      label: 'Choose featured projects',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Choose featured projects',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close selection',
                      onPressed: busy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Selections save immediately. Only the first four published projects appear on the home page.',
                  style: Design.captionType,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
                  stream: projects,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return const StateMessage(
                        title: 'Could not load projects',
                        message: 'Check your connection and try again.',
                      );
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: snap.data!
                          .map(
                            (entry) => CheckboxListTile(
                              value: entry.value['featured'] == true,
                              onChanged: busy
                                  ? null
                                  : (_) async {
                                      setState(() {
                                        busy = true;
                                        error = null;
                                        feedback = null;
                                      });
                                      final saved = await widget.onToggle(
                                        entry,
                                      );
                                      if (mounted) {
                                        setState(() {
                                          busy = false;
                                          error = saved
                                              ? null
                                              : 'Could not save this selection. Try again.';
                                          feedback = saved
                                              ? 'Selection saved.'
                                              : null;
                                        });
                                      }
                                    },
                              title: Text(
                                '${entry.value['title'] ?? 'Untitled'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${entry.value['category'] ?? ''} · ${FirestoreService.isPublished(entry.value) ? 'Published' : 'Private draft'}',
                                style: Design.captionType,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              if (error != null || feedback != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      error ?? feedback!,
                      style: TextStyle(
                        color: error != null ? Design.error : Design.accent,
                      ),
                    ),
                  ),
                ),
              if (busy) const LinearProgressIndicator(),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton(
                    onPressed: busy ? null : () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
