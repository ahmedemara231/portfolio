import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/dashboard_theme.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _search = '';
  _Filter _filter = _Filter.all;

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
                    const Text('Messages',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Inbox from your portfolio contact form',
                        style: TextStyle(color: DashboardColors.mutedForeground)),
                  ],
                ),
              ),
              StreamBuilder<int>(
                stream: FirestoreService.unreadMessagesCountStream(),
                builder: (context, snap) {
                  final unread = snap.data ?? 0;
                  if (unread == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DashboardColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('$unread unread',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: DashboardColors.primary)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search + filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: const InputDecoration(
                    hintText: 'Search by name, email, subject...',
                    prefixIcon:
                        Icon(Icons.search, color: DashboardColors.mutedForeground),
                    fillColor: DashboardColors.card,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<_Filter>(
                segments: const [
                  ButtonSegment(value: _Filter.all, label: Text('All')),
                  ButtonSegment(value: _Filter.unread, label: Text('Unread')),
                  ButtonSegment(value: _Filter.read, label: Text('Read')),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
                showSelectedIcon: false,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List
          StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
            stream: FirestoreService.messagesStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return _emptyCard('Failed to load messages: ${snap.error}');
              }
              final all = snap.data ?? [];
              final q = _search.toLowerCase().trim();
              final filtered = all.where((e) {
                final m = e.value;
                final read = (m['read'] ?? false) == true;
                if (_filter == _Filter.unread && read) return false;
                if (_filter == _Filter.read && !read) return false;
                if (q.isEmpty) return true;
                bool match(String? s) =>
                    (s ?? '').toLowerCase().contains(q);
                return match(m['name']) ||
                    match(m['email']) ||
                    match(m['subject']) ||
                    match(m['message']);
              }).toList();

              if (filtered.isEmpty) {
                return _emptyCard(all.isEmpty
                    ? 'No messages yet. Submissions from the contact form will appear here.'
                    : 'No messages match this filter.');
              }

              return Container(
                decoration: BoxDecoration(
                  color: DashboardColors.card,
                  border: Border.all(color: DashboardColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: List.generate(filtered.length, (i) {
                    final e = filtered[i];
                    return _MessageRow(
                      id: e.key,
                      data: e.value,
                      showDivider: i != filtered.length - 1,
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              size: 40, color: DashboardColors.mutedForeground),
          const SizedBox(height: 12),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: DashboardColors.mutedForeground)),
        ],
      ),
    );
  }
}

enum _Filter { all, unread, read }

class _MessageRow extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final bool showDivider;
  const _MessageRow({
    required this.id,
    required this.data,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final subject = (data['subject'] ?? '').toString();
    final message = (data['message'] ?? '').toString();
    final read = (data['read'] ?? false) == true;
    final replied = (data['replied'] ?? false) == true;
    final ts = data['createdAt'];
    final when = ts is Timestamp ? ts.toDate() : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openMessage(context),
        hoverColor: DashboardColors.accent,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: showDivider
                    ? DashboardColors.border
                    : Colors.transparent,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread dot / avatar
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: DashboardColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DashboardColors.primary),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!read)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: DashboardColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            name.isEmpty ? '(no name)' : name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  read ? FontWeight.w500 : FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text('<$email>',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: DashboardColors.mutedForeground),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subject.isEmpty ? '(no subject)' : subject,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  read ? FontWeight.w400 : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (replied) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: DashboardColors.greenLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Replied',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: DashboardColors.green)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                          fontSize: 13,
                          color: DashboardColors.mutedForeground),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    when == null ? '' : _shortTime(when),
                    style: const TextStyle(
                        fontSize: 12, color: DashboardColors.mutedForeground),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: read ? 'Mark as unread' : 'Mark as read',
                        icon: Icon(
                          read
                              ? Icons.mark_email_unread_outlined
                              : Icons.mark_email_read_outlined,
                          size: 18,
                        ),
                        onPressed: () => _toggleRead(context, !read),
                        splashRadius: 18,
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: DashboardColors.destructive),
                        onPressed: () => _confirmDelete(context),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMessage(BuildContext context) async {
    final read = (data['read'] ?? false) == true;
    if (!read) {
      // Best-effort mark as read on open.
      FirestoreService.markMessageRead(id).catchError((_) {});
    }
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => _MessageDetailDialog(id: id, data: data),
    );
  }

  Future<void> _toggleRead(BuildContext context, bool read) async {
    try {
      await FirestoreService.markMessageRead(id, read: read);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update message: $e')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text(
            'Delete message from "${data['name'] ?? '(no name)'}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirestoreService.deleteMessage(id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
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
  }
}

