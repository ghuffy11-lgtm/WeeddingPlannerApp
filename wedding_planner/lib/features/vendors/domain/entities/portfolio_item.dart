/// Portfolio item entity
class PortfolioItem {
  final String id;
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  const PortfolioItem({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.displayOrder = 0,
  });
}
