import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import '../web/browser.dart';

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
  static const press = Duration(milliseconds: 90);
  static const release = Duration(milliseconds: 220);
  static const reveal = Duration(milliseconds: 560);
  static const transition = Duration(milliseconds: 260);
  static const ease = Curves.easeOutCubic;
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
      visualDensity: VisualDensity.standard,
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
        ).copyWith(foregroundBuilder: _buttonMotion, animationDuration: fast),
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
        ).copyWith(foregroundBuilder: _buttonMotion, animationDuration: fast),
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
        ).copyWith(foregroundBuilder: _buttonMotion, animationDuration: fast),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: font,
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(foregroundBuilder: _buttonMotion, animationDuration: fast),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ink,
        ).copyWith(foregroundBuilder: _buttonMotion, animationDuration: fast),
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

  // Native button states also cover keyboard activation and disabled controls.
  // Animate the contents while the 48px target and focus outline stay stable.
  static Widget _buttonMotion(
    BuildContext context,
    Set<WidgetState> states,
    Widget? child,
  ) {
    if (child == null) return const SizedBox.shrink();
    final disabled = states.contains(WidgetState.disabled);
    final pressed = !disabled && states.contains(WidgetState.pressed);
    final hovered = !disabled && states.contains(WidgetState.hovered);
    return _InteractionMotion(
      enabled: !disabled,
      pressed: pressed,
      hovered: hovered,
      button: true,
      child: child,
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
  ) {
    if (Design.reduced(context)) return child;
    final curved = animation.drive(CurveTween(curve: Design.ease));
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: curved.drive(
          Tween(begin: const Offset(0, .018), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
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
  Widget build(BuildContext context) => Entrance(
    distance: 18,
    child: LayoutBuilder(
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
    ),
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

/// Reveals once, when the content actually reaches its scroll viewport.
/// Content remains fully visible until visibility can be measured. After the
/// reveal, scroll listeners are removed; scrolling never drives an animation.
class Entrance extends StatefulWidget {
  final Widget child;
  final int index;
  final double distance;
  final bool scrollTriggered;
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.distance = 24,
    this.scrollTriggered = true,
  });
  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController controller = AnimationController(
    vsync: this,
    value: 1,
  );
  ScrollPosition? position;
  bool revealed = false, scheduled = false, reduced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = Design.reduced(context);
    if (reduced) {
      revealed = true;
      controller.stop();
      controller.value = 1;
    }
    final next = !revealed && widget.scrollTriggered
        ? Scrollable.maybeOf(context)?.position
        : null;
    if (next != position) {
      position?.removeListener(scheduleCheck);
      position = next;
      position?.addListener(scheduleCheck);
    }
    scheduleCheck();
  }

  @override
  void didChangeMetrics() => scheduleCheck();

  void scheduleCheck() {
    if (revealed || scheduled || reduced || !mounted) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (!mounted || revealed || reduced) return;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) return;
      final bounds = box.localToGlobal(Offset.zero) & box.size;
      final viewport = RenderAbstractViewport.maybeOf(box);
      var visible = Offset.zero & MediaQuery.sizeOf(context);
      if (viewport case final RenderBox viewportBox) {
        if (viewportBox.hasSize) {
          visible = viewportBox.localToGlobal(Offset.zero) & viewportBox.size;
        }
      }
      if (widget.scrollTriggered &&
          (!bounds.overlaps(visible) || bounds.top > visible.bottom - 32)) {
        return;
      }
      revealed = true;
      position?.removeListener(scheduleCheck);
      position = null;
      controller.duration = Duration(
        milliseconds:
            baseDuration.inMilliseconds + widget.index.clamp(0, 3) * 55,
      );
      controller.forward(from: 0);
    });
  }

  Duration get baseDuration =>
      widget.scrollTriggered ? Design.reveal : Design.transition;

  @override
  Widget build(BuildContext context) {
    scheduleCheck();
    if (reduced) return widget.child;
    final delay = widget.index.clamp(0, 3) * 55;
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        final t = Interval(
          delay / (baseDuration.inMilliseconds + delay),
          1,
          curve: Design.ease,
        ).transform(controller.value);
        return Opacity(
          opacity: .78 + .22 * t,
          child: Transform.translate(
            offset: Offset(0, widget.distance * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    position?.removeListener(scheduleCheck);
    controller.dispose();
    super.dispose();
  }
}

/// Material keeps native tap, keyboard, focus, and semantics behavior. Only the
/// painted surface moves; its layout and hit target never shrink or shift.
class MotionSurface extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final BorderRadius borderRadius;
  final BorderSide border;
  const MotionSurface({
    super.key,
    required this.child,
    required this.onTap,
    this.color = Colors.transparent,
    this.borderRadius = const BorderRadius.all(Radius.circular(Design.radius)),
    this.border = BorderSide.none,
  });
  @override
  State<MotionSurface> createState() => _MotionSurfaceState();
}

class _MotionSurfaceState extends State<MotionSurface> {
  bool hovered = false, pressed = false, focused = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final lifted = enabled && (hovered || focused);
    final down = enabled && pressed;
    return _InteractionMotion(
      enabled: enabled,
      pressed: down,
      hovered: lifted,
      child: Material(
        color: widget.color,
        shape: RoundedRectangleBorder(
          borderRadius: widget.borderRadius,
          side: widget.border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          onHover: (v) => setState(() => hovered = v),
          onHighlightChanged: (v) => setState(() => pressed = v),
          onFocusChange: (v) => setState(() => focused = v),
          child: widget.child,
        ),
      ),
    );
  }
}