class _MessageDetailDialog extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  const _MessageDetailDialog({required this.id, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final subject = (data['subject'] ?? '').toString();
    final message = (data['message'] ?? '').toString();
    final ts = data['createdAt'];
    final when = ts is Timestamp ? ts.toDate() : null;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subject.isEmpty ? '(no subject)' : subject,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: DashboardColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(name.isEmpty ? '(no name)' : name,
                          style: const TextStyle(
                              fontSize: 13,
                              color: DashboardColors.mutedForeground)),
                    ],
                  ),
                  if (email.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mail_outline,
                            size: 14,
                            color: DashboardColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text(email,
                            style: const TextStyle(
                                fontSize: 13,
                                color: DashboardColors.mutedForeground)),
                      ],
                    ),
                  if (when != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule,
                            size: 14,
                            color: DashboardColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text(_fullTime(when),
                            style: const TextStyle(
                                fontSize: 13,
                                color: DashboardColors.mutedForeground)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: SelectableText(
                    message,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (email.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => _ReplyDialog(
                            messageId: id,
                            toName: name,
                            toEmail: email,
                            originalSubject: subject,
                            originalMessage: message,
                            originalSentAt: when,
                          ),
                        );
                      },
                      icon: const Icon(Icons.reply, size: 16),
                      label: const Text('Reply'),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await FirestoreService.deleteMessage(id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: DashboardColors.destructive),
                    label: const Text('Delete',
                        style: TextStyle(color: DashboardColors.destructive)),
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

class _ReplyDialog extends StatefulWidget {
  final String messageId;
  final String toName;
  final String toEmail;
  final String originalSubject;
  final String originalMessage;
  final DateTime? originalSentAt;

  const _ReplyDialog({
    required this.messageId,
    required this.toName,
    required this.toEmail,
    required this.originalSubject,
    required this.originalMessage,
    required this.originalSentAt,
  });

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  late final TextEditingController _toCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _bodyCtrl;
  bool _includeQuote = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _toCtrl = TextEditingController(text: widget.toEmail);
    _subjectCtrl = TextEditingController(
      text: widget.originalSubject.isEmpty
          ? 'Re:'
          : (widget.originalSubject.toLowerCase().startsWith('re:')
              ? widget.originalSubject
              : 'Re: ${widget.originalSubject}'),
    );
    final greeting = widget.toName.isEmpty ? 'Hi,' : 'Hi ${widget.toName},';
    _bodyCtrl = TextEditingController(text: '$greeting\n\n\n');
  }

  @override
  void dispose() {
    _toCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  String _quotedOriginal() {
    final when = widget.originalSentAt;
    final header = when == null
        ? 'On a previous date, ${widget.toName.isEmpty ? widget.toEmail : widget.toName} wrote:'
        : 'On ${_fullTime(when)}, ${widget.toName.isEmpty ? widget.toEmail : widget.toName} wrote:';
    final quoted = widget.originalMessage
        .split('\n')
        .map((l) => '> $l')
        .join('\n');
    return '\n\n$header\n$quoted';
  }

  String _composeBody() {
    return _includeQuote ? '${_bodyCtrl.text}${_quotedOriginal()}' : _bodyCtrl.text;
  }

  Uri _mailtoUri() {
    return Uri(
      scheme: 'mailto',
      path: _toCtrl.text.trim(),
      query: _encodeMailtoQuery({
        'subject': _subjectCtrl.text,
        'body': _composeBody(),
      }),
    );
  }

  String _encodeMailtoQuery(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
  }

  Future<void> _send() async {
    final to = _toCtrl.text.trim();
    if (to.isEmpty || _sending) return;
    setState(() => _sending = true);
    final uri = _mailtoUri();
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        // Fall back to copying so the user can paste into their mail client.
        await Clipboard.setData(ClipboardData(text: uri.toString()));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'No mail client found. The mailto link was copied to your clipboard.')),
        );
      }
      await FirestoreService.markMessageReplied(widget.messageId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reply opened for $to and marked as replied.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open mail client: $e')),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(
      text: 'To: ${_toCtrl.text}\n'
          'Subject: ${_subjectCtrl.text}\n\n'
          '${_composeBody()}',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Reply',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label('To'),
              TextField(
                controller: _toCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'name@example.com'),
              ),
              const SizedBox(height: 12),
              _label('Subject'),
              TextField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(hintText: 'Subject'),
              ),
              const SizedBox(height: 12),
              _label('Message'),
              TextField(
                controller: _bodyCtrl,
                minLines: 8,
                maxLines: 14,
                decoration: const InputDecoration(
                  hintText: 'Write your reply...',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _includeQuote,
                    onChanged: (v) =>
                        setState(() => _includeQuote = v ?? true),
                  ),
                  const Text('Quote original message',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy'),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _toCtrl.text.trim().isEmpty || _sending
                        ? null
                        : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, size: 16),
                    label: const Text('Open in Mail'),
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
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      );
}

String _shortTime(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${when.year}-${_pad(when.month)}-${_pad(when.day)}';
}

String _fullTime(DateTime when) {
  return '${when.year}-${_pad(when.month)}-${_pad(when.day)} '
      '${_pad(when.hour)}:${_pad(when.minute)}';
}

String _pad(int n) => n.toString().padLeft(2, '0');
