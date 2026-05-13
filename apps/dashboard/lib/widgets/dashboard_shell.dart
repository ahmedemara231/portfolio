import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../theme/dashboard_theme.dart';
import '../pages/overview_page.dart';
import '../pages/projects_page.dart';
import '../pages/skills_page.dart';
import '../pages/experience_page.dart';
import '../pages/messages_page.dart';
import '../pages/settings_page.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const _navItems = [
  _NavItem(Icons.dashboard_outlined, 'Overview'),
  _NavItem(Icons.folder_outlined, 'Projects'),
  _NavItem(Icons.star_outline, 'Skills'),
  _NavItem(Icons.work_outline, 'Experience'),
  _NavItem(Icons.mail_outline, 'Messages'),
  _NavItem(Icons.settings_outlined, 'Settings'),
];

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;
  bool _sidebarOpen = false;

  void _goTo(int index) {
    setState(() {
      _selectedIndex = index;
      _sidebarOpen = false;
    });
  }

  late final List<Widget> _pages = <Widget>[
    OverviewPage(onNavigate: _goTo),
    const ProjectsPage(),
    const SkillsPage(),
    const ExperiencePage(),
    const MessagesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar for desktop
          if (isDesktop) _buildSidebar(),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Mobile header
                if (!isDesktop) _buildMobileHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(isDesktop ? 32 : 16),
                        child: _pages[_selectedIndex],
                      ),
                      // Mobile sidebar overlay
                      if (!isDesktop && _sidebarOpen) ...[
                        GestureDetector(
                          onTap: () => setState(() => _sidebarOpen = false),
                          child: Container(color: Colors.black54),
                        ),
                        _buildSidebar(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: DashboardColors.card,
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: Row(
        children: [
          Text('Admin Dashboard',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(
            icon: Icon(_sidebarOpen ? Icons.close : Icons.menu),
            onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Material(
      color: DashboardColors.card,
      child: SizedBox(
        width: 256,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admin Dashboard',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DashboardColors.primary)),
                  const SizedBox(height: 4),
                  Text('Portfolio Manager',
                      style: TextStyle(
                          fontSize: 14,
                          color: DashboardColors.mutedForeground)),
                ],
              ),
            ),
            // Nav items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final selected = _selectedIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _goTo(i),
                      hoverColor: DashboardColors.accent,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: selected
                              ? DashboardColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(item.icon,
                                  size: 20,
                                  color: selected
                                      ? DashboardColors.primaryForeground
                                      : DashboardColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(item.label,
                                    style: TextStyle(
                                      color: selected
                                          ? DashboardColors.primaryForeground
                                          : DashboardColors.primary,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                              if (item.label == 'Messages')
                                StreamBuilder<int>(
                                  stream: FirestoreService
                                      .unreadMessagesCountStream(),
                                  builder: (context, snap) {
                                    final unread = snap.data ?? 0;
                                    if (unread == 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? DashboardColors.primaryForeground
                                            : DashboardColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '$unread',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? DashboardColors.primary
                                              : DashboardColors
                                                  .primaryForeground,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: DashboardColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SidebarButton(
                    icon: Icons.home_outlined,
                    label: 'View Portfolio',
                    onTap: () {},
                  ),
                  const SizedBox(height: 4),
                  _SidebarButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    color: DashboardColors.destructive,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? DashboardColors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      hoverColor: DashboardColors.accent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(color: c, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
