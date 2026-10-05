import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../content_schema.dart';
import '../pages/collection_page.dart';
import '../pages/overview_page.dart';
import '../pages/settings_page.dart';
import '../pages/messages_page.dart';
import '../services/studio_content.dart';
import 'studio_widgets.dart';

const navigation = [
  (Icons.space_dashboard_outlined, 'Overview'),
  (Icons.folder_outlined, 'Projects'),
  (Icons.star_outline, 'Featured work'),
  (Icons.work_outline, 'Experience'),
  (Icons.data_object, 'Flutter packages'),
  (Icons.layers_outlined, 'Capabilities'),
  (Icons.school_outlined, 'Education'),
  (Icons.person_outline, 'Profile & contact'),
  (Icons.verified_outlined, 'Credibility'),
  (Icons.link, 'Social links'),
  (Icons.travel_explore, 'Search & sharing'),
  (Icons.inbox_outlined, 'Messages'),
  (Icons.more_horiz, 'More content'),
];

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});
  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int selected = 0;
  String projectFilter = 'All';
  final scaffold = GlobalKey<ScaffoldState>();
  late final content = StudioContent();
  @override
  void dispose() {
    content.dispose();
    super.dispose();
  }

  void go(int index) {
    setState(() {
      selected = index;
      projectFilter = 'All';
    });
    if (scaffold.currentState?.isDrawerOpen ?? false) Navigator.pop(context);
  }

  void showProjects(String filter) => setState(() {
    selected = 1;
    projectFilter = filter;
  });

  Widget page() => switch (selected) {
    0 => OverviewPage(
      content: content,
      onNavigate: go,
      onProjectFilter: showProjects,
    ),
    1 => CollectionPage(schema: projectSchema, initialStatus: projectFilter),
    2 => CollectionPage(
      schema: projectSchema,
      featuredOnly: true,
      onManageProjects: () => go(1),
    ),
    3 => CollectionPage(schema: schemas[1]),
    4 => CollectionPage(schema: schemas[2]),
    5 => CollectionPage(schema: schemas[3]),
    6 => CollectionPage(schema: schemas[4]),
    7 => SettingsPage(content: content),
    8 => CollectionPage(schema: schemas[5]),
    9 => CollectionPage(schema: schemas[6]),
    10 => SettingsPage(content: content, metadata: true),
    11 => const MessagesPage(),
    _ => const MoreContentPage(),
  };
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1050;
    return ListenableBuilder(
      listenable: content,
      builder: (context, _) => Scaffold(
        key: scaffold,
        drawer: desktop
            ? null
            : Drawer(
                width: 280,
                backgroundColor: Design.surface,
                child: sidebar(),
              ),
        body: Row(
          children: [
            if (desktop)
              SizedBox(
                width: 264,
                child: Material(color: Design.surface, child: sidebar()),
              ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Design.surface,
                      border: Border(bottom: BorderSide(color: Design.line)),
                    ),
                    child: Row(
                      children: [
                        if (!desktop)
                          IconButton(
                            tooltip: 'Open studio navigation',
                            onPressed: () =>
                                scaffold.currentState?.openDrawer(),
                            icon: const Icon(Icons.menu),
                          ),
                        if (!desktop)
                          const PortfolioLogo(size: 36, semanticLabel: null),
                        const SizedBox(width: 12),
                        if (desktop) ...[
                          const Eyebrow('Portfolio Studio'),
                          Container(
                            width: 1,
                            height: 18,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            color: Design.line,
                          ),
                        ],
                        Expanded(
                          child: Tooltip(
                            message: navigation[selected].$2,
                            child: Text(
                              navigation[selected].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final url =
                                FirestoreService.useFirebase &&
                                    !FirestoreService.useEmulators
                                ? content.text('siteUrl')
                                : ({'http', 'https'}.contains(Uri.base.scheme)
                                      ? Uri.base.origin
                                      : 'http://localhost:4173');
                            return TextButton.icon(
                              onPressed: url.isEmpty
                                  ? null
                                  : () => openLink(context, url),
                              label: Text(
                                MediaQuery.sizeOf(context).width < 500
                                    ? 'Preview'
                                    : 'Open portfolio',
                              ),
                              icon: const Icon(Icons.north_east, size: 16),
                              iconAlignment: IconAlignment.end,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!FirestoreService.useFirebase)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      color: Design.tint,
                      child: const Text(
                        'Local preview · Changes are saved in this browser. Production data is untouched.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Design.accent,
                          height: 1.6,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(desktop ? 36 : 20),
                      child: Entrance(
                        key: ValueKey((selected, projectFilter)),
                        scrollTriggered: false,
                        distance: 10,
                        child: page(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sidebar() => Container(
    decoration: const BoxDecoration(
      border: Border(right: BorderSide(color: Design.line)),
    ),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: PortfolioBrand(name: content.text('name', 'Ahmed Emara')),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              'Your portfolio, thoughtfully maintained.',
              style: TextStyle(fontSize: 10, color: Design.muted),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final group in const [
                  ('Workspace', [0]),
                  ('Public portfolio', [7, 8, 1, 2, 3, 4, 5, 6]),
                  ('Contact & publishing', [9, 10, 11]),
                  ('Existing content', [12]),
                ]) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Text(
                      group.$1.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Design.muted,
                      ),
                    ),
                  ),
                  for (final i in group.$2)
                    ListTile(
                      selected: i == selected,
                      selectedTileColor: Design.tint,
                      selectedColor: Design.accent,
                      minVerticalPadding: 8,
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(navigation[i].$1, size: 19),
                      title: Text(
                        navigation[i].$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: i == selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      onTap: () => go(i),
                    ),
                ],
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FirestoreService.useFirebase
                ? TextButton.icon(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign out'),
                  )
                : const Text(
                    'LOCAL WORKSPACE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Design.muted,
                      letterSpacing: 1.6,
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

class MoreContentPage extends StatelessWidget {
  const MoreContentPage({super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StudioPageHeader(
          eyebrow: 'Existing content',
          title: 'More content',
          description:
              'Maintain the additional collections kept from your earlier portfolio. Your current public sections are available in the main navigation.',
        ),
        const SizedBox(height: 24),
        for (final schema in schemas.skip(7))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(schema.title),
              subtitle: Text(
                schema.description,
                style: const TextStyle(color: Design.muted, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward, size: 18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(schema.title)),
                    body: Padding(
                      padding: const EdgeInsets.all(24),
                      child: CollectionPage(schema: schema),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
