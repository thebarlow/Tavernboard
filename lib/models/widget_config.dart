class WidgetConfig {
  final String typeKey;
  final Map<String, dynamic> settings;

  const WidgetConfig({
    required this.typeKey,
    this.settings = const {},
  });

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => WidgetConfig(
    typeKey: json['type_key'] as String,
    settings: (json['settings'] as Map<String, dynamic>?) ?? {},
  );

  Map<String, dynamic> toJson() => {
    'type_key': typeKey,
    'settings': settings,
  };
}
