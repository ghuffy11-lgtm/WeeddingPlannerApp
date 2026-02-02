import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/portfolio_item.dart';

/// Portfolio tab showing vendor's work
class PortfolioTab extends StatelessWidget {
  final List<PortfolioItem> portfolio;

  const PortfolioTab({
    super.key,
    required this.portfolio,
  });

  void _showFullImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenGallery(
          portfolio: portfolio,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (portfolio.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: AppColors.warmGray,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'No portfolio yet',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'This vendor hasn\'t added any work samples',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.warmGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.small,
        crossAxisSpacing: AppSpacing.small,
      ),
      itemCount: portfolio.length,
      itemBuilder: (context, index) {
        final item = portfolio[index];
        return GestureDetector(
          onTap: () => _showFullImage(context, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.blushRose,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.roseGold,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.blushRose,
                child: const Icon(
                  Icons.image,
                  color: AppColors.warmGray,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Full screen gallery viewer
class _FullScreenGallery extends StatefulWidget {
  final List<PortfolioItem> portfolio;
  final int initialIndex;

  const _FullScreenGallery({
    required this.portfolio,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.portfolio.length}',
          style: AppTypography.labelLarge.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.portfolio.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = widget.portfolio[index];
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.roseGold,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: AppColors.error,
                        size: 64,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.portfolio[_currentIndex].caption != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: AppSpacing.medium,
                right: AppSpacing.medium,
                top: AppSpacing.medium,
                bottom: AppSpacing.medium + MediaQuery.of(context).padding.bottom,
              ),
              color: AppColors.black.withAlpha(179),
              child: Text(
                widget.portfolio[_currentIndex].caption!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
