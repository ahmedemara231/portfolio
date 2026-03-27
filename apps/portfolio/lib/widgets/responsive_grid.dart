import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.columns,
    this.spacing = 24,
    this.runSpacing = 24,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += columns) {
      final rowItems = <Widget>[];
      for (int j = 0; j < columns; j++) {
        if (j > 0) rowItems.add(SizedBox(width: spacing));
        if (i + j < children.length) {
          rowItems.add(Expanded(child: children[i + j]));
        } else {
          rowItems.add(const Expanded(child: SizedBox.shrink()));
        }
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: runSpacing));
      rows.add(
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowItems),
      );
    }
    return Column(children: rows);
  }
}
