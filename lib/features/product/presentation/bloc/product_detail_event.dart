part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadProductDetail extends ProductDetailEvent {
  const LoadProductDetail(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}
