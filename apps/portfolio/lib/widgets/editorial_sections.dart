import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../services/public_content.dart';
import 'contact_form.dart';

class PortfolioHero extends StatelessWidget {
  final PublicContent content;
  final VoidCallback onWork, onContact;
  const PortfolioHero({
    super.key,
    required this.content,
    required this.onWork,
    required this.onContact,
  });
  @override
  Widget build(BuildContext context) => ContentWidth(
    vertical: MediaQuery.sizeOf(context).width < 600 ? 28 : 48,
    child: LayoutBuilder(
      builder: (context, c) {
        final profile = content;
        final width = c.maxWidth;
        final isWide = width >= 850;
        final intro = Entrance(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(
                '${profile.text('professionalTitle', profile.text('badge', 'Flutter Developer'))} / ${profile.text('contactLocation')}',
              ),
              SizedBox(height: width < 600 ? 16 : 24),
              Semantics(
                header: true,
                child: Text(
                  profile.text('name', 'Ahmed Emara'),
                  style: TextStyle(
                    fontSize: width < 600 ? 40 : 66,
                    fontWeight: FontWeight.w800,
                    letterSpacing: width < 600 ? -1.6 : -2.8,
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                profile.text('heroTitle'),
                style: TextStyle(
                  fontSize: width < 600 ? 28 : 46,
                  height: 1.18,
                  fontWeight: FontWeight.w500,
                  color: Design.accent,
                  letterSpacing: width < 600 ? -.9 : -1.8,
                ),
              ),
              if (profile.text('heroHighlight').trim().isNotEmpty)
                Text(
                  profile.text('heroHighlight').trim(),
                  style: const TextStyle(fontSize: 24, color: Design.accent),
                ),
              SizedBox(height: width < 600 ? 16 : 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  profile.text('heroDescription'),
                  style: TextStyle(
                    fontSize: width < 600 ? 14 : 16,
                    height: width < 600 ? 1.7 : 1.8,
                    color: Design.muted,
                  ),
                ),
              ),
              SizedBox(height: width < 600 ? 20 : 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: onWork,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Projects'),
                        SizedBox(width: 18),
                        Icon(Icons.arrow_downward, size: 16),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: profile.text('cvUrl').isEmpty
                        ? null
                        : () => downloadFile(
                            profile.text('cvUrl'),
                            'Ahmed-Emara-CV.pdf',
                          ),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Download CV'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (profile.text('availabilityStatus').isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusPill(
                      profile.text('availabilityNote').isEmpty
                          ? switch (profile.text('availabilityStatus')) {
                              'available' => 'Available for opportunities',
                              'open' => 'Open to opportunities',
                              _ => 'Currently engaged',
                            }
                          : profile.text('availabilityNote'),
                      active:
                          profile.text('availabilityStatus') != 'unavailable',
                    ),
                    if (width >= 600)
                      TextButton(
                        onPressed: onContact,
                        child: const Text('Get in touch →'),
                      ),
                  ],
                ),
            ],
          ),
        );
        final featured =
            content.projects
                .where((p) => p.featured && p.gallery.isNotEmpty)
                .toList()
              ..sort((a, b) => a.featuredOrder.compareTo(b.featuredOrder));
        final visual = featured.isEmpty
            ? const SizedBox.shrink()
            : Entrance(
                index: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('A glimpse of the work', color: Design.muted),
                    const SizedBox(height: 14),
                    ProjectMedia(project: featured.first, compact: true),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${featured.first.title} · ${featured.first.category}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Design.muted,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/projects/${featured.first.slug}',
                          ),
                          child: const Text('Explore ↗'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 3, child: intro),
                  const SizedBox(width: 60),
                  Expanded(flex: 2, child: visual),
                ],
              )
            else
              intro,
            SizedBox(height: width < 600 ? 24 : 36),
            const Divider(),
            SizedBox(height: width < 600 ? 18 : 26),
            LayoutBuilder(
              builder: (context, statsWidth) {
                final stats = content.list('stats');
                final mobile = width < 600;
                return Wrap(
                  spacing: mobile ? 12 : 48,
                  runSpacing: 20,
                  children: stats.map((stat) {
                    final value = Text(
                      (stat['value'] ?? '').toString(),
                      style: TextStyle(
                        fontSize: mobile ? 26 : 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    );
                    final label = Text(
                      (stat['label'] ?? '').toString(),
                      style: TextStyle(
                        fontSize: mobile ? 10 : 12,
                        height: 1.6,
                        color: Design.muted,
                      ),
                    );
                    return mobile
                        ? SizedBox(
                            width: (statsWidth.maxWidth - 24) / 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                value,
                                const SizedBox(height: 4),
                                label,
                              ],
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              value,
                              const SizedBox(width: 14),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 140,
                                ),
                                child: label,
                              ),
                            ],
                          );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    ),
  );
}

