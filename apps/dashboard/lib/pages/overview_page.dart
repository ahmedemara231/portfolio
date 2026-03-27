import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../theme/dashboard_theme.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text('Dashboard Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Welcome back! Here's what's happening with your portfolio.",
              style: TextStyle(color: DashboardColors.mutedForeground)),
          const SizedBox(height: 24),

          // Stats Grid
          _StatsGrid(),
          const SizedBox(height: 24),

          // Charts Row
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _DownloadsChart()),
                    const SizedBox(width: 24),
                    Expanded(child: _ProjectPerformance()),
                  ],
                );
              }
              return Column(
                children: [
                  _DownloadsChart(),
                  const SizedBox(height: 24),
                  _ProjectPerformance(),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Activity & Quick Actions
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _RecentActivity()),
                    const SizedBox(width: 24),
                    Expanded(child: _QuickActions()),
                  ],
                );
              }
              return Column(
                children: [
                  _RecentActivity(),
                  const SizedBox(height: 24),
                  _QuickActions(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
      stream: FirestoreService.collectionStreamWithIds('stats'),
      builder: (context, statsSnap) {
        return StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
          stream: FirestoreService.collectionStreamWithIds('projects'),
          builder: (context, projSnap) {
            final stats = statsSnap.data ?? [];
            final projectCount = projSnap.data?.length ?? 0;

            final cards = <_StatData>[
              _StatData(Icons.folder_outlined, 'Total Projects', '$projectCount', '+2'),
            ];
            for (final e in stats) {
              final s = e.value;
              cards.add(_StatData(
                Icons.trending_up,
                s['label'] ?? '',
                s['value'] ?? '',
                '',
              ));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 500
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, i) => _StatCard(data: cards[i]),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final String change;
  const _StatData(this.icon, this.label, this.value, this.change);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DashboardColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: DashboardColors.primary),
              ),
              if (data.change.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.trending_up, size: 16, color: DashboardColors.green),
                    const SizedBox(width: 4),
                    Text(data.change,
                        style: const TextStyle(fontSize: 12, color: DashboardColors.green)),
                  ],
                ),
            ],
          ),
          const Spacer(),
          Text(data.value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(data.label,
              style: const TextStyle(fontSize: 13, color: DashboardColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _DownloadsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [15000, 22000, 28000, 35000, 42000, 50000];
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Downloads Overview',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _AreaChartPainter(data, labels, maxVal),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<int> data;
  final List<String> labels;
  final double maxVal;

  _AreaChartPainter(this.data, this.labels, this.maxVal);

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 50.0;
    const bottomPad = 30.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = DashboardColors.border
      ..strokeWidth = 1;
    final textStyle = const TextStyle(fontSize: 10, color: DashboardColors.mutedForeground);

    for (int i = 0; i <= 4; i++) {
      final y = chartH * (1 - i / 4);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '${(maxVal * i / 4 / 1000).toInt()}K', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 8, y - tp.height / 2));
    }

    // Data points & area
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = leftPad + (chartW / (data.length - 1)) * i;
      final y = chartH * (1 - data[i] / maxVal);
      points.add(Offset(x, y));

      // Labels
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 8));
    }

    // Area fill
    final areaPath = Path()..moveTo(points.first.dx, chartH);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(points.last.dx, chartH);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          DashboardColors.primary.withValues(alpha: 0.3),
          DashboardColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftPad, 0, chartW, chartH));
    canvas.drawPath(areaPath, areaPaint);

    // Line
    final linePaint = Paint()
      ..color = DashboardColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = DashboardColors.primary;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProjectPerformance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<String, Map<String, dynamic>>>>(
      stream: FirestoreService.collectionStreamWithIds('projects'),
      builder: (context, snap) {
        final projects = snap.data ?? [];
        final top5 = projects.take(5).toList();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DashboardColors.card,
            border: Border.all(color: DashboardColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Top Projects Performance',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ...top5.map((e) {
                final p = e.value;
                final title = p['title'] ?? '';
                final dl = p['downloads'] ?? '0';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(title,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(dl,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _parseDownloads(dl) / 100000,
                          minHeight: 8,
                          backgroundColor: DashboardColors.accent,
                          valueColor: const AlwaysStoppedAnimation(DashboardColors.primary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  double _parseDownloads(String dl) {
    final cleaned = dl.replaceAll(RegExp(r'[^0-9.]'), '');
    final num = double.tryParse(cleaned) ?? 0;
    if (dl.contains('K')) return num * 1000;
    return num;
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      ('Updated project', 'E-Commerce App', '2 hours ago'),
      ('Added new skill', 'GraphQL', '5 hours ago'),
      ('Published project', 'Task Management', '1 day ago'),
      ('Updated experience', 'Senior Flutter Developer', '2 days ago'),
      ('Received review', 'Food Delivery', '3 days ago'),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Icon(Icons.timeline, size: 20, color: DashboardColors.mutedForeground),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: const BoxDecoration(
                        color: DashboardColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: a.$1,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            TextSpan(
                                text: '  ${a.$2}',
                                style: const TextStyle(
                                    color: DashboardColors.mutedForeground, fontSize: 13)),
                          ])),
                          const SizedBox(height: 2),
                          Text(a.$3,
                              style: const TextStyle(
                                  fontSize: 12, color: DashboardColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.folder_outlined, 'Add Project', 'Create new project'),
      (Icons.people_outline, 'Add Experience', 'Update work history'),
      (Icons.star_outline, 'Update Skills', 'Add new skills'),
      (Icons.message_outlined, 'View Messages', '3 new messages'),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.card,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: actions.map((a) {
              return Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: DashboardColors.border),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  hoverColor: DashboardColors.accent,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(a.$1, color: DashboardColors.primary),
                        const SizedBox(height: 8),
                        Text(a.$2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13)),
                        Text(a.$3,
                            style: const TextStyle(
                                fontSize: 12, color: DashboardColors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
