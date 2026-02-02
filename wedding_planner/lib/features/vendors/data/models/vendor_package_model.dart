import '../../domain/entities/vendor_package.dart';

/// Vendor package data model for JSON serialization
class VendorPackageModel extends VendorPackage {
  const VendorPackageModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    super.features,
    super.durationHours,
    super.isPopular,
  });

  factory VendorPackageModel.fromJson(Map<String, dynamic> json) {
    return VendorPackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      durationHours: json['duration_hours'] as int?,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'features': features,
      'duration_hours': durationHours,
      'is_popular': isPopular,
    };
  }
}
