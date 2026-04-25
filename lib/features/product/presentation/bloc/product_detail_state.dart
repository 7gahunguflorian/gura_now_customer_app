part of 'product_detail_bloc.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.error,
  });

  final ProductDetailStatus status;
  final Product? product;
  final String? error;

  @override
  List<Object?> get props => [status, product, error];

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? product,
    String? error,
    bool clearError = false,
  }) =>
      ProductDetailState(
        status: status ?? this.status,
        product: product ?? this.product,
        error: clearError ? null : (error ?? this.error),
      );
}
