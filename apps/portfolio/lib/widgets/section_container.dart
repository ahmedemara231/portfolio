import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? extraPadding;

  const SectionContainer({
    super.key,
    required this.child,
    this.extraPadding,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 640 ? 16.0 : (width < 1024 ? 24.0 : 32.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad)
              .add(extraPadding ?? EdgeInsets.zero),
          child: child,
        ),
      ),
    );
  }
}
