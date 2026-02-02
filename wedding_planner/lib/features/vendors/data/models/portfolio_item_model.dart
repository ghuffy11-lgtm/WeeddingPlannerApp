import '../../domain/entities/portfolio_item.dart';

/// Portfolio item data model for JSON serialization
class PortfolioItemModel extends PortfolioItem {
  const PortfolioItemModel({
    required super.id,
    required super.imageUrl,
    super.caption,
    super.displayOrder,
  });

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'caption': caption,
      'display_order': displayOrder,
    };
  }
}
