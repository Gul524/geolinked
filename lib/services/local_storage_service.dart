import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  LocalStorageService._internal();

  static final LocalStorageService instance = LocalStorageService._internal();

  static const String _defaultBoxName = 'geolinked_box';

  Box<dynamic>? _defaultBox;

  Future<void> init({String boxName = _defaultBoxName}) async {
    await Hive.initFlutter();
    _defaultBox = await Hive.openBox<dynamic>(boxName);
  }

  Future<void> put(String key, dynamic value) async {
    await _ensureReady();
    await _defaultBox!.put(key, value);
  }

  T? get<T>(String key) {
    if (_defaultBox == null) {
      return null;
    }
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

  bool containsKey(String key) {
    if (_defaultBox == null) {
      return false;
    }
    return _defaultBox!.containsKey(key);
  }

  Future<void> _ensureReady() async {
    if (_defaultBox != null) {
      return;
    }
    await init();
  }
}
