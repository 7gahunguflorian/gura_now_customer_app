part of 'review_bloc.dart';

enum ReviewListStatus { initial, loading, success, failure }
enum ReviewSubmitStatus { idle, loading, success, failure }

class ReviewState extends Equatable {
  const ReviewState({
    this.listStatus = ReviewListStatus.initial,
    this.submitStatus = ReviewSubmitStatus.idle,
    this.reviews = const [],
    this.summary,
    this.error,
  });

  final ReviewListStatus listStatus;
  final ReviewSubmitStatus submitStatus;
  final List<Review> reviews;
  final RatingSummary? summary;
  final String? error;

  @override
  List<Object?> get props =>
      [listStatus, submitStatus, reviews, summary, error];

  ReviewState copyWith({
    ReviewListStatus? listStatus,
    ReviewSubmitStatus? submitStatus,
    List<Review>? reviews,
    RatingSummary? summary,
    String? error,
  }) =>
      ReviewState(
        listStatus: listStatus ?? this.listStatus,
        submitStatus: submitStatus ?? this.submitStatus,
        reviews: reviews ?? this.reviews,
        summary: summary ?? this.summary,
        error: error ?? this.error,
      );
}
