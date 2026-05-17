import 'package:flutter/material.dart';
import '../config/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_color';
  static final _storage = <String, String>{};

  ThemeColor _color = ThemeColor.black;

  ThemeColor get color => _color;
  ThemeData get theme => AppTheme.getTheme(_color);

  ThemeProvider() {
    final saved = _storage[_key];
    if (saved != null) {
      _color = ThemeColor.values.firstWhere((e) => e.name == saved, orElse: () => ThemeColor.black);
    }
  }

  void setColor(ThemeColor color) {
    _color = color;
    _storage[_key] = color.name;
    notifyListeners();
  }
}