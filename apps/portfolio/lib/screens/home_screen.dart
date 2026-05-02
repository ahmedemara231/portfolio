import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../sections/header_section.dart';
import '../sections/hero_section.dart';
import '../sections/about_section.dart';
import '../sections/skills_section.dart';
import '../sections/projects_section.dart';
import '../sections/experience_section.dart';
import '../sections/contact_section.dart';
import '../sections/footer_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FirestoreService.profileStream(),
        builder: (context, profileSnap) {
          if (profileSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = profileSnap.data ?? {};

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 72),
                    HeroSection(profile: profile),
                    SizedBox(
                        key: _aboutKey,
                        child: AboutSection(profile: profile)),
                    SizedBox(
                        key: _skillsKey,
                        child: SkillsSection(profile: profile)),
                    SizedBox(
                        key: _projectsKey,
                        child: const ProjectsSection()),
                    SizedBox(
                        key: _experienceKey,
                        child: ExperienceSection(profile: profile)),
                    SizedBox(
                        key: _contactKey,
                        child: ContactSection(profile: profile)),
                    FooterSection(
                      profile: profile,
                      onAbout: () => _scrollToSection(_aboutKey),
                      onSkills: () => _scrollToSection(_skillsKey),
                      onProjects: () => _scrollToSection(_projectsKey),
                      onExperience: () => _scrollToSection(_experienceKey),
                      onContact: () => _scrollToSection(_contactKey),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HeaderSection(
                  cvUrl: profile['cvUrl'] as String? ?? '',
                  onAbout: () => _scrollToSection(_aboutKey),
                  onSkills: () => _scrollToSection(_skillsKey),
                  onProjects: () => _scrollToSection(_projectsKey),
                  onExperience: () => _scrollToSection(_experienceKey),
                  onContact: () => _scrollToSection(_contactKey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
