part of 'shop_bloc.dart';

enum ShopListStatus { initial, loading, success, failure }
enum ShopDetailStatus { initial, loading, success, failure }
enum ShopProductsStatus { initial, loading, success, failure }

class ShopState extends Equatable {
  const ShopState({
    this.listStatus = ShopListStatus.initial,
    this.shops = const [],
    this.listError,
    this.detailStatus = ShopDetailStatus.initial,
    this.selectedShop,
    this.detailError,
    this.categoryFilter,
    this.productsStatus = ShopProductsStatus.initial,
    this.shopProducts = const [],
    this.productsError,
  });

  final ShopListStatus listStatus;
  final List<Shop> shops;
  final String? listError;
  final ShopDetailStatus detailStatus;
  final Shop? selectedShop;
  final String? detailError;
  final String? categoryFilter;
  final ShopProductsStatus productsStatus;
  final List<Product> shopProducts;
  final String? productsError;

  List<Shop> get filteredShops {
    if (categoryFilter == null || categoryFilter!.isEmpty) return shops;
    return shops.where((s) => s.type == categoryFilter).toList();
  }

  @override
  List<Object?> get props => [
        listStatus,
        shops,
        listError,
        detailStatus,
        selectedShop,
        detailError,
        categoryFilter,
        productsStatus,
        shopProducts,
        productsError,
      ];

  ShopState copyWith({
    ShopListStatus? listStatus,
    List<Shop>? shops,
    String? listError,
    ShopDetailStatus? detailStatus,
    Shop? selectedShop,
    String? detailError,
    String? categoryFilter,
    ShopProductsStatus? productsStatus,
    List<Product>? shopProducts,
    String? productsError,
  }) {
    return ShopState(
      listStatus: listStatus ?? this.listStatus,
      shops: shops ?? this.shops,
      listError: listError,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedShop: selectedShop ?? this.selectedShop,
      detailError: detailError,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      productsStatus: productsStatus ?? this.productsStatus,
      shopProducts: shopProducts ?? this.shopProducts,
      productsError: productsError,
    );
  }
}