class SelectedWork extends StatelessWidget {
  final PublicContent content;
  const SelectedWork({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final projects = content.projects.where((p) => p.featured).toList()
      ..sort((a, b) => a.featuredOrder.compareTo(b.featuredOrder));
    if (projects.isEmpty) return const SizedBox.shrink();
    return ContentWidth(
      vertical: MediaQuery.sizeOf(context).width < 600 ? 24 : 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            number: '01 / Selected work',
            title: content.text('projectsTitle', 'Selected work.'),
            description: content.text('projectsDescription'),
            trailing: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/projects'),
              label: Text('All projects (${content.projects.length})'),
              icon: const Icon(Icons.north_east, size: 18),
              iconAlignment: IconAlignment.end,
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 24 : 36),
          ProjectGrid(projects: projects.take(4).toList()),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ProjectGrid extends StatelessWidget {
  final List<ProjectModel> projects;
  const ProjectGrid({super.key, required this.projects});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth >= 700 ? 2 : 1;
      const gap = 32.0;
      return Wrap(
        spacing: gap,
        runSpacing: 48,
        children: [
          for (var i = 0; i < projects.length; i++)
            SizedBox(
              width: (c.maxWidth - gap * (cols - 1)) / cols,
              child: Entrance(
                key: ValueKey(projects[i].id),
                index: i,
                child: ProjectPreview(project: projects[i], index: i),
              ),
            ),
        ],
      );
    },
  );
}

class ProjectPreview extends StatelessWidget {
  final ProjectModel project;
  final int index;
  const ProjectPreview({super.key, required this.project, this.index = 0});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MotionSurface(
        borderRadius: BorderRadius.circular(Design.radius),
        onTap: () => Navigator.pushNamed(
          context,
          '/projects/${project.slug.isEmpty ? project.id : project.slug}',
        ),
        child: Semantics(
          button: true,
          label: 'Explore ${project.title}',
          child: ProjectMedia(project: project),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: Text(
              project.title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                letterSpacing: -.8,
              ),
            ),
          ),
          IconButton(
            tooltip: 'View ${project.title}',
            onPressed: () => Navigator.pushNamed(
              context,
              '/projects/${project.slug.isEmpty ? project.id : project.slug}',
            ),
            icon: const Icon(Icons.north_east, size: 20),
          ),
        ],
      ),
      Eyebrow(project.category, color: Design.muted),
      const SizedBox(height: 10),
      Text(
        project.description,
        style: const TextStyle(fontSize: 14, height: 1.75, color: Design.muted),
      ),
      if (project.capabilities.isNotEmpty) ...[
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: project.capabilities
              .take(3)
              .map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Design.line),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Design.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        children: [
          if (project.googlePlayUrl.isNotEmpty)
            ExternalAction(
              label: 'Google Play',
              url: project.googlePlayUrl,
              icon: Icons.android,
            ),
          if (project.appStoreUrl.isNotEmpty)
            ExternalAction(
              label: 'App Store',
              url: project.appStoreUrl,
              icon: Icons.apple,
            ),
        ],
      ),
    ],
  );
}

