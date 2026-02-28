import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Thank you for your message! I'll get back to you soon."),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width >= 768 ? 36.0 : 28.0;
    final isDesktop = width >= 1024;

    return Container(
      color: AppColors.accent.withValues(alpha: 0.3),
      child: SectionContainer(
        extraPadding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            // Header
            Text(
              'Get In Touch',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Have a project in mind or want to collaborate? I'd love to hear from you!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.mutedForeground, height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 64),
            // Content
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildContactInfo()),
                      const SizedBox(width: 48),
                      Expanded(child: _buildForm()),
                    ],
                  )
                : Column(
                    children: [
                      _buildContactInfo(),
                      const SizedBox(height: 48),
                      _buildForm(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground),
        ),
        const SizedBox(height: 24),
        _ContactInfoRow(
          icon: Icons.mail_outline,
          title: 'Email',
          value: 'your.email@example.com',
        ),
        const SizedBox(height: 24),
        _ContactInfoRow(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: '+1 (555) 123-4567',
        ),
        const SizedBox(height: 24),
        _ContactInfoRow(
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: 'Your City, Country',
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Let's Work Together",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.foreground),
              ),
              SizedBox(height: 12),
              Text(
                "I'm currently available for freelance projects and full-time opportunities. Whether you need a new app built from scratch or help with an existing project, I'm here to help bring your vision to life.",
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                    height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormField(
            label: 'Name',
            controller: _nameController,
            placeholder: 'Your name',
            validator: (v) => v!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 24),
          _FormField(
            label: 'Email',
            controller: _emailController,
            placeholder: 'your.email@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v!.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _FormField(
            label: 'Subject',
            controller: _subjectController,
            placeholder: 'Project inquiry',
            validator: (v) => v!.isEmpty ? 'Subject is required' : null,
          ),
          const SizedBox(height: 24),
          _FormField(
            label: 'Message',
            controller: _messageController,
            placeholder: 'Tell me about your project...',
            maxLines: 5,
            validator: (v) => v!.isEmpty ? 'Message is required' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Send Message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactInfoRow(
      {required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.foreground),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.mutedForeground),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style:
              const TextStyle(fontSize: 14, color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
                color: AppColors.mutedForeground, fontSize: 14),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
