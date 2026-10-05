import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../services/media_upload.dart';

class RecordEditor extends StatefulWidget {
  final ContentSchema schema;
  final String? id;
  final Map<String, dynamic> initial;
  final bool profile;
  const RecordEditor({
    super.key,
    required this.schema,
    this.id,
    this.initial = const {},
    this.profile = false,
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
  @override
  void initState() {
    super.initState();
    values = {...widget.initial};
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
    }
  }

  void changed() {
    if (!mounted) return;
    setState(() => dirty = true);
    protectUnsavedChanges(true);
  }

  @override
  void dispose() {
    protectUnsavedChanges(false);
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
        result[f.key] = values[f.key] ?? [];
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
    if (saving || uploading || !form.currentState!.validate()) return;
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
    final project = ProjectModel.fromMap(data(), recordId);
    showContentDialog(
      useRootNavigator: false,
      context: context,
      builder: (ctx) => ContentDialog(
        label: 'Project preview',
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Project preview',
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
            Expanded(child: ProjectDetail(project: project, preview: true)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.schema.fields.map((f) => f.group).toSet();
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
          backgroundColor: Design.paper,
          leading: IconButton(
            tooltip: 'Close editor',
            onPressed: saving || uploading ? null : close,
            icon: const Icon(Icons.close),
          ),
          title: Text(
            widget.profile
                ? 'Edit ${widget.schema.singular}'
                : '${widget.id == null ? 'New' : 'Edit'} ${widget.schema.singular}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
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
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).width < 600 ? 20 : 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.schema.description,
                        style: const TextStyle(
                          color: Design.muted,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (!widget.profile &&
                          !widget.schema.fields.any(
                            (f) => f.key == 'status',
                          )) ...[
                        input(
                          const ContentField(
                            'status',
                            'Publication',
                            kind: FieldKind.select,
                            choices: ['draft', 'published'],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      for (final group in groups) ...[
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(group, style: Design.groupType),
                        const SizedBox(height: 24),
                        for (final f in widget.schema.fields.where(
                          (f) => f.group == group,
                        ))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: input(f),
                          ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
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
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (widget.schema.collection == 'projects')
                      OutlinedButton.icon(
                        onPressed: saving ? null : preview,
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

  Widget input(ContentField f) {
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
        onChanged: (v) {
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
      );
    }
    if (f.kind == FieldKind.select) {
      final current = controllers[f.key]!.text;
      return DropdownButtonFormField<String>(
        initialValue: f.choices.contains(current) ? current : f.choices.first,
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
        onChanged: (s) {
          controllers[f.key]!.text = s ?? '';
        },
      );
    }
    final text = TextFormField(
      controller: controllers[f.key],
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
  const MediaListEditor({
    super.key,
    required this.field,
    required this.projectId,
    required this.items,
    required this.onChanged,
    required this.onBusy,
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

  @override
  Widget build(BuildContext context) {
    final gallery = widget.field.kind == FieldKind.gallery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.field.label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          gallery
              ? 'Use genuine app screens. Add a description, then move screens into the order you want.'
              : widget.field.help,
          style: const TextStyle(
            color: Design.muted,
            fontSize: 12,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < widget.items.length; i++)
          Container(
            key: ValueKey(widget.items[i]['mediaId'] ?? 'initial-$i'),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Design.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      '${gallery ? 'Screen' : 'Link'} ${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Move ${i + 1} up',
                      onPressed: i == 0 ? null : () => move(i, -1),
                      icon: const Icon(Icons.arrow_upward, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Move ${i + 1} down',
                      onPressed: i == widget.items.length - 1
                          ? null
                          : () => move(i, 1),
                      icon: const Icon(Icons.arrow_downward, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Remove ${gallery ? 'screen' : 'link'} ${i + 1}',
                      onPressed: () =>
                          widget.onChanged([...widget.items]..removeAt(i)),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                if (gallery) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: PortfolioImage(
                      url:
                          (widget.items[i]['thumbnail'] ??
                                  widget.items[i]['url'] ??
                                  '')
                              .toString(),
                      alt: (widget.items[i]['alt'] ?? 'Media preview')
                          .toString(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (!(widget.items[i]['url'] ?? '').toString().startsWith(
                  'data:',
                ))
                  TextFormField(
                    initialValue: (widget.items[i]['url'] ?? '').toString(),
                    decoration: InputDecoration(
                      labelText: gallery ? 'Image URL' : 'Destination URL',
                    ),
                    onChanged: (v) => change(i, 'url', v),
                    validator: (value) {
                      final u = Uri.tryParse(value ?? '');
                      if (value == null || value.trim().isEmpty) {
                        return 'Add a URL or remove this item.';
                      }
                      if (gallery &&
                          (value.startsWith('packages/') ||
                              value.startsWith('storage://'))) {
                        return null;
                      }
                      return u != null &&
                              {'https', 'http'}.contains(u.scheme) &&
                              u.host.isNotEmpty
                          ? null
                          : 'Use a complete HTTP or HTTPS URL.';
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue:
                      (widget.items[i][gallery ? 'alt' : 'label'] ?? '')
                          .toString(),
                  decoration: InputDecoration(
                    labelText: gallery
                        ? 'Meaningful screen description *'
                        : 'Link label *',
                  ),
                  onChanged: (v) => change(i, gallery ? 'alt' : 'label', v),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Add a description.'
                      : null,
                ),
                if (gallery &&
                    !(widget.items[i]['thumbnail'] ?? '').toString().startsWith(
                      'data:',
                    )) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: (widget.items[i]['thumbnail'] ?? '')
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Optimized thumbnail URL (optional)',
                      helperText:
                          'Use a smaller version of this same screenshot for previews.',
                    ),
                    onChanged: (v) => change(i, 'thumbnail', v),
                  ),
                ],
              ],
            ),
          ),
        if (widget.items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'No entries yet.',
              style: TextStyle(color: Design.muted),
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
          Text(error!, style: const TextStyle(color: Design.error)),
      ],
    );
  }
}
