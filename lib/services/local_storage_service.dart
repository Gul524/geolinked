import 'package:hive_flutter/hive_flutter.dart';

/// Service to handle local key-value persistence using Hive.
class LocalStorageService {
  LocalStorageService._internal();
  static final LocalStorageService instance = LocalStorageService._internal();

  static const String boxName = 'geolinked_prefs';
  Box<dynamic>? _defaultBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _defaultBox = await Hive.openBox<dynamic>(boxName);
  }

  Future<void> _ensureReady() async {
    if (_defaultBox == null || !_defaultBox!.isOpen) {
      _defaultBox = await Hive.openBox<dynamic>(boxName);
    }
  }

  Future<void> put(String key, dynamic value) async {
    await _ensureReady();
    await _defaultBox!.put(key, value);
  }

  T? get<T>(String key) {
    if (_defaultBox == null) return null;
    final dynamic value = _defaultBox!.get(key);
    return value is T ? value : null;
  }

  Future<void> delete(String key) async {
    await _ensureReady();
    await _defaultBox!.delete(key);
  }

  Future<void> clear() async {
    await _ensureReady();
    await _defaultBox!.clear();
  }
}
