import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/cart_state.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;
  static const String _storageKey = 'cart_state';

  @override
  Future<List<CartItemModel>> getCart() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return const [];
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final cartModel = CartStateModel.fromJson(json);
    return cartModel.items.cast<CartItemModel>();
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    final cartModel = CartStateModel(items: items);
    final jsonString = jsonEncode(cartModel.toJson());
    await _prefs.setString(_storageKey, jsonString);
  }
}

