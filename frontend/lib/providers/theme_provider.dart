import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _key = 'theme_color';

  ThemeColor _color = ThemeColor.black;

  ThemeColor get color => _color;
  ThemeData get theme => AppTheme.getTheme(_color);

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final saved = await _storage.read(key: _key);
    if (saved != null) {
      _color = ThemeColor.values.firstWhere((e) => e.name == saved, orElse: () => ThemeColor.black);
    }
    notifyListeners();
  }

  Future<void> setColor(ThemeColor color) async {
    _color = color;
    await _storage.write(key: _key, value: color.name);
    notifyListeners();
  }
}