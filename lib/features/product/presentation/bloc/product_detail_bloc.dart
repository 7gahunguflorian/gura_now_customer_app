import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shop/domain/entities/product.dart';
import '../../domain/usecases/product_usecases.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc
    extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({required GetProductByIdUseCase getProductByIdUseCase})
      : _getProductById = getProductByIdUseCase,
        super(const ProductDetailState()) {
    on<LoadProductDetail>(_onLoad);
  }

  final GetProductByIdUseCase _getProductById;

  Future<void> _onLoad(
    LoadProductDetail event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(state.copyWith(status: ProductDetailStatus.loading, clearError: true));
    final result = await _getProductById(ProductIdParam(event.productId));
    result.fold(
      (f) => emit(state.copyWith(
          status: ProductDetailStatus.failure, error: f.message)),
      (product) => emit(state.copyWith(
          status: ProductDetailStatus.success, product: product)),
    );
  }
}
