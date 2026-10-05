import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../services/media_upload.dart';
import 'studio_widgets.dart';
import 'project_reference_picker.dart';

class RecordEditor extends StatefulWidget {
  final ContentSchema schema;
  final String? id;
  final Map<String, dynamic> initial;
  final bool profile;
  final String? initialGroup;
  final List<Map<String, dynamic>> profileIndicators;
  const RecordEditor({
    super.key,
    required this.schema,
    this.id,
    this.initial = const {},
    this.profile = false,
    this.initialGroup,
    this.profileIndicators = const [],
  });
  @override
  State<RecordEditor> createState() => _RecordEditorState();
}

class _RecordEditorState extends State<RecordEditor> {
  final form = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  late Map<String, dynamic> values;
  late String recordId;
  bool dirty = false, saving = false, uploading = false;
  String? error;
  final scroll = ScrollController();
  final groupKeys = <String, GlobalKey>{};
  String selectedGroup = '';
  List<String> get groups {
    final available = widget.schema.fields.map((f) => f.group).toSet();
    if (widget.schema.collection == 'projects') {
      return [
        'The essentials',
        'Imagery',
        'Case study',
        'Links',
        'Visibility & selection',
        'Search & sharing',
        'Existing content',
      ].where(available.contains).toList();
    }
    return available.toList();
  }

