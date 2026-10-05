import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'press_event.dart';

final _pressObservers = <void Function(BrowserPress)>{};
final _activePresses = <int>{};
JSFunction? _pointerFeedback, _keyFeedback, _blurFeedback;

// PointerEvent coordinates can be fractional, while the inherited MouseEvent
// getters in package:web are typed as integers. Preserve CSS pixel precision.
@JS()
extension type _PressCoordinates(JSObject _) implements JSObject {
  external double get clientX;
  external double get clientY;
}

/// Flutter web debounces pointer events on accessible buttons for 200ms.
/// Observe the original events for immediate visual feedback, while leaving
/// all click, focus, scrolling, and keyboard handling to Flutter.
void Function() watchPressFeedback(void Function(BrowserPress) callback) {
  void notify(BrowserPress press) {
    for (final observer in _pressObservers.toList()) {
      observer(press);
    }
  }

  if (_pressObservers.isEmpty) {
    _pointerFeedback = ((web.PointerEvent event) {
      if (!event.isPrimary) return;
      if (event.type == 'pointerdown') {
        if (event.button != 0) return;
        final target = event.target;
        if (target == null || !target.isA<web.Element>()) return;
        final button = (target as web.Element).closest('[role="button"]');
        if (button == null || button.getAttribute('aria-disabled') == 'true')
          return;
        _activePresses.add(event.pointerId);
      } else if (!_activePresses.contains(event.pointerId)) {
        return;
      }
      final phase = switch (event.type) {
        'pointerdown' => PressPhase.down,
        'pointermove' => PressPhase.move,
        _ => PressPhase.end,
      };
      if (phase == PressPhase.end) _activePresses.remove(event.pointerId);
      final coordinates = _PressCoordinates(event);
      notify(
        BrowserPress(
          event.pointerId,
          coordinates.clientX,
          coordinates.clientY,
          phase,
        ),
      );
    }).toJS;
    _keyFeedback = ((web.KeyboardEvent event) {
      if (event.key != 'Enter' && event.key != ' ') return;
      if (event.type == 'keyup') {
        notify(const BrowserPress(-1, 0, 0, PressPhase.end));
        return;
      }
      if (event.repeat) return;
      final active = web.document.activeElement;
      if (active?.getAttribute('role') != 'button' ||
          active?.getAttribute('aria-disabled') == 'true')
        return;
      final rect = active!.getBoundingClientRect();
      notify(
        BrowserPress(
          -1,
          rect.x + rect.width / 2,
          rect.y + rect.height / 2,
          PressPhase.down,
        ),
      );
    }).toJS;
    _blurFeedback = ((web.Event event) {
      _activePresses.clear();
      notify(const BrowserPress(-1, 0, 0, PressPhase.clear));
    }).toJS;
    for (final type in [
      'pointerdown',
      'pointermove',
      'pointerup',
      'pointercancel',
    ]) {
      web.window.addEventListener(type, _pointerFeedback, true.toJS);
    }
    for (final type in ['keydown', 'keyup']) {
      web.window.addEventListener(type, _keyFeedback, true.toJS);
    }
    web.window.addEventListener('blur', _blurFeedback);
  }
  _pressObservers.add(callback);
  return () {
    _pressObservers.remove(callback);
    if (_pressObservers.isNotEmpty) return;
    for (final type in [
      'pointerdown',
      'pointermove',
      'pointerup',
      'pointercancel',
    ]) {
      web.window.removeEventListener(type, _pointerFeedback, true.toJS);
    }
    for (final type in ['keydown', 'keyup']) {
      web.window.removeEventListener(type, _keyFeedback, true.toJS);
    }
    web.window.removeEventListener('blur', _blurFeedback);
    _activePresses.clear();
    _pointerFeedback = _keyFeedback = _blurFeedback = null;
  };
}

void watchStorage(String key, void Function() callback) {
  web.window.addEventListener(
    'storage',
    ((web.StorageEvent event) {
      if (event.key == key || event.key == 'flutter.$key') callback();
    }).toJS,
  );
}

JSFunction? _unload;
void protectUnsavedChanges(bool dirty) {
  if (_unload != null) web.window.removeEventListener('beforeunload', _unload);
  _unload = null;
  if (dirty) {
    _unload = ((web.BeforeUnloadEvent event) {
      event.preventDefault();
      event.returnValue = '';
    }).toJS;
    web.window.addEventListener('beforeunload', _unload);
  }
}

void updatePageMetadata({
  required String title,
  required String description,
  String canonical = '',
  String image = '',
  bool noIndex = false,
}) {
  if (image.startsWith('/') && canonical.isNotEmpty)
    image = Uri.parse(canonical).resolve(image).toString();
  web.document.title = title;
  void meta(String name, String content, {bool property = false}) {
    final attr = property ? 'property' : 'name';
    final element =
        web.document.querySelector('meta[$attr="$name"]') ??
        web.document.createElement('meta');
    element.setAttribute(attr, name);
    element.setAttribute('content', content);
    if (element.parentNode == null) web.document.head?.appendChild(element);
  }

  meta('description', description);
  meta('og:title', title, property: true);
  meta('og:description', description, property: true);
  meta('og:image', image, property: true);
  meta('og:url', canonical, property: true);
  meta('twitter:title', title);
  meta('twitter:description', description);
  meta('twitter:image', image);
  meta('robots', noIndex ? 'noindex, nofollow' : 'index, follow');
  final link =
      web.document.querySelector('link[rel="canonical"]') ??
      web.document.createElement('link');
  link.setAttribute('rel', 'canonical');
  link.setAttribute('href', canonical);
  if (link.parentNode == null) web.document.head?.appendChild(link);
}

void downloadFile(String url, String filename) {
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.target = '_blank';
  anchor.rel = 'noopener';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
