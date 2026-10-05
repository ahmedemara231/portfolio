import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../services/public_content.dart';
import '../widgets/editorial_sections.dart';

class HomeScreen extends StatefulWidget {
  final PublicContent content;
  const HomeScreen({super.key, required this.content});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final work = GlobalKey(),
      experience = GlobalKey(),
      packages = GlobalKey(),
      contact = GlobalKey();
  final scroll = ScrollController();
  void go(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: Design.reduced(context) ? Duration.zero : Design.motion,
        curve: Curves.easeOutCubic,
        alignment: 0,
      );
    }
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.content,
    builder: (context, _) {
      final c = widget.content;
      updatePageMetadata(
        title: c.text('seoTitle', 'Ahmed Emara — Flutter Developer'),
        description: c.text('seoDescription'),
        canonical: c.text('siteUrl'),
        image: c.text('socialImage'),
      );
      return Scaffold(
        body: Column(
          children: [
            PublicHeader(
              name: c.text('name', 'Ahmed Emara'),
              onWork: () => go(work),
              onExperience: () => go(experience),
              onPackages: () => go(packages),
              onContact: () => go(contact),
            ),
            Expanded(
              child: c.error != null
                  ? Center(
                      child: StateMessage(
                        title: 'Could not load the portfolio',
                        message: c.error!,
                        action: FilledButton(
                          onPressed: c.connect,
                          child: const Text('Try again'),
                        ),
                      ),
                    )
                  : c.loading
                  ? const Center(child: CircularProgressIndicator())
                  : SelectionArea(
                      child: SingleChildScrollView(
                        controller: scroll,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PortfolioHero(
                              content: c,
                              onWork: () => go(work),
                              onContact: () => go(contact),
                            ),
                            SizedBox(
                              key: work,
                              child: SelectedWork(content: c),
                            ),
                            SizedBox(
                              key: experience,
                              child: ExperienceBlock(content: c),
                            ),
                            SizedBox(
                              key: packages,
                              child: PackagesBlock(content: c),
                            ),
                            CapabilitiesBlock(content: c),
                            AboutBlock(content: c),
                            SizedBox(
                              key: contact,
                              child: ContactBlock(content: c),
                            ),
                            PortfolioFooter(content: c),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    },
  );
}

class PublicHeader extends StatelessWidget {
  final String name;
  final VoidCallback onWork, onExperience, onPackages, onContact;
  const PublicHeader({
    super.key,
    required this.name,
    required this.onWork,
    required this.onExperience,
    required this.onPackages,
    required this.onContact,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Design.paper,
      border: Border(bottom: BorderSide(color: Design.line)),
    ),
    child: ContentWidth(
      child: SizedBox(
        height: 80,
        child: LayoutBuilder(
          builder: (context, c) => Row(
            children: [
              PortfolioBrand(name: name, compact: c.maxWidth < 470),
              const Spacer(),
              if (c.maxWidth >= 740) ...[
                TextButton(onPressed: onWork, child: const Text('Work')),
                const SizedBox(width: 14),
                TextButton(
                  onPressed: onExperience,
                  child: const Text('Experience'),
                ),
                const SizedBox(width: 14),
                TextButton(
                  onPressed: onPackages,
                  child: const Text('Open source'),
                ),
                const SizedBox(width: 24),
              ],
              if (c.maxWidth < 740)
                PopupMenuButton<String>(
                  tooltip: 'Portfolio navigation',
                  onSelected: (value) => switch (value) {
                    'work' => onWork(),
                    'experience' => onExperience(),
                    'packages' => onPackages(),
                    _ => onContact(),
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'work', child: Text('Selected work')),
                    PopupMenuItem(
                      value: 'experience',
                      child: Text('Experience'),
                    ),
                    PopupMenuItem(
                      value: 'packages',
                      child: Text('Open source'),
                    ),
                    PopupMenuItem(value: 'contact', child: Text('Contact')),
                  ],
                  icon: const Icon(Icons.menu),
                ),
              OutlinedButton(
                onPressed: onContact,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.maxWidth < 350 ? 'Contact' : 'Let’s talk'),
                    if (c.maxWidth >= 350) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.north_east, size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
