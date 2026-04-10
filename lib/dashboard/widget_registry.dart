import 'package:flutter/material.dart';
import '../models/widget_config.dart';

typedef WidgetBuilder = Widget Function(WidgetConfig config);

class WidgetRegistry {
  static final Map<String, WidgetBuilder> _registry = {};

  static void register(String typeKey, WidgetBuilder builder) {
    _registry[typeKey] = builder;
  }

  static Widget build(String typeKey, WidgetConfig config) {
    final builder = _registry[typeKey];
    if (builder == null) return const SizedBox.shrink();
    return builder(config);
  }
}
