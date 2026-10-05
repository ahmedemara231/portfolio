import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class Design {
  static const paper = Color(0xFFF6F5F0);
  static const surface = Color(0xFFFFFEFA);
  static const ink = Color(0xFF192E2B);
  static const muted = Color(0xFF5B6B65);
  static const accent = Color(0xFF08786F);
  static const tint = Color(0xFFE6EEE8);
  static const line = Color(0xFFD9DED6);
  static const error = Color(0xFFB53333);
  static const radius = 16.0;
  static const fieldRadius = 8.0;
  static const unit = 8.0;
  static const maxWidth = 1200.0;
  static const fast = Duration(milliseconds: 160);
  static const motion = Duration(milliseconds: 380);
  static const font = 'packages/core/Manrope';
  static const sectionType = TextStyle(
    fontSize: 44,
    height: 1.16,
    letterSpacing: -1.6,
    fontWeight: FontWeight.w700,
  );
  static const pageType = TextStyle(
    fontSize: 34,
    letterSpacing: -1.2,
    fontWeight: FontWeight.w700,
  );
  static const groupType = TextStyle(
    fontSize: 22,
    letterSpacing: -.5,
    fontWeight: FontWeight.w700,
  );
  static const bodyType = TextStyle(fontSize: 16, height: 1.7, color: muted);
  static const captionType = TextStyle(fontSize: 12, height: 1.6, color: muted);
  static const shadow = BoxShadow(
    color: Color(0x14192E2B),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: font,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: paper,
      colorScheme: const ColorScheme.light(
        primary: accent,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: ink,
        error: error,
        outline: line,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 350),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorMaxLines: 3,
        labelStyle: const TextStyle(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(fieldRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(fieldRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(fieldRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: font,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ink,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: tint,
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: const TextStyle(fontFamily: font, fontSize: 13, color: ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _EditorialTransition(),
          TargetPlatform.iOS: _EditorialTransition(),
          TargetPlatform.macOS: _EditorialTransition(),
          TargetPlatform.windows: _EditorialTransition(),
          TargetPlatform.linux: _EditorialTransition(),
        },
      ),
    );
  }
}

class _EditorialTransition extends PageTransitionsBuilder {
  const _EditorialTransition();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => Design.reduced(context)
      ? child
      : FadeTransition(opacity: animation, child: child);
}

class ContentWidth extends StatelessWidget {
  final Widget child;
  final double vertical;
  const ContentWidth({super.key, required this.child, this.vertical = 0});
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Design.maxWidth + 64),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 600 ? 22 : 40,
          vertical: vertical,
        ),
        child: child,
      ),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const Eyebrow(this.text, {super.key, this.color = Design.accent});
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 2,
      color: color,
      height: 1.7,
    ),
  );
}

class SectionHeading extends StatelessWidget {
  final String number, title, description;
  final Widget? trailing;
  const SectionHeading({
    super.key,
    required this.number,
    required this.title,
    this.description = '',
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(number),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              title,
              style: Design.sectionType.copyWith(
                fontSize: c.maxWidth < 600 ? 32 : 44,
              ),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 630),
              child: Text(
                description,
                style: Design.bodyType.copyWith(
                  fontSize: c.maxWidth < 600 ? 14 : 16,
                ),
              ),
            ),
          ],
        ],
      );
      if (trailing == null) return text;
      if (c.maxWidth < 700)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [text, const SizedBox(height: 12), trailing!],
        );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: text),
          const SizedBox(width: 24),
          trailing!,
        ],
      );
    },
  );
}

class PortfolioBrand extends StatelessWidget {
  final String name;
  final bool compact;
  const PortfolioBrand({
    super.key,
    this.name = 'Ahmed Emara',
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Design.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'ae.',
          style: TextStyle(
            color: Design.paper,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -1.5,
          ),
        ),
      ),
      if (!compact) ...[
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            name,
            maxLines: 2,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: -.4,
            ),
          ),
        ),
      ],
    ],
  );
}

class Entrance extends StatelessWidget {
  final Widget child;
  final int index;
  const Entrance({super.key, required this.child, this.index = 0});
  @override
  Widget build(BuildContext context) {
    if (Design.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index.clamp(0, 5) * 70),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: .8 + .2 * t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final bool active;
  const StatusPill(this.label, {super.key, this.active = true});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: active ? Design.tint : Design.paper,
      border: Border.all(color: Design.line),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 6,
          color: active ? Design.accent : Design.muted,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Design.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> openLink(BuildContext context, String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null || !{'https', 'http', 'mailto', 'tel'}.contains(uri.scheme))
    return;
  try {
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault))
      throw StateError('Unavailable');
  } catch (_) {
    if (context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this link. Please try again.'),
        ),
      );
  }
}

class ExternalAction extends StatelessWidget {
  final String label, url;
  final IconData icon;
  final bool outlined;
  const ExternalAction({
    super.key,
    required this.label,
    required this.url,
    this.icon = Icons.north_east,
    this.outlined = false,
  });
  @override
  Widget build(BuildContext context) => outlined
      ? OutlinedButton.icon(
          onPressed: () => openLink(context, url),
          icon: Icon(icon, size: 16),
          label: Text(label),
        )
      : TextButton.icon(
          onPressed: () => openLink(context, url),
          label: Text(label),
          icon: Icon(icon, size: 16),
          iconAlignment: IconAlignment.end,
        );
}

class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final Widget? action;
  const StateMessage({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Design.accent),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Design.muted, height: 1.6),
        ),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

/// Give modal copy its own semantics nodes instead of merging it into the
/// dialog role, which can hide static text from web screen readers.
class ContentDialog extends StatelessWidget {
  final String label;
  final Widget child;
  final EdgeInsets insetPadding;
  final ShapeBorder? shape;
  const ContentDialog({
    super.key,
    required this.label,
    required this.child,
    this.insetPadding = const EdgeInsets.all(16),
    this.shape,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: label,
    child: Dialog(
      insetPadding: insetPadding,
      shape: shape,
      child: Semantics(container: true, explicitChildNodes: true, child: child),
    ),
  );
}
