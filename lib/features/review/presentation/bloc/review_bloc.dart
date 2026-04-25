import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/review.dart';
import '../../domain/usecases/review_usecases.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc({
    required GetShopReviewsUseCase getShopReviewsUseCase,
    required GetProductReviewsUseCase getProductReviewsUseCase,
    required SubmitReviewUseCase submitReviewUseCase,
    required GetRatingSummaryUseCase getRatingSummaryUseCase,
  })  : _getShopReviews = getShopReviewsUseCase,
        _getProductReviews = getProductReviewsUseCase,
        _submitReview = submitReviewUseCase,
        _getRatingSummary = getRatingSummaryUseCase,
        super(const ReviewState()) {
    on<ReviewShopRequested>(_onShopRequested);
    on<ReviewProductRequested>(_onProductRequested);
    on<ReviewSubmitRequested>(_onSubmitRequested);
    on<ReviewSummaryRequested>(_onSummaryRequested);
  }

  final GetShopReviewsUseCase _getShopReviews;
  final GetProductReviewsUseCase _getProductReviews;
  final SubmitReviewUseCase _submitReview;
  final GetRatingSummaryUseCase _getRatingSummary;

  Future<void> _onShopRequested(
      ReviewShopRequested event, Emitter<ReviewState> emit) async {
    emit(state.copyWith(listStatus: ReviewListStatus.loading));
    final result = await _getShopReviews(event.shopId);
    result.fold(
      (f) => emit(state.copyWith(
          listStatus: ReviewListStatus.failure, error: f.message)),
      (list) => emit(state.copyWith(
          listStatus: ReviewListStatus.success, reviews: list)),
    );
  }

  Future<void> _onProductRequested(
      ReviewProductRequested event, Emitter<ReviewState> emit) async {
    emit(state.copyWith(listStatus: ReviewListStatus.loading));
    final result = await _getProductReviews(event.productId);
    result.fold(
      (f) => emit(state.copyWith(
          listStatus: ReviewListStatus.failure, error: f.message)),
      (list) => emit(state.copyWith(
          listStatus: ReviewListStatus.success, reviews: list)),
    );
  }

  Future<void> _onSubmitRequested(
      ReviewSubmitRequested event, Emitter<ReviewState> emit) async {
    emit(state.copyWith(submitStatus: ReviewSubmitStatus.loading));
    final result = await _submitReview(SubmitReviewParams(
      targetId: event.targetId,
      targetType: event.targetType,
      rating: event.rating,
      comment: event.comment,
      orderId: event.orderId,
    ));
    result.fold(
      (f) => emit(state.copyWith(
          submitStatus: ReviewSubmitStatus.failure, error: f.message)),
      (review) {
        final updated = [review, ...state.reviews];
        emit(state.copyWith(
            submitStatus: ReviewSubmitStatus.success, reviews: updated));
      },
    );
  }

  Future<void> _onSummaryRequested(
      ReviewSummaryRequested event, Emitter<ReviewState> emit) async {
    final result = await _getRatingSummary(GetRatingSummaryParams(
        targetId: event.targetId, targetType: event.targetType));
    result.fold(
      (_) => null,
      (summary) => emit(state.copyWith(summary: summary)),
    );
  }
}
