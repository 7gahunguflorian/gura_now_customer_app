import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../shop/domain/entities/product.dart';
import '../../data/models/cart_item.dart';
import '../../domain/usecases/cart_usecases.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required UpdateCartQuantityUseCase updateCartQuantityUseCase,
    required ClearCartUseCase clearCartUseCase,
  })  : _getCart = getCartUseCase,
        _addToCart = addToCartUseCase,
        _removeFromCart = removeFromCartUseCase,
        _updateQuantity = updateCartQuantityUseCase,
        _clearCart = clearCartUseCase,
        super(const CartState()) {
    on<CartLoadRequested>(_onLoadRequested);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartQuantityUpdated>(_onQuantityUpdated);
    on<CartCleared>(_onCleared);
    add(const CartLoadRequested());
  }

  final GetCartUseCase _getCart;
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;
  final UpdateCartQuantityUseCase _updateQuantity;
  final ClearCartUseCase _clearCart;

  Future<void> _onLoadRequested(
      CartLoadRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading, error: null));
    final result = await _getCart(NoParams());
    result.fold(
      (f) => emit(state.copyWith(
          status: CartStatus.failure, error: f.message, items: const [])),
      (items) => emit(
          state.copyWith(status: CartStatus.success, items: items)),
    );
  }

  Future<void> _onItemAdded(
      CartItemAdded event, Emitter<CartState> emit) async {
    final result = await _addToCart(AddToCartParams(event.product, event.quantity));
    result.fold(
      (f) => emit(state.copyWith(status: CartStatus.failure, error: f.message)),
      (_) {
        final items = List<CartItemModel>.from(state.items);
        final idx = items.indexWhere((i) => i.product.id == event.product.id);
        if (idx >= 0) {
          items[idx] = CartItemModel(
              product: items[idx].product,
              quantity: items[idx].quantity + event.quantity);
        } else {
          items.add(CartItemModel(product: event.product, quantity: event.quantity));
        }
        emit(state.copyWith(items: items));
      },
    );
  }

  Future<void> _onItemRemoved(
      CartItemRemoved event, Emitter<CartState> emit) async {
    final result = await _removeFromCart(event.productId);
    result.fold(
      (f) => emit(state.copyWith(status: CartStatus.failure, error: f.message)),
      (_) {
        final items =
            state.items.where((i) => i.product.id != event.productId).toList();
        emit(state.copyWith(items: items));
      },
    );
  }

  Future<void> _onQuantityUpdated(
      CartQuantityUpdated event, Emitter<CartState> emit) async {
    if (event.quantity <= 0) {
      add(CartItemRemoved(event.productId));
      return;
    }
    final result =
        await _updateQuantity(UpdateCartQuantityParams(event.productId, event.quantity));
    result.fold(
      (f) => emit(state.copyWith(status: CartStatus.failure, error: f.message)),
      (_) {
        final items = List<CartItemModel>.from(state.items);
        final idx = items.indexWhere((i) => i.product.id == event.productId);
        if (idx >= 0) {
          items[idx] = CartItemModel(
              product: items[idx].product, quantity: event.quantity);
          emit(state.copyWith(items: items));
        }
      },
    );
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    final result = await _clearCart(NoParams());
    result.fold(
      (f) => emit(state.copyWith(status: CartStatus.failure, error: f.message)),
      (_) => emit(state.copyWith(items: const [])),
    );
  }
}
