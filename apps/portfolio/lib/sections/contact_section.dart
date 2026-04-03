import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/section_container.dart';

class ContactSection extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ContactSection({super.key, required this.profile});

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

  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await FirestoreService.submitContactMessage(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final width = MediaQuery.of(context).size.width;
    final titleSize = width >= 768 ? 36.0 : 28.0;
    final isDesktop = width >= 1024;
    final contactTitle =
        profile['contactTitle'] as String? ?? 'Get In Touch';
    final contactDescription = profile['contactDescription'] as String?;
    final contactEmail = profile['contactEmail'] as String?;
    final contactPhone = profile['contactPhone'] as String?;
    final contactLocation = profile['contactLocation'] as String?;
    final contactCtaTitle = profile['contactCtaTitle'] as String?;
    final contactCtaDescription =
        profile['contactCtaDescription'] as String?;

    final hasContactInfo = (contactEmail != null && contactEmail.isNotEmpty) ||
        (contactPhone != null && contactPhone.isNotEmpty) ||
        (contactLocation != null && contactLocation.isNotEmpty);

    return Container(
      color: AppColors.accent.withValues(alpha: 0.3),
      child: SectionContainer(
        extraPadding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Text(
              contactTitle,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            if (contactDescription != null &&
                contactDescription.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                contactDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.mutedForeground,
                    height: 1.6,
                    fontSize: 16),
              ),
            ],
            const SizedBox(height: 64),
            if (hasContactInfo && isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildContactInfo(
                    email: contactEmail,
                    phone: contactPhone,
                    location: contactLocation,
                    ctaTitle: contactCtaTitle,
                    ctaDescription: contactCtaDescription,
                  )),
                  const SizedBox(width: 48),
                  Expanded(child: _buildForm()),
                ],
              )
            else if (hasContactInfo)
              Column(
                children: [
                  _buildContactInfo(
                    email: contactEmail,
                    phone: contactPhone,
                    location: contactLocation,
                    ctaTitle: contactCtaTitle,
                    ctaDescription: contactCtaDescription,
                  ),
                  const SizedBox(height: 48),
                  _buildForm(),
                ],
              )
            else
              _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    String? email,
    String? phone,
    String? location,
    String? ctaTitle,
    String? ctaDescription,
  }) {
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
        if (email != null && email.isNotEmpty) ...[
          _ContactInfoRow(
            icon: Icons.mail_outline,
            title: 'Email',
            value: email,
          ),
          const SizedBox(height: 24),
        ],
        if (phone != null && phone.isNotEmpty) ...[
          _ContactInfoRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: phone,
          ),
          const SizedBox(height: 24),
        ],
        if (location != null && location.isNotEmpty) ...[
          _ContactInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: location,
          ),
          const SizedBox(height: 24),
        ],
        if (ctaTitle != null && ctaTitle.isNotEmpty)
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
              children: [
                Text(
                  ctaTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.foreground),
                ),
                if (ctaDescription != null &&
                    ctaDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    ctaDescription,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                        height: 1.6),
                  ),
                ],
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
            onPressed: _isSubmitting ? null : _handleSubmit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryForeground,
                    ),
                  )
                : const Icon(Icons.send, size: 18),
            label: Text(_isSubmitting ? 'Sending...' : 'Send Message'),
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
