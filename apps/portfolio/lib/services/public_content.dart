import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class PublicContent extends ChangeNotifier {
  Map<String, dynamic> profile = {};
  final Map<String, List<MapEntry<String, Map<String, dynamic>>>> collections =
      {};
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<String> _pending = {
    'profile',
    ...FirestoreService.publicCollections,
  };
  String? error;
  bool get loading => _pending.isNotEmpty;
  PublicContent() {
    connect();
  }
  String text(String key, [String fallback = '']) =>
      (profile[key] ?? fallback).toString();
  List<Map<String, dynamic>> list(String name) =>
      collections[name]?.map((e) => e.value).toList() ?? [];
  List<ProjectModel> get projects => (collections['projects'] ?? [])
      .map((e) => ProjectModel.fromMap(e.value, e.key))
      .toList();
  void connect() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    error = null;
    _pending.addAll({'profile', ...FirestoreService.publicCollections});
    _subscriptions.add(
      FirestoreService.profileStream().listen((data) {
        profile = data ?? {};
        _pending.remove('profile');
        notifyListeners();
      }, onError: _onError),
    );
    for (final name in FirestoreService.publicCollections) {
      _subscriptions.add(
        FirestoreService.collectionStreamWithIds(
          name,
          publishedOnly: true,
        ).listen((data) {
          collections[name] = data;
          _pending.remove(name);
          notifyListeners();
        }, onError: _onError),
      );
    }
  }

  void _onError(Object e) {
    error = 'Portfolio content is temporarily unavailable.';
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