class ExperienceBlock extends StatelessWidget {
  final PublicContent content;
  const ExperienceBlock({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final list = content.list('experiences');
    if (list.isEmpty) return const SizedBox.shrink();
    return ContentWidth(
      vertical: 64,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          const SizedBox(height: 56),
          SectionHeading(
            number: '02 / Experience',
            title: content.text('experienceTitle', 'Experience.'),
            description: content.text('experienceDescription'),
          ),
          const SizedBox(height: 40),
          for (final e in list)
            Entrance(
              key: ValueKey(e['id'] ?? e['company']),
              index: list.indexOf(e),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final left = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow((e['period'] ?? '').toString()),
                        const SizedBox(height: 12),
                        Text(
                          (e['company'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (e['location'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Design.muted,
                          ),
                        ),
                      ],
                    );
                    final right = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (e['title'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.7,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (e['description'] ?? '').toString(),
                          style: const TextStyle(
                            color: Design.muted,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 18),
                        for (final a in (e['achievements'] as List? ?? []))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Icon(
                                    Icons.circle,
                                    size: 4,
                                    color: Design.accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    a.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.75,
                                      color: Design.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                    return c.maxWidth >= 750
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: left),
                              const SizedBox(width: 64),
                              Expanded(flex: 2, child: right),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [left, const SizedBox(height: 24), right],
                          );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PackagesBlock extends StatelessWidget {
  final PublicContent content;
  const PackagesBlock({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final packages = content.list('packages');
    if (packages.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Design.tint,
      child: ContentWidth(
        vertical: 64,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              number: '03 / Open source',
              title: content.text(
                'packagesTitle',
                'Open-source Flutter packages.',
              ),
              description: content.text('packagesDescription'),
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 800 ? 3 : 1;
                return Wrap(
                  spacing: 36,
                  runSpacing: 32,
                  children: [
                    for (var i = 0; i < packages.length; i++)
                      SizedBox(
                        width: (c.maxWidth - 36 * (cols - 1)) / cols,
                        child: Entrance(
                          index: i,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.data_object,
                                    size: 22,
                                    color: Design.accent,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '0${i + 1}',
                                    style: const TextStyle(
                                      color: Design.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Text(
                                (packages[i]['name'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.7,
                                ),
                              ),
                              if ((packages[i]['subtitle'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  packages[i]['subtitle'].toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Text(
                                (packages[i]['description'] ?? '').toString(),
                                style: const TextStyle(
                                  color: Design.muted,
                                  fontSize: 14,
                                  height: 1.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ExternalAction(
                                label: 'View on pub.dev',
                                url: (packages[i]['url'] ?? '').toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CapabilitiesBlock extends StatelessWidget {
  final PublicContent content;
  const CapabilitiesBlock({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final skills = content.list('technical_skills');
    if (skills.isEmpty) return const SizedBox.shrink();
    return ContentWidth(
      vertical: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            number: '04 / Capabilities',
            title: content.text('skillsTitle'),
            description: content.text('skillsDescription'),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 900
                  ? 3
                  : c.maxWidth >= 550
                  ? 2
                  : 1;
              return Wrap(
                spacing: 36,
                runSpacing: 36,
                children: skills
                    .map(
                      (s) => SizedBox(
                        width: (c.maxWidth - 36 * (cols - 1)) / cols,
                        child: Entrance(
                          index: skills.indexOf(s) % cols,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 20),
                              Text(
                                (s['name'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (s['description'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Design.muted,
                                  height: 1.7,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                (s['items'] as List? ?? []).join(' · '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Design.accent,
                                  height: 1.9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              for (final id in (s['projectIds'] as List? ?? []))
                                for (final p in content.projects.where(
                                  (p) => p.id == id,
                                ))
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/projects/${p.slug}',
                                    ),
                                    child: Text('See ${p.title} ↗'),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          if (content.list('soft_skills').isNotEmpty) ...[
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: content
                  .list('soft_skills')
                  .map(
                    (s) => Text(
                      '${s['name']} · ${s['description']}',
                      style: const TextStyle(fontSize: 13, color: Design.muted),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (content.list('tools').isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              content.list('tools').map((s) => s['name']).join(' · '),
              style: const TextStyle(
                color: Design.muted,
                fontSize: 13,
                height: 1.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AboutBlock extends StatelessWidget {
  final PublicContent content;
  const AboutBlock({super.key, required this.content});
  @override
  Widget build(BuildContext context) => ContentWidth(
    vertical: 24,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 48),
        LayoutBuilder(
          builder: (context, c) {
            final about = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeading(
                  number: '05 / The person behind the work',
                  title: content.text('aboutTitle'),
                ),
                const SizedBox(height: 24),
                Text(
                  content.text('aboutDescription'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Design.muted,
                    height: 1.85,
                  ),
                ),
                for (final feature in content.list('about_features'))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '${feature['title']} — ${feature['description']}',
                      style: const TextStyle(color: Design.muted, height: 1.8),
                    ),
                  ),
              ],
            );
            final education = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Education'),
                const SizedBox(height: 20),
                for (final e in content.list('education')) ...[
                  Text(
                    (e['title'] ?? '').toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (e['institution'] ?? '').toString(),
                    style: const TextStyle(fontSize: 14, color: Design.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (e['period'] ?? '').toString(),
                    style: const TextStyle(fontSize: 12, color: Design.muted),
                  ),
                  const SizedBox(height: 16),
                  if ((e['description'] ?? '').toString().isNotEmpty)
                    Text(
                      e['description'].toString(),
                      style: const TextStyle(color: Design.muted, height: 1.7),
                    ),
                ],
                if (content.text('languages').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Eyebrow('Languages'),
                  const SizedBox(height: 12),
                  Text(
                    content.text('languages'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Design.muted,
                      height: 1.9,
                    ),
                  ),
                ],
              ],
            );
            return c.maxWidth >= 800
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: Entrance(child: about)),
                      const SizedBox(width: 100),
                      Expanded(
                        flex: 2,
                        child: Entrance(index: 1, child: education),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Entrance(child: about),
                      const SizedBox(height: 40),
                      Entrance(index: 1, child: education),
                    ],
                  );
          },
        ),
        const SizedBox(height: 64),
      ],
    ),
  );
}

class ContactBlock extends StatelessWidget {
  final PublicContent content;
  const ContactBlock({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    color: Design.ink,
    child: ContentWidth(
      vertical: 64,
      child: Entrance(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow(
              '06 / Start a conversation',
              color: Color(0xFF9FCCBC),
            ),
            const SizedBox(height: 24),
            Text(
              content.text('contactTitle'),
              style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width < 600 ? 40 : 62,
                height: 1.15,
                fontWeight: FontWeight.w600,
                letterSpacing: -2,
                color: Design.paper,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              content.text('contactDescription'),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFBDCAC3),
                height: 1.8,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Design.paper,
                    foregroundColor: Design.ink,
                  ),
                  onPressed: () => openLink(
                    context,
                    'mailto:${content.text('contactEmail')}',
                  ),
                  icon: const Icon(Icons.north_east, size: 18),
                  label: Text(content.text('contactEmail')),
                ),
                if (content.profile['contactFormEnabled'] == true)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Design.paper,
                      side: const BorderSide(color: Color(0xFF849B8F)),
                    ),
                    onPressed: () => showContentDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => ContactFormDialog(
                        email: content.text('contactEmail'),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Send a message'),
                  ),
                if (content.text('contactPhone').isNotEmpty)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Design.paper),
                    onPressed: () => openLink(
                      context,
                      'tel:${content.text('contactPhone')}',
                    ),
                    child: Text(content.text('contactPhone')),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                for (final social in content.list('social_links'))
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFBDCAC3),
                    ),
                    onPressed: () =>
                        openLink(context, (social['url'] ?? '').toString()),
                    label: Text(
                      (social['label'] ?? social['icon'] ?? 'Link').toString(),
                    ),
                    icon: const Icon(Icons.north_east, size: 15),
                    iconAlignment: IconAlignment.end,
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class PortfolioFooter extends StatelessWidget {
  final PublicContent content;
  const PortfolioFooter({super.key, required this.content});
  @override
  Widget build(BuildContext context) => ContentWidth(
    vertical: 26,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 32,
      runSpacing: 14,
      children: [
        Text(
          '${content.text('name')} · ${content.text('professionalTitle', content.text('badge'))}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Design.muted,
          ),
        ),
        Text(
          content.text('copyright').isEmpty
              ? '© ${DateTime.now().year} ${content.text('name')}'
              : content.text('copyright'),
          style: const TextStyle(fontSize: 12, color: Design.muted),
        ),
      ],
    ),
  );
}
