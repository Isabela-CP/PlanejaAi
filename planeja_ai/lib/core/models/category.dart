class AppCategory {
  final String id;
  final String name;
  final String colorHex;
  final String iconName;
  final String type;

  const AppCategory({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
    this.type = 'transaction',
  });

  factory AppCategory.fromJson(Map<String, dynamic> json) {
    return AppCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as String? ?? '#888888',
      iconName: json['iconName'] as String? ?? 'help-circle',
      type: json['type'] as String? ?? 'transaction',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'colorHex': colorHex,
        'iconName': iconName,
        'type': type,
      };

  /// Converts a colorHex string like '#FF5733' to a Flutter Color int.
  int get colorValue {
    final hex = colorHex.replaceFirst('#', '');
    return int.parse('FF$hex', radix: 16);
  }
}
