import '../../domain/entities/category.dart';

/// Category data model for JSON serialization
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.icon,
    super.vendorCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      vendorCount: json['vendorCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'vendorCount': vendorCount,
    };
  }
}
