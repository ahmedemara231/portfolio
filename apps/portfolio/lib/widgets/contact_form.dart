import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ContactFormDialog extends StatefulWidget {
  final String email;
  const ContactFormDialog({super.key, required this.email});
  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      subject = TextEditingController(),
      message = TextEditingController();
  bool busy = false, sent = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    subject.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await FirestoreService.submitContactMessage(
        name: name.text,
        email: email.text,
        subject: subject.text,
        message: message.text,
      );
      if (mounted) setState(() => sent = true);
    } catch (e) {
      if (mounted) {
        setState(
          () => error =
              'Could not send your message. Please wait a moment and retry, or email Ahmed directly.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ContentDialog(
    label: sent ? 'Message sent.' : 'Contact Ahmed',
    insetPadding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 580),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: sent
              ? StateMessage(
                  icon: Icons.check_circle_outline,
                  title: 'Message sent.',
                  message:
                      'Thanks for getting in touch. Ahmed will follow up with you.',
                  action: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                )
              : Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Start a conversation.',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.7,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close contact form',
                            onPressed: busy
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: name,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter your name.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: email,
                        maxLength: 254,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) =>
                            RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(v ?? '')
                            ? null
                            : 'Enter a valid email.',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: subject,
                        maxLength: 160,
                        decoration: const InputDecoration(
                          labelText: 'Subject (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: message,
                        maxLines: 5,
                        maxLength: 5000,
                        decoration: const InputDecoration(labelText: 'Message'),
                        validator: (v) => (v?.trim().length ?? 0) < 10
                            ? 'Write at least 10 characters.'
                            : null,
                      ),
                      if (error != null)
                        Semantics(
                          liveRegion: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              error!,
                              style: const TextStyle(
                                color: Design.error,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: busy ? null : submit,
                        child: Text(busy ? 'Sending…' : 'Send message'),
                      ),
                      const SizedBox(height: 8),
                      ExternalAction(
                        label: 'Email Ahmed directly',
                        url: 'mailto:${widget.email}',
                        icon: Icons.mail_outline,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ),
  );
}
