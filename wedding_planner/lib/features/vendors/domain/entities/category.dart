/// Category entity for vendor categories
class Category {
  final String id;
  final String name;
  final String? icon;
  final int? vendorCount;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.vendorCount,
  });

  /// Get the emoji icon or a fallback
  String get displayIcon => icon ?? _getCategoryIcon(name);

  /// Get default icon based on category name
  static String _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('photo')) return 'camera_alt';
    if (lowerName.contains('video')) return 'videocam';
    if (lowerName.contains('cater')) return 'restaurant';
    if (lowerName.contains('cake')) return 'cake';
    if (lowerName.contains('music') || lowerName.contains('dj')) return 'music_note';
    if (lowerName.contains('flower')) return 'local_florist';
    if (lowerName.contains('decor')) return 'celebration';
    if (lowerName.contains('venue')) return 'location_on';
    if (lowerName.contains('makeup') || lowerName.contains('beauty')) return 'face';
    if (lowerName.contains('wedding dress') || lowerName.contains('attire')) return 'checkroom';
    if (lowerName.contains('invitation')) return 'mail';
    if (lowerName.contains('transport')) return 'directions_car';
    return 'store';
  }
}
