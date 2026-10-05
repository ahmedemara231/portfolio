import 'dart:js_interop';
import 'package:web/web.dart' as web;

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
