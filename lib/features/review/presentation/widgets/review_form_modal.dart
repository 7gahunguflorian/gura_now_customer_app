import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/review_bloc.dart';
import 'star_rating_widget.dart';

/// Modal dialog for submitting a review (dark theme).
class ReviewFormModal extends StatefulWidget {
  const ReviewFormModal({
    super.key,
    this.orderId,
    this.shopId,
    this.driverId,
    required this.targetName,
    required this.reviewType,
    this.onSubmit,
  });
  final String? orderId;
  final String? shopId;
  final String? driverId;
  final String targetName;
  final String reviewType;
  final Function(int rating, String? comment)? onSubmit;

  @override
  State<ReviewFormModal> createState() => _ReviewFormModalState();
}

class _ReviewFormModalState extends State<ReviewFormModal> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez donner une note'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final comment = _commentController.text.trim().isEmpty
        ? null
        : _commentController.text.trim();
    final targetId = widget.shopId ?? widget.driverId ?? '';
    final targetType = widget.reviewType;
    if (targetId.isNotEmpty) {
      context.read<ReviewBloc>().add(ReviewSubmitRequested(
            targetId: targetId,
            targetType: targetType,
            rating: _rating,
            comment: comment,
            orderId: widget.orderId,
          ));
    }
    await widget.onSubmit?.call(_rating, comment);
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: AppColors.borderGray)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Évaluer ${widget.targetName}',
                  style: AppTextStyles.heading4,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.reviewType == 'shop'
                      ? 'Comment était votre expérience d\'achat?'
                      : 'Comment était la livraison?',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                StarRatingWidget(
                  rating: _rating,
                  size: 48,
                  onRatingChanged: (rating) => setState(() => _rating = rating),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingText(_rating),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _rating > 0 ? AppColors.primary : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 500,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Partagez votre expérience (optionnel)...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                            ),
                          )
                        : Text(
                            'Envoyer',
                            style: AppTextStyles.buttonLarge.copyWith(color: AppColors.textOnPrimary),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Très mauvais';
      case 2:
        return 'Mauvais';
      case 3:
        return 'Correct';
      case 4:
        return 'Bien';
      case 5:
        return 'Excellent!';
      default:
        return 'Touchez les étoiles pour noter';
    }
  }
}

Future<bool?> showReviewFormModal({
  required BuildContext context,
  required String targetName,
  required String reviewType,
  String? orderId,
  String? shopId,
  String? driverId,
  Function(int rating, String? comment)? onSubmit,
}) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewFormModal(
        orderId: orderId,
        shopId: shopId,
        driverId: driverId,
        targetName: targetName,
        reviewType: reviewType,
        onSubmit: onSubmit,
      ),
    );
