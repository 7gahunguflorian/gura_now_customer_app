import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/review_bloc.dart';
import '../widgets/review_form_modal.dart';
import '../widgets/star_rating_widget.dart';

class ReviewsListScreen extends StatefulWidget {
  const ReviewsListScreen({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  final String targetId;
  final String targetType;
  final String targetName;

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ReviewBloc>();
    if (widget.targetType == 'shop') {
      bloc.add(ReviewShopRequested(widget.targetId));
    } else {
      bloc.add(ReviewProductRequested(widget.targetId));
    }
    bloc.add(ReviewSummaryRequested(
        targetId: widget.targetId, targetType: widget.targetType));
  }

  void _showReviewForm() async {
    await showReviewFormModal(
      context: context,
      targetName: widget.targetName,
      reviewType: widget.targetType,
      shopId: widget.targetType == 'shop' ? widget.targetId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            title: Text('Avis sur ${widget.targetName}',
                style: AppTextStyles.heading3),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.rate_review_rounded),
                onPressed: _showReviewForm,
                tooltip: 'Écrire un avis',
              ),
            ],
          ),
          body: state.listStatus == ReviewListStatus.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : state.listStatus == ReviewListStatus.failure
                  ? Center(
                      child: Text(state.error ?? 'Erreur',
                          style: AppTextStyles.bodyMedium))
                  : _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(ReviewState state) {
    if (state.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rate_review_rounded,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('Aucun avis pour le moment.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showReviewForm,
              icon: const Icon(Icons.add),
              label: const Text('Écrire le premier avis'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('d MMM yyyy', 'fr');

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: state.reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final review = state.reviews[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      review.userName.isNotEmpty
                          ? review.userName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.userName, style: AppTextStyles.bodySmall),
                        Text(
                            dateFormat.format(review.createdAt),
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  StarRatingWidget(rating: review.rating, size: 16),
                ],
              ),
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(review.comment!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ],
          ),
        );
      },
    );
  }
}