  @override
  void initState() {
    super.initState();
    values = {...widget.initial};
    if (widget.profile &&
        !values.containsKey('professionalTitle') &&
        values.containsKey('badge')) {
      values['professionalTitle'] = values['badge'];
    }
    recordId = widget.id ?? 'entry-${DateTime.now().microsecondsSinceEpoch}';
    if (!widget.profile) {
      values.putIfAbsent(
        'status',
        () => widget.id == null ? 'draft' : 'published',
      );
    }
    for (final key in ['gallery', 'additionalLinks']) {
      if (values[key] is List) {
        values[key] = (values[key] as List)
            .asMap()
            .entries
            .map(
              (e) => {
                'mediaId': 'initial-${e.key}',
                ...Map<String, dynamic>.from(e.value as Map),
              },
            )
            .toList();
      }
    }
    for (final field in widget.schema.fields) {
      if ({
        FieldKind.toggle,
        FieldKind.gallery,
        FieldKind.links,
      }.contains(field.kind)) {
        continue;
      }
      final v = values[field.key];
      controllers[field.key] = TextEditingController(
        text: field.kind == FieldKind.lines
            ? (v as List? ?? []).join('\n')
            : v?.toString() ??
                  (field.key == 'status'
                      ? values['status'].toString()
                      : field.kind == FieldKind.number
                      ? '0'
                      : field.kind == FieldKind.select &&
                            field.choices.isNotEmpty
                      ? field.choices.first
                      : ''),
      );
      controllers[field.key]!.addListener(changed);
    }
    if (!widget.profile && !controllers.containsKey('status')) {
      controllers['status'] = TextEditingController(text: values['status']);
      controllers['status']!.addListener(changed);
    }
    for (final group in groups) {
      groupKeys[group] = GlobalKey();
    }
    selectedGroup = widget.initialGroup ?? groups.first;
    if (widget.initialGroup != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) jumpToGroup(widget.initialGroup!);
      });
    }
  }

  void jumpToGroup(String group) {
    final target = groupKeys[group]?.currentContext;
    if (target == null) return;
    setState(() => selectedGroup = group);
    Scrollable.ensureVisible(
      target,
      alignment: 0,
      duration: Design.reduced(context) ? Duration.zero : Design.motion,
      curve: Design.ease,
    );
  }

  void changed() {
    if (!mounted) return;
    setState(() => dirty = true);
    protectUnsavedChanges(true);
  }

  @override
  void dispose() {
    protectUnsavedChanges(false);
    scroll.dispose();
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> discard() async {
    if (saving || uploading) return false;
    if (!dirty) return true;
    return await showContentDialog<bool>(
          useRootNavigator: false,
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard unsaved changes?'),
            content: const Text(
              'Your saved content will stay as it is. Changes in this editor will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard changes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> close() async {
    if (await discard() && mounted) {
      FocusScope.of(context).unfocus();
      setState(() {
        dirty = false;
        saving = false;
      });
      protectUnsavedChanges(false);
      Navigator.pop(context);
    }
  }

  Map<String, dynamic> data() {
    final result = {...values};
    for (final f in widget.schema.fields) {
      if (f.kind == FieldKind.toggle) {
        result[f.key] = values[f.key] == true;
      } else if (f.kind == FieldKind.gallery || f.kind == FieldKind.links) {
        result[f.key] = (values[f.key] as List? ?? []).map((item) {
          final entry = Map<String, dynamic>.from(item as Map);
          for (final key in ['url', 'alt', 'label', 'thumbnail']) {
            if (entry[key] is String) {
              entry[key] = (entry[key] as String).trim();
            }
          }
          if ((entry['thumbnail'] ?? '').toString().isEmpty) {
            entry.remove('thumbnail');
          }
          return entry;
        }).toList();
      } else if (f.kind == FieldKind.lines) {
        result[f.key] = controllers[f.key]!.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (f.kind == FieldKind.number) {
        result[f.key] = int.tryParse(controllers[f.key]!.text) ?? 0;
      } else {
        result[f.key] = controllers[f.key]!.text.trim();
      }
    }
    if (result.containsKey('rating')) {
      result['rating'] = double.tryParse(result['rating'].toString()) ?? 0;
    }
    if (widget.profile && result['siteUrl'] is String) {
      result['siteUrl'] = (result['siteUrl'] as String).replaceFirst(
        RegExp(r'/+$'),
        '',
      );
    }
    if (!widget.profile) {
      result['status'] = controllers['status']!.text;
      result['order'] = widget.initial['order'] ?? values['order'] ?? 0;
    }
    if ({'experiences', 'education'}.contains(widget.schema.collection)) {
      final start = (result['startDate'] ?? '').toString(),
          end = (result['endDate'] ?? '').toString();
      if (start.isNotEmpty) {
        result['period'] =
            '${monthLabel(start)}–${result['current'] == true || end.isEmpty ? 'Present' : monthLabel(end)}';
      }
    }
    return result;
  }

  String monthLabel(String value) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final p = value.split('-');
    if (p.length != 2) return value;
    final month = int.tryParse(p[1]);
    return month == null || month < 1 || month > 12
        ? value
        : '${months[month - 1]} ${p[0]}';
  }

  Future<void> save() async {
    if (saving || uploading) return;
    final invalid = form.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      Scrollable.ensureVisible(
        invalid.first.context,
        alignment: .2,
        duration: Design.reduced(context) ? Duration.zero : Design.motion,
        curve: Design.ease,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final result = data();
    final start = (result['startDate'] ?? '').toString(),
        end = (result['endDate'] ?? '').toString();
    if (result['current'] != true &&
        start.isNotEmpty &&
        end.isNotEmpty &&
        start.compareTo(end) > 0) {
      setState(() => error = 'End month must follow the start month.');
      return;
    }
    for (final item in result['gallery'] as List? ?? []) {
      if ((item['url'] ?? '').toString().isEmpty ||
          (item['alt'] ?? '').toString().trim().isEmpty) {
        setState(
          () => error =
              'Each screenshot needs an image and a meaningful description.',
        );
        return;
      }
    }
    setState(() {
      saving = true;
      error = null;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      if (widget.schema.collection == 'projects') {
        final records = await FirestoreService.collectionStreamWithIds(
          'projects',
        ).first;
        if (records.any(
          (e) => e.key != recordId && e.value['slug'] == result['slug'],
        )) {
          throw StateError('Another project already uses this page address.');
        }
      }
      if (widget.profile) {
        await FirestoreService.updateProfile(result);
      } else {
        if (widget.id == null) {
          final entries = await FirestoreService.collectionStreamWithIds(
            widget.schema.collection,
          ).first;
          result['order'] = entries.isEmpty
              ? 0
              : entries
                        .map((e) => (e.value['order'] as num?)?.toInt() ?? 0)
                        .reduce((a, b) => a > b ? a : b) +
                    1;
        }
        await FirestoreService.setDocument(
          widget.schema.collection,
          recordId,
          result,
        );
      }
      await FirestoreService.logActivity(
        action: widget.id == null && !widget.profile ? 'added' : 'updated',
        entity: widget.schema.singular,
        target: (result[widget.schema.nameKey] ?? widget.schema.title)
            .toString(),
      );
      if (!mounted) return;
      setState(() {
        dirty = false;
        saving = false;
      });
      protectUnsavedChanges(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.schema.singular[0].toUpperCase()}${widget.schema.singular.substring(1)} saved.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e, stack) {
      assert(() {
        debugPrint('Content save failed: $e\n$stack');
        return true;
      }());
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  String? validate(ContentField field, String? input) {
    final value = input?.trim() ?? '';
    if (field.group == 'Existing content') {
      final initial = widget.initial[field.key];
      final original = field.kind == FieldKind.lines
          ? (initial as List? ?? []).join('\n')
          : initial?.toString() ?? '';
      if (value == original.trim()) return null;
    }
    if (field.required && value.isEmpty) return '${field.label} is required.';
    if (value.isEmpty) return null;
    if (field.key == 'title' && value.length > 160) {
      return 'Keep the title within 160 characters.';
    }
    if (field.key == 'slug' && value.length > 120) {
      return 'Keep the page address within 120 characters.';
    }
    if (field.key == 'slug' &&
        !RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value)) {
      return 'Use lowercase letters, numbers, and single hyphens.';
    }
    if (field.kind == FieldKind.email &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'Enter a valid email address.';
    }
    if (field.kind == FieldKind.month &&
        !RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value)) {
      return 'Use YYYY-MM, such as 2024-07.';
    }
    if (field.kind == FieldKind.number &&
        (int.tryParse(value) == null || int.parse(value) < 0)) {
      return 'Use a whole number of zero or more.';
    }
    if (field.kind == FieldKind.url) {
      if (value.startsWith('/') ||
          value.startsWith('packages/') ||
          value.startsWith('assets/') ||
          value.startsWith('data:application/pdf;base64,')) {
        if ({
          'cvUrl',
          'image',
          'heroImage',
          'socialImage',
        }.contains(field.key)) {
          return null;
        }
      }
      final uri = Uri.tryParse(value);
      if (uri == null ||
          !{'https', 'http', 'mailto', 'tel'}.contains(uri.scheme) ||
          ({'http', 'https'}.contains(uri.scheme) && uri.host.isEmpty)) {
        return 'Use a complete, valid URL.';
      }
      if (field.key == 'googlePlayUrl' && uri.host != 'play.google.com') {
        return 'Use a play.google.com store link.';
      }
      if (field.key == 'appStoreUrl' && uri.host != 'apps.apple.com') {
        return 'Use an apps.apple.com store link.';
      }
      if (field.key == 'siteUrl' &&
          (!{'https', 'http'}.contains(uri.scheme) ||
              uri.hasQuery ||
              uri.hasFragment ||
              (uri.path.isNotEmpty && uri.path != '/'))) {
        return 'Use the public site origin, with no query or fragment.';
      }
      if (field.key == 'url' &&
          widget.schema.collection == 'packages' &&
          uri.host != 'pub.dev') {
        return 'Use the package’s pub.dev URL.';
      }
    }
    return null;
  }

  Future<void> uploadCv() async {
    setState(() => uploading = true);
    try {
      final url = await MediaUpload.pickCv();
      if (url != null && mounted) controllers['cvUrl']!.text = url;
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  void preview() {
    if (widget.profile) {
      showStudioProfilePreview(
        context,
        data(),
        indicators: widget.profileIndicators,
        metadata: widget.schema.singular == 'metadata',
      );
    } else if (widget.schema.collection == 'projects') {
      showStudioProjectPreview(context, ProjectModel.fromMap(data(), recordId));
    } else {
      final value = data();
      showContentDialog(
        context: context,
        useRootNavigator: false,
        builder: (ctx) => ContentDialog(
          label: 'Entry preview',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Eyebrow('Private content preview'),
                        ),
                        IconButton(
                          tooltip: 'Close preview',
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${value[widget.schema.nameKey] ?? ''}',
                      style: Design.pageType,
                    ),
                    if (widget.schema.collection == 'stats')
                      Text(
                        '${value['value'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: Design.accent,
                        ),
                      ),
                    if (value['title'] != null &&
                        widget.schema.nameKey != 'title') ...[
                      const SizedBox(height: 10),
                      Text('${value['title']}', style: Design.groupType),
                    ],
                    if ((value['period'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${value['period']}',
                        style: Design.captionType.copyWith(
                          color: Design.accent,
                        ),
                      ),
                    ],
                    if ((value['institution'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('${value['institution']}', style: Design.groupType),
                    ],
                    if ((value['description'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('${value['description']}', style: Design.bodyType),
                    ],
                    for (final item in value['achievements'] as List? ?? [])
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('• $item', style: Design.bodyType),
                      ),
                    if ((value['items'] as List? ?? []).isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in value['items'] as List)
                            Chip(label: Text(item.toString())),
                        ],
                      ),
                    ],
                    if ((value['url'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SelectableText(
                        '${value['url']}',
                        style: Design.captionType.copyWith(
                          color: Design.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = saving
        ? 'Saving…'
        : dirty
        ? 'Unsaved changes'
        : widget.id == null && !widget.profile
        ? 'New draft'
        : 'Saved';
    return PopScope(
      canPop: !dirty && !saving && !uploading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close editor',
            onPressed: saving || uploading ? null : close,
            icon: const Icon(Icons.close),
          ),
          title: Text(
            widget.profile
                ? 'Edit ${widget.schema.singular}'
                : '${widget.id == null ? 'New' : 'Edit'} ${widget.schema.singular}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Semantics(
                liveRegion: true,
                child: MotionSwap(
                  child: StatusPill(
                    status,
                    key: ValueKey(status),
                    active:
                        !dirty &&
                        !saving &&
                        (widget.id != null || widget.profile),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: form,
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (constraints.maxWidth >= 1100) ...[
                  SizedBox(
                    width: 224,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(12, 0, 12, 18),
                              child: Eyebrow(
                                'In this editor',
                                color: Design.muted,
                              ),
                            ),
                            for (var index = 0; index < groups.length; index++)
                              ListTile(
                                selected: selectedGroup == groups[index],
                                selectedColor: Design.accent,
                                selectedTileColor: Design.tint,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                leading: Text(
                                  '${index + 1}'.padLeft(2, '0'),
                                  style: Design.captionType,
                                ),
                                title: Text(
                                  groups[index],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onTap: () => jumpToGroup(groups[index]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    controller: scroll,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Padding(
                          padding: EdgeInsets.all(
                            constraints.maxWidth < 600 ? 20 : 36,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StudioPageHeader(
                                eyebrow: widget.profile
                                    ? 'Your public presence'
                                    : widget.schema.title,
                                title: widget.schema.singular == 'metadata'
                                    ? widget.schema.title
                                    : (controllers[widget.schema.nameKey]
                                                  ?.text ??
                                              values[widget.schema.nameKey]
                                                  ?.toString() ??
                                              '')
                                          .isNotEmpty
                                    ? (controllers[widget.schema.nameKey]
                                              ?.text ??
                                          values[widget.schema.nameKey]
                                              .toString())
                                    : 'New ${widget.schema.singular}',
                                description: widget.schema.description,
                              ),
                              const SizedBox(height: 24),
                              if (widget.profile ||
                                  widget.schema.collection == 'projects') ...[
                                summaryPreview(),
                                const SizedBox(height: 28),
                              ],
                              if (constraints.maxWidth < 1100) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final group in groups)
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 48),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          backgroundColor:
                                              selectedGroup == group
                                              ? Design.tint
                                              : Design.surface,
                                          side: BorderSide(
                                            color: selectedGroup == group
                                                ? Design.accent
                                                : Design.line,
                                          ),
                                        ),
                                        onPressed: () => jumpToGroup(group),
                                        child: Text(
                                          group,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                              ],
                              if (!widget.profile &&
                                  !widget.schema.fields.any(
                                    (f) => f.key == 'status',
                                  )) ...[
                                StudioPanel(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Visibility',
                                        style: Design.groupType,
                                      ),
                                      const SizedBox(height: 16),
                                      input(
                                        const ContentField(
                                          'status',
                                          'Publication',
                                          kind: FieldKind.select,
                                          choices: ['draft', 'published'],
                                          help:
                                              'Drafts are private. Published entries appear on your portfolio.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              for (
                                var index = 0;
                                index < groups.length;
                                index++
                              )
                                Padding(
                                  key: groupKeys[groups[index]],
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: groupSection(groups[index], index),
                                ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Design.surface,
              border: Border(top: BorderSide(color: Design.line)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: Design.error,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                if (MediaQuery.sizeOf(context).width >= 760)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      widget.profile ||
                              controllers['status']?.text == 'published'
                          ? 'Saved changes update your public portfolio.'
                          : 'This draft stays private until you publish it.',
                      style: Design.captionType,
                    ),
                  ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: saving || uploading ? null : preview,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Preview'),
                    ),
                    TextButton(
                      onPressed: saving || uploading ? null : close,
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: saving || uploading ? null : save,
                      icon: MotionSwap(
                        alignment: Alignment.center,
                        child: saving || uploading
                            ? const SizedBox(
                                key: ValueKey('progress'),
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check,
                                key: ValueKey('ready'),
                                size: 18,
                              ),
                      ),
                      label: MotionSwap(
                        child: Text(
                          saving
                              ? 'Saving…'
                              : uploading
                              ? 'Uploading…'
                              : 'Save changes',
                          key: ValueKey((saving, uploading)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryPreview() {
    final result = data();
    final isProject = widget.schema.collection == 'projects';
    final project = isProject ? ProjectModel.fromMap(result, recordId) : null;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('On your portfolio', color: Design.muted),
        const SizedBox(height: 12),
        Text(
          isProject
              ? project!.title
              : widget.schema.singular == 'metadata'
              ? '${result['seoTitle'] ?? ''}'
              : '${result['heroTitle'] ?? ''}',
          style: const TextStyle(
            fontSize: 23,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: Design.accent,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isProject
              ? project!.description
              : '${result[widget.schema.singular == 'metadata' ? 'seoDescription' : 'heroDescription'] ?? ''}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Design.captionType,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: preview,
          icon: const Icon(Icons.north_east, size: 15),
          iconAlignment: IconAlignment.end,
          label: Text(
            isProject
                ? 'Preview case study'
                : widget.schema.singular == 'metadata'
                ? 'Preview sharing'
                : 'Preview introduction',
          ),
        ),
      ],
    );
    return StudioPanel(
      color: Design.tint,
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, c) {
          if (project == null || c.maxWidth < 500) return copy;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 164,
                child: ProjectMedia(project: project, compact: true),
              ),
              const SizedBox(width: 24),
              Expanded(child: copy),
            ],
          );
        },
      ),
    );
  }

  Widget groupSection(String group, int index) {
    final fields = widget.schema.fields.where((f) => f.group == group).toList();
    if (group == 'Existing content') {
      return StudioPanel(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          maintainState: true,
          title: const Text(
            'Existing content',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Preserved fields from your earlier portfolio.',
            style: Design.captionType,
          ),
          childrenPadding: const EdgeInsets.all(24),
          children: [fieldsLayout(fields)],
        ),
      );
    }
    return StudioPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: Design.captionType.copyWith(color: Design.accent),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(group, style: Design.groupType)),
            ],
          ),
          const SizedBox(height: 24),
          fieldsLayout(fields),
        ],
      ),
    );
  }

  Widget fieldsLayout(List<ContentField> fields) => LayoutBuilder(
    builder: (context, constraints) {
      final rows = <Widget>[];
      var index = 0;
      bool short(ContentField f) =>
          {
            FieldKind.text,
            FieldKind.email,
            FieldKind.month,
            FieldKind.number,
            FieldKind.select,
          }.contains(f.kind) &&
          f.key != 'period';
      while (index < fields.length) {
        final field = fields[index];
        if (constraints.maxWidth >= 620 &&
            index + 1 < fields.length &&
            short(field) &&
            short(fields[index + 1])) {
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: input(field)),
                  const SizedBox(width: 20),
                  Expanded(child: input(fields[index + 1])),
                ],
              ),
            ),
          );
          index += 2;
        } else {
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: input(field),
            ),
          );
          index++;
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    },
  );

  Widget input(ContentField f) {
    if (f.key == 'projectIds') {
      return AbsorbPointer(
        absorbing: saving,
        child: ExcludeFocus(
          excluding: saving,
          child: ProjectReferencePicker(controller: controllers[f.key]!),
        ),
      );
    }
    if (f.key == 'period' &&
        controllers['startDate']?.text.trim().isNotEmpty == true) {
      return InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date shown on portfolio',
          helperText: 'Generated from the start and end months.',
        ),
        child: Text(
          (data()['period'] ?? '').toString(),
          style: const TextStyle(fontSize: 14),
        ),
      );
    }
    if (f.kind == FieldKind.toggle) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(
          f.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: f.help.isEmpty
            ? null
            : Text(
                f.help,
                style: const TextStyle(fontSize: 12, color: Design.muted),
              ),
        value: values[f.key] == true,
        onChanged: saving
            ? null
            : (v) {
                values[f.key] = v;
                changed();
              },
      );
    }
    if (f.kind == FieldKind.gallery || f.kind == FieldKind.links) {
      return MediaListEditor(
        key: ValueKey(f.key),
        field: f,
        projectId: recordId,
        items: (values[f.key] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        onChanged: (items) {
          values[f.key] = items;
          changed();
        },
        onBusy: (busy) => setState(() => uploading = busy),
        enabled: !saving,
      );
    }
    if (f.kind == FieldKind.select) {
      final current = controllers[f.key]!.text;
      return DropdownButtonFormField<String>(
        initialValue: f.choices.contains(current) ? current : f.choices.first,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: f.label,
          helperText: f.help.isEmpty ? null : f.help,
          helperMaxLines: 3,
        ),
        items: f.choices
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(
                  s.isEmpty ? 'Hidden' : s[0].toUpperCase() + s.substring(1),
                ),
              ),
            )
            .toList(),
        onChanged: saving
            ? null
            : (s) {
                controllers[f.key]!.text = s ?? '';
              },
      );
    }
    final text = TextFormField(
      controller: controllers[f.key],
      enabled: !saving && !(f.key == 'endDate' && values['current'] == true),
      maxLines: {FieldKind.multiline, FieldKind.lines}.contains(f.kind) ? 4 : 1,
      keyboardType: f.kind == FieldKind.number
          ? TextInputType.number
          : f.kind == FieldKind.email
          ? TextInputType.emailAddress
          : f.kind == FieldKind.url
          ? TextInputType.url
          : TextInputType.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: '${f.label}${f.required ? ' *' : ''}',
        helperText: f.help.isEmpty ? null : f.help,
        helperMaxLines: 4,
        hintText: f.kind == FieldKind.month ? 'YYYY-MM' : null,
      ),
      validator: (v) => validate(f, v),
    );
    if (f.key == 'cvUrl') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controllers['cvUrl']!.text.startsWith('data:'))
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.picture_as_pdf_outlined),
              title: Text('Uploaded CV'),
              subtitle: Text('Upload another PDF to replace this file.'),
            )
          else
            text,
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: uploading ? null : uploadCv,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload PDF'),
              ),
              TextButton.icon(
                onPressed: controllers['cvUrl']!.text.isEmpty
                    ? null
                    : () {
                        var url = controllers['cvUrl']!.text;
                        if (FirestoreService.useFirebase &&
                            !FirestoreService.useEmulators &&
                            url.startsWith('/')) {
                          url = Uri.parse(
                            controllers['siteUrl']?.text ??
                                values['siteUrl'] ??
                                '',
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
      );
    }
    return text;
  }
}

