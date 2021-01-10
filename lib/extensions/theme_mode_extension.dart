import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

extension ThemeModeExtension on ThemeMode {
  String get name => describeEnum(this);
}
