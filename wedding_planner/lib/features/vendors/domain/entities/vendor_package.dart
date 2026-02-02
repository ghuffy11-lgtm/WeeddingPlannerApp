/// Vendor package entity
class VendorPackage {
  final String id;
  final String name;
  final String? description;
  final double price;
  final List<String> features;
  final int? durationHours;
  final bool isPopular;

  const VendorPackage({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.features = const [],
    this.durationHours,
    this.isPopular = false,
  });

  /// Format price with currency
  String formatPrice({String currency = 'KWD'}) {
    final priceStr = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    return '$currency $priceStr';
  }

  /// Format duration
  String? get durationDisplay {
    if (durationHours == null) return null;
    if (durationHours! < 1) return '${(durationHours! * 60).round()} minutes';
    if (durationHours! == 1) return '1 hour';
    if (durationHours! < 24) return '${durationHours!.round()} hours';
    final days = (durationHours! / 24).round();
    return days == 1 ? '1 day' : '$days days';
  }
}