class MediaListEditor extends StatefulWidget {
  final ContentField field;
  final String projectId;
  final List<Map<String, dynamic>> items;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  final ValueChanged<bool> onBusy;
  final bool enabled;
  const MediaListEditor({
    super.key,
    required this.field,
    required this.projectId,
    required this.items,
    required this.onChanged,
    required this.onBusy,
    this.enabled = true,
  });
  @override
  State<MediaListEditor> createState() => _MediaListEditorState();
}

class _MediaListEditorState extends State<MediaListEditor> {
  bool busy = false;
  String? error;
  void change(int index, String key, String value) {
    final list = widget.items.map((e) => Map<String, dynamic>.from(e)).toList();
    list[index][key] = value;
    widget.onChanged(list);
  }

  void move(int index, int delta) {
    final list = widget.items.toList();
    final item = list.removeAt(index);
    list.insert(index + delta, item);
    widget.onChanged(list);
  }

  Future<void> upload() async {
    setState(() => busy = true);
    widget.onBusy(true);
    try {
      final item = await MediaUpload.pickImage(widget.projectId);
      if (item != null && mounted) {
        widget.onChanged([
          ...widget.items,
          {
            'mediaId': 'media-${DateTime.now().microsecondsSinceEpoch}',
            ...item,
          },
        ]);
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
        widget.onBusy(false);
      }
    }
  }

