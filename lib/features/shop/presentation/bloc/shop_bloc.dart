import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/shop.dart';
import '../../domain/usecases/get_shop_detail_usecase.dart';
import '../../domain/usecases/get_shop_products_usecase.dart';
import '../../domain/usecases/get_shops_usecase.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc({
    required GetShopsUseCase getShopsUseCase,
    required GetShopDetailUseCase getShopDetailUseCase,
    required GetShopProductsUseCase getShopProductsUseCase,
  })  : _getShopsUseCase = getShopsUseCase,
        _getShopDetailUseCase = getShopDetailUseCase,
        _getShopProductsUseCase = getShopProductsUseCase,
        super(const ShopState()) {
    on<ShopListRequested>(_onListRequested);
    on<ShopDetailRequested>(_onDetailRequested);
    on<ShopCategoryFilterChanged>(_onCategoryFilterChanged);
    on<ShopProductsRequested>(_onProductsRequested);
  }

  final GetShopsUseCase _getShopsUseCase;
  final GetShopDetailUseCase _getShopDetailUseCase;
  final GetShopProductsUseCase _getShopProductsUseCase;

  Future<void> _onListRequested(
    ShopListRequested event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(listStatus: ShopListStatus.loading, listError: null));
    final result = await _getShopsUseCase(GetShopsParams(
      category: event.category ?? state.categoryFilter,
    ));
    result.fold(
      (f) => emit(state.copyWith(
          listStatus: ShopListStatus.failure, listError: f.message)),
      (shops) => emit(state.copyWith(
          listStatus: ShopListStatus.success, shops: shops)),
    );
  }

  Future<void> _onDetailRequested(
    ShopDetailRequested event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(
        detailStatus: ShopDetailStatus.loading,
        detailError: null,
        selectedShop: null));
    final result =
        await _getShopDetailUseCase(GetShopDetailParams(event.shopId));
    result.fold(
      (f) => emit(state.copyWith(
          detailStatus: ShopDetailStatus.failure, detailError: f.message)),
      (shop) => emit(state.copyWith(
          detailStatus: ShopDetailStatus.success, selectedShop: shop)),
    );
  }

  void _onCategoryFilterChanged(
    ShopCategoryFilterChanged event,
    Emitter<ShopState> emit,
  ) {
    emit(state.copyWith(categoryFilter: event.category));
  }

  Future<void> _onProductsRequested(
    ShopProductsRequested event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(
        productsStatus: ShopProductsStatus.loading, productsError: null));
    final result =
        await _getShopProductsUseCase(GetShopProductsParams(event.shopId));
    result.fold(
      (f) => emit(state.copyWith(
          productsStatus: ShopProductsStatus.failure,
          productsError: f.message)),
      (products) => emit(state.copyWith(
          productsStatus: ShopProductsStatus.success, shopProducts: products)),
    );
  }
}
