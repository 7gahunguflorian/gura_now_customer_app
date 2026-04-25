part of 'shop_bloc.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();
  @override
  List<Object?> get props => [];
}

class ShopListRequested extends ShopEvent {
  const ShopListRequested({this.category});
  final String? category;
  @override
  List<Object?> get props => [category];
}

class ShopDetailRequested extends ShopEvent {
  const ShopDetailRequested(this.shopId);
  final String shopId;
  @override
  List<Object?> get props => [shopId];
}

class ShopCategoryFilterChanged extends ShopEvent {
  const ShopCategoryFilterChanged(this.category);
  final String? category;
  @override
  List<Object?> get props => [category];
}

class ShopProductsRequested extends ShopEvent {
  const ShopProductsRequested(this.shopId);
  final String shopId;
  @override
  List<Object?> get props => [shopId];
}