class _InteractionMotion extends StatefulWidget {
  final bool enabled, pressed, hovered, button;
  final Widget child;
  const _InteractionMotion({
    required this.enabled,
    required this.pressed,
    required this.hovered,
    required this.child,
    this.button = false,
  });
  @override
  State<_InteractionMotion> createState() => _InteractionMotionState();
}

class _InteractionMotionState extends State<_InteractionMotion> {
  late final void Function() stopWatching;
  int? pointer;
  Offset? start;
  Timer? releaseTimer;

  @override
  void initState() {
    super.initState();
    stopWatching = watchPressFeedback(browserPress);
  }

  void browserPress(BrowserPress event) {
    if (!mounted) return;
    if (event.phase == PressPhase.clear) {
      releaseTimer?.cancel();
      if (pointer != null) setState(() => pointer = null);
      return;
    }
    if (event.phase == PressPhase.end && event.pointer == pointer) {
      releaseTimer?.cancel();
      // Even a quick accessible click gets a perceptible pulse. Its action
      // still runs immediately; only the painted release is prolonged.
      releaseTimer = Timer(Design.press, () {
        if (mounted) setState(() => pointer = null);
      });
      return;
    }
    final point = Offset(event.x, event.y);
    if (event.phase == PressPhase.move && event.pointer == pointer) {
      // Do not keep a button held while dragging to scroll, or re-arm it.
      if ((point - start!).distanceSquared > 144) {
        releaseTimer?.cancel();
        setState(() => pointer = null);
      }
      return;
    }
    if (event.phase != PressPhase.down ||
        !widget.enabled ||
        Design.reduced(context) ||
        ModalRoute.of(context)?.isCurrent == false)
      return;
    RenderObject? object;
    if (widget.button) {
      context.visitAncestorElements((element) {
        if (element.widget is ButtonStyleButton) {
          object = element.findRenderObject();
          return false;
        }
        return true;
      });
    }
    object ??= context.findRenderObject();
    if (object case final RenderBox box) {
      if (box.attached &&
          box.hasSize &&
          (box.localToGlobal(Offset.zero) & box.size)
              .inflate(widget.button ? 0 : 4)
              .contains(point)) {
        releaseTimer?.cancel();
        setState(() {
          pointer = event.pointer;
          start = point;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Design.reduced(context)) return widget.child;
    final down = widget.enabled && (widget.pressed || pointer != null);
    final hovered = widget.enabled && widget.hovered;
    final duration = down ? Design.press : Design.release;
    if (widget.button) {
      return AnimatedScale(
        scale: down
            ? .93
            : hovered
            ? 1.035
            : 1,
        duration: duration,
        curve: Design.ease,
        child: AnimatedSlide(
          offset: down ? const Offset(0, .025) : Offset.zero,
          duration: duration,
          curve: Design.ease,
          child: widget.child,
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: down
            ? -1
            : hovered
            ? 1
            : 0,
      ),
      duration: duration,
      curve: Design.ease,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, t > 0 ? -4 * t : 0),
        transformHitTests: false,
        child: Transform.scale(
          scale: t < 0 ? 1 + .016 * t : 1,
          transformHitTests: false,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    releaseTimer?.cancel();
    stopWatching();
    super.dispose();
  }
}

/// Old content cannot retain pointer, keyboard, or screen-reader actions.
class MotionSwap extends StatelessWidget {
  final Widget child;
  final Offset offset;
  final Alignment alignment;
  const MotionSwap({
    super.key,
    required this.child,
    this.offset = const Offset(0, .025),
    this.alignment = Alignment.topLeft,
  });
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: Design.reduced(context) ? Duration.zero : Design.transition,
    switchInCurve: Design.ease,
    switchOutCurve: Curves.easeInCubic,
    layoutBuilder: (current, previous) => Stack(
      alignment: alignment,
      children: [
        for (final outgoing in previous)
          Positioned.fill(
            child: ExcludeFocus(
              child: ExcludeSemantics(child: IgnorePointer(child: outgoing)),
            ),
          ),
        if (current != null) current,
      ],
    ),
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween(begin: offset, end: Offset.zero)),
        child: child,
      ),
    ),
    child: child,
  );
}

Future<T?> showContentDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
}) => showDialog<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  barrierDismissible: barrierDismissible,
  animationStyle: Design.reduced(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: Design.transition,
          reverseDuration: Design.fast,
          curve: Design.ease,
          reverseCurve: Curves.easeInCubic,
        ),
  builder: (context) {
    final child = builder(context);
    if (Design.reduced(context)) return child;
    final animation = ModalRoute.of(
      context,
    )!.animation!.drive(CurveTween(curve: Design.ease));
    return ScaleTransition(
      scale: animation.drive(Tween(begin: .96, end: 1.0)),
      child: SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, .02), end: Offset.zero),
        ),
        child: child,
      ),
    );
  },
);

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
