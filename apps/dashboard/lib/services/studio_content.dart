import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// The studio reads the same documents that drive the public portfolio.
class StudioContent extends ChangeNotifier {
  static const collectionNames = [
    'projects',
    'experiences',
    'packages',
    'technical_skills',
    'education',
    'stats',
    'social_links',
  ];
  Map<String, dynamic> profile = {};
  final collections = <String, List<MapEntry<String, Map<String, dynamic>>>>{};
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _pending = <String>{};
  String? error;

  StudioContent() {
    reload();
  }

  bool get loading => _pending.isNotEmpty;
  String text(String key, [String fallback = '']) =>
      (profile[key] ?? fallback).toString();
  List<MapEntry<String, Map<String, dynamic>>> rows(String collection) =>
      collections[collection] ?? [];
  List<Map<String, dynamic>> published(String collection) => rows(collection)
      .where((e) => FirestoreService.isPublished(e.value))
      .map((e) => e.value)
      .toList();
  List<ProjectModel> get projects => rows(
    'projects',
  ).map((e) => ProjectModel.fromMap(e.value, e.key)).toList();
  List<ProjectModel> get featured {
    final selected =
        projects.where((p) => p.featured && p.status == 'published').toList()
          ..sort((a, b) => a.featuredOrder.compareTo(b.featuredOrder));
    return selected.take(4).toList();
  }

  void reload() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    error = null;
    _pending.addAll(['profile', ...collectionNames]);
    _subscriptions.add(
      FirestoreService.profileStream().listen((value) {
        profile = value ?? {};
        _pending.remove('profile');
        notifyListeners();
      }, onError: _failed),
    );
    for (final name in collectionNames) {
      _subscriptions.add(
        FirestoreService.collectionStreamWithIds(name).listen((value) {
          collections[name] = value;
          _pending.remove(name);
          notifyListeners();
        }, onError: _failed),
      );
    }
  }

  void _failed(Object _) {
    error = 'Check your connection and Firebase permissions, then try again.';
    _pending.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