  void remove(int index, bool gallery) {
    final removed = Map<String, dynamic>.from(widget.items[index]);
    widget.onChanged([...widget.items]..removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gallery ? 'Screen' : 'Link'} removed from this edit.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (!mounted || !widget.enabled) return;
            final items = [...widget.items];
            items.insert(index > items.length ? items.length : index, removed);
            widget.onChanged(items);
          },
        ),
      ),
    );
  }

  void inspect(int index) {
    final item = widget.items[index];
    showContentDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) => ContentDialog(
        label: 'Screenshot preview',
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * .82,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (item['alt'] ?? '').toString().isEmpty
                              ? 'Screen ${index + 1}'
                              : item['alt'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close screenshot preview',
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: PortfolioImage(
                      url: '${item['url'] ?? ''}',
                      alt: '${item['alt'] ?? ''}',
                      thumbnail: false,
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

  String? mediaUrl(String? input, {bool required = true, bool gallery = true}) {
    final value = input?.trim() ?? '';
    if (value.isEmpty) {
      return required ? 'Add a URL or remove this item.' : null;
    }
    if (gallery &&
        (value.startsWith('packages/') ||
            value.startsWith('assets/') ||
            value.startsWith('/') ||
            value.startsWith('storage://') ||
            value.startsWith('data:image/png;base64,') ||
            value.startsWith('data:image/jpeg;base64,') ||
            value.startsWith('data:image/webp;base64,'))) {
      return null;
    }
    final uri = Uri.tryParse(value);
    return uri != null &&
            {'https', 'http'}.contains(uri.scheme) &&
            uri.host.isNotEmpty
        ? null
        : 'Use a complete HTTP or HTTPS URL.';
  }

  @override
  Widget build(BuildContext context) {
    final gallery = widget.field.kind == FieldKind.gallery;
    return AbsorbPointer(
      absorbing: !widget.enabled,
      child: ExcludeFocus(
        excluding: !widget.enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.field.label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              gallery
                  ? 'The first two screens form project previews. Add genuine app imagery and descriptions, then arrange it with the arrows.'
                  : widget.field.help,
              style: Design.captionType,
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < widget.items.length; index++)
              Padding(
                key: ValueKey(
                  widget.items[index]['mediaId'] ?? 'initial-$index',
                ),
                padding: const EdgeInsets.only(bottom: 18),
                child: StudioPanel(
                  padding: const EdgeInsets.all(16),
                  color: Design.paper,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${gallery && index == 0 ? 'Cover · ' : ''}${gallery ? 'Screen' : 'Link'} ${index + 1}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Move ${index + 1} up',
                                onPressed: busy || index == 0
                                    ? null
                                    : () => move(index, -1),
                                icon: const Icon(Icons.arrow_upward, size: 18),
                              ),
                              IconButton(
                                tooltip: 'Move ${index + 1} down',
                                onPressed:
                                    busy || index == widget.items.length - 1
                                    ? null
                                    : () => move(index, 1),
                                icon: const Icon(
                                  Icons.arrow_downward,
                                  size: 18,
                                ),
                              ),
                              IconButton(
                                tooltip:
                                    'Remove ${gallery ? 'screen' : 'link'} ${index + 1}',
                                onPressed: busy
                                    ? null
                                    : () => remove(index, gallery),
                                icon: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, c) {
                          final fields = itemFields(index, gallery);
                          if (!gallery) return fields;
                          final item = widget.items[index];
                          final thumbnail = (item['thumbnail'] ?? '')
                              .toString();
                          final image = Semantics(
                            button: true,
                            label: 'Preview screen ${index + 1}',
                            child: MotionSurface(
                              color: Design.tint,
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => inspect(index),
                              child: SizedBox(
                                height: 230,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: PortfolioImage(
                                    url: thumbnail.isEmpty
                                        ? '${item['url'] ?? ''}'
                                        : thumbnail,
                                    alt:
                                        '${item['alt'] ?? 'Screenshot preview'}',
                                  ),
                                ),
                              ),
                            ),
                          );
                          if (c.maxWidth < 580) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                image,
                                const SizedBox(height: 18),
                                fields,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 150, child: image),
                              const SizedBox(width: 24),
                              Expanded(child: fields),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  gallery
                      ? 'No screenshots yet. Upload an app screen or add its image URL.'
                      : 'No additional links yet.',
                  style: Design.captionType,
                ),
              ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (gallery)
                  OutlinedButton.icon(
                    onPressed: busy ? null : upload,
                    icon: const Icon(Icons.upload_outlined, size: 18),
                    label: Text(busy ? 'Uploading…' : 'Upload screenshot'),
                  ),
                TextButton.icon(
                  onPressed: busy
                      ? null
                      : () => widget.onChanged([
                          ...widget.items,
                          {
                            'mediaId':
                                'media-${DateTime.now().microsecondsSinceEpoch}',
                            'url': '',
                            gallery ? 'alt' : 'label': '',
                          },
                        ]),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(gallery ? 'Add image URL' : 'Add link'),
                ),
              ],
            ),
            if (error != null)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Design.error),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget itemFields(int index, bool gallery) {
    final item = widget.items[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!(item['url'] ?? '').toString().startsWith('data:')) ...[
          TextFormField(
            initialValue: '${item['url'] ?? ''}',
            decoration: InputDecoration(
              labelText: gallery ? 'Image URL' : 'Destination URL',
            ),
            onChanged: (value) => change(index, 'url', value),
            validator: (value) => mediaUrl(value, gallery: gallery),
          ),
          const SizedBox(height: 16),
        ] else ...[
          Text(
            (item['filename'] ?? 'Uploaded screenshot').toString(),
            style: Design.captionType,
          ),
          const SizedBox(height: 14),
        ],
        TextFormField(
          initialValue: '${item[gallery ? 'alt' : 'label'] ?? ''}',
          decoration: InputDecoration(
            labelText: gallery
                ? 'Meaningful screen description *'
                : 'Link label *',
          ),
          onChanged: (value) => change(index, gallery ? 'alt' : 'label', value),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Add a description.'
              : null,
        ),
        if (gallery &&
            !(item['thumbnail'] ?? '').toString().startsWith('data:')) ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: '${item['thumbnail'] ?? ''}',
            decoration: const InputDecoration(
              labelText: 'Optimized thumbnail URL (optional)',
              helperText: 'A smaller version of this same screenshot.',
              helperMaxLines: 2,
            ),
            onChanged: (value) => change(index, 'thumbnail', value),
            validator: (value) => mediaUrl(value, required: false),
          ),
        ],
      ],
    );
  }
}
