import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/review.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';

/// Reviews tab showing customer reviews
class ReviewsTab extends StatefulWidget {
  const ReviewsTab({super.key});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VendorBloc>().add(const VendorReviewsLoadMoreRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorBloc, VendorState>(
      builder: (context, state) {
        if (state.reviewsStatus == VendorStatus.loading &&
            state.reviews.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.roseGold),
          );
        }

        if (state.reviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: AppColors.warmGray,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    'No reviews yet',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Be the first to leave a review!',
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

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSpacing.medium),
          itemCount: state.reviews.length + (state.canLoadMoreReviews ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.reviews.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.medium),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.roseGold),
                ),
              );
            }

            final review = state.reviews[index];
            return _ReviewCard(review: review);
          },
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusMedium,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: AppColors.blushRose,
                radius: 20,
                child: Text(
                  (review.reviewerName ?? 'A')[0].toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.roseGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),

              // Name and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName ?? 'Anonymous',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateFormat.format(review.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmGray,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: AppColors.warning,
                  );
                }),
              ),
            ],
          ),

          // Comment
          if (review.comment != null) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              review.comment!,
              style: AppTypography.bodyMedium,
            ),
          ],

          // Vendor Response
          if (review.hasResponse) ...[
            const SizedBox(height: AppSpacing.medium),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.blushRose.withAlpha(128),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.reply,
                        size: 16,
                        color: AppColors.roseGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Vendor\'s Response',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.roseGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.micro),
                  Text(
                    review.vendorResponse!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
