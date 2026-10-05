import 'dart:convert';
import 'dart:ui' as ui;
import 'package:core/core.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MediaUpload {
  static Future<Map<String, dynamic>?> pickImage(String projectId) async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Application screenshots',
          extensions: ['png', 'jpg', 'jpeg', 'webp'],
          mimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
        ),
      ],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final limit = FirestoreService.useFirebase ? 8 * 1024 * 1024 : 900 * 1024;
    if (bytes.length > limit) {
      throw StateError(
        FirestoreService.useFirebase
            ? 'Choose an image smaller than 8 MB.'
            : 'For local preview, choose an optimized image smaller than 900 KB.',
      );
    }
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final width = frame.image.width, height = frame.image.height;
    frame.image.dispose();
    codec.dispose();
    if (width > 8000 || height > 8000) {
      throw StateError(
        'Resize this screenshot to less than 8000 pixels per side.',
      );
    }
    final ext = file.name.split('.').last.toLowerCase();
    final mime = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
        ? 'image/webp'
        : 'image/jpeg';
    final thumbnailCodec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 370,
      allowUpscaling: false,
    );
    final thumbnailFrame = await thumbnailCodec.getNextFrame();
    final thumbnailData = await thumbnailFrame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    thumbnailFrame.image.dispose();
    thumbnailCodec.dispose();
    final thumbnailBytes = thumbnailData!.buffer.asUint8List();
    String url, thumbnail;
    if (FirestoreService.useFirebase) {
      final path =
          'projects/$projectId/${DateTime.now().microsecondsSinceEpoch}.$ext';
      // No download tokens: draft media is protected by Storage rules too.
      await FirebaseStorage.instance
          .ref(path)
          .putData(bytes, SettableMetadata(contentType: mime));
      url = 'storage://$path';
      final thumbnailPath =
          'projects/$projectId/${DateTime.now().microsecondsSinceEpoch}-thumb.png';
      await FirebaseStorage.instance
          .ref(thumbnailPath)
          .putData(thumbnailBytes, SettableMetadata(contentType: 'image/png'));
      thumbnail = 'storage://$thumbnailPath';
    } else {
      url = 'data:$mime;base64,${base64Encode(bytes)}';
      thumbnail = 'data:image/png;base64,${base64Encode(thumbnailBytes)}';
    }
    return {
      'url': url,
      'thumbnail': thumbnail,
      'alt': '',
      'width': width,
      'height': height,
      'filename': file.name,
    };
  }

  static Future<String?> pickCv() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'PDF document',
          extensions: ['pdf'],
          mimeTypes: ['application/pdf'],
        ),
      ],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length < 5 ||
        utf8.decode(bytes.take(5).toList(), allowMalformed: true) != '%PDF-') {
      throw StateError('Choose a valid PDF file.');
    }
    if (bytes.length >
        (FirestoreService.useFirebase ? 5 * 1024 * 1024 : 900 * 1024)) {
      throw StateError('This PDF is too large. Optimize it before uploading.');
    }
    if (!FirestoreService.useFirebase) {
      return 'data:application/pdf;base64,${base64Encode(bytes)}';
    }
    final path = 'cv/${DateTime.now().microsecondsSinceEpoch}.pdf';
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'application/pdf',
        contentDisposition: 'attachment; filename="Ahmed-Emara-CV.pdf"',
      ),
    );
    // CVs are intentionally public, unlike project drafts.
    return ref.getDownloadURL();
  }
}
