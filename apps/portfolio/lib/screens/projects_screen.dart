import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../services/public_content.dart';
import '../widgets/editorial_sections.dart';

class ProjectsScreen extends StatefulWidget {
  final PublicContent content;
  const ProjectsScreen({super.key, required this.content});
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String category = 'All work';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.content,
    builder: (context, _) {
      final c = widget.content;
      final categories = {
        'All work',
        ...c.projects.map((p) => p.category).where((v) => v.isNotEmpty),
      };
      final filtered = c.projects
          .where((p) => category == 'All work' || p.category == category)
          .toList();
      updatePageMetadata(
        title: 'Projects — ${c.text('name')}',
        description: c.text('projectsDescription'),
        canonical: '${c.text('siteUrl')}/projects',
        image: c.text('socialImage'),
      );
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Design.paper,
          title: PortfolioBrand(name: c.text('name')),
          leading: IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
          ),
        ),
        body: c.error != null
            ? Center(
                child: StateMessage(
                  title: 'Could not load projects',
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
                  child: ContentWidth(
                    vertical: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeading(
                          number: 'The collection',
                          title: 'Work in the wild.',
                          description:
                              'Production mobile applications across services, marketplaces, fitness, and beyond.',
                        ),
                        const SizedBox(height: 32),
                        if (c.projects.length >= 6)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categories
                                .map(
                                  (e) => ChoiceChip(
                                    label: Text(e),
                                    selected: category == e,
                                    onSelected: (_) =>
                                        setState(() => category = e),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 18),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            '${filtered.length} ${filtered.length == 1 ? 'project' : 'projects'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Design.muted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedSwitcher(
                          duration: Design.reduced(context)
                              ? Duration.zero
                              : Design.fast,
                          child: filtered.isEmpty
                              ? StateMessage(
                                  key: ValueKey(category),
                                  title: 'No projects here yet',
                                  message:
                                      'Choose another category to explore the collection.',
                                )
                              : ProjectGrid(
                                  key: ValueKey(category),
                                  projects: filtered,
                                ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
      );
    },
  );
}

class ProjectScreen extends StatelessWidget {
  final String slug;
  final PublicContent content;
  const ProjectScreen({super.key, required this.slug, required this.content});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: content,
    builder: (context, _) {
      final matches = content.projects.where(
        (p) => p.slug == slug || p.id == slug,
      );
      if (content.loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (content.error != null) {
        return Scaffold(
          body: Center(
            child: StateMessage(
              title: 'Could not load this project',
              message: content.error!,
              action: FilledButton(
                onPressed: content.connect,
                child: const Text('Try again'),
              ),
            ),
          ),
        );
      }
      if (matches.isEmpty) return const NotFoundScreen();
      final p = matches.first;
      updatePageMetadata(
        title: p.seoTitle.isEmpty
            ? '${p.title} — ${content.text('name')}'
            : p.seoTitle,
        description: p.seoDescription.isEmpty
            ? p.description
            : p.seoDescription,
        canonical:
            '${content.text('siteUrl')}/projects/${p.slug.isEmpty ? p.id : p.slug}',
        image: content.text('socialImage'),
      );
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Design.paper,
          title: PortfolioBrand(name: content.text('name')),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              child: const Text('Home'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: ProjectDetail(
          project: p,
          onBack: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/projects',
            (_) => false,
          ),
        ),
      );
    },
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) {
    updatePageMetadata(
      title: 'Page not found — Ahmed Emara',
      description: 'This page is not available.',
      noIndex: true,
    );
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: StateMessage(
            icon: Icons.explore_outlined,
            title: 'This page took a wrong turn.',
            message:
                'The project may be unpublished, or the link may have changed.',
            action: FilledButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              child: const Text('Back to the portfolio'),
            ),
          ),
        ),
      ),
    );
  }
}
