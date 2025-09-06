import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/purchase.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get cartItems => _cartItems;
  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cartItemCount => _cartItems.length;
  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.price);

  Future<void> loadCartAndPurchases() async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cart items
      final cartJson = prefs.getStringList('cart_items') ?? [];
      _cartItems = cartJson
          .map((json) => CartItem.fromJson(jsonDecode(json)))
          .toList();

      // Load purchases
      final purchasesJson = prefs.getStringList('purchases') ?? [];
      _purchases = purchasesJson
          .map((json) => Purchase.fromJson(jsonDecode(json)))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load cart and purchases: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(CartItem item) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if item already exists in cart
      final existingIndex = _cartItems.indexWhere((i) => i.productId == item.productId);
      
      if (existingIndex != -1) {
        _setError('Item already in cart');
        return;
      }

      _cartItems.add(item);
      await _saveCart();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add item to cart: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeFromCart(String productId) async {
    _setLoading(true);
    _clearError();

    try {
      _cartItems.removeWhere((item) => item.productId == productId);
      await _saveCart();
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove item from cart: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearCart() async {
    _setLoading(true);
    _clearError();

    try {
      _cartItems.clear();
      await _saveCart();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear cart: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkout() async {
    _setLoading(true);
    _clearError();

    try {
      // Create purchases from cart items
      final newPurchases = _cartItems.map((item) => Purchase(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${item.productId}',
        productId: item.productId,
        title: item.title,
        price: item.price,
        imageUrl: item.imageUrl,
        sellerUsername: item.sellerUsername,
        purchaseDate: DateTime.now(),
      )).toList();

      _purchases.addAll(newPurchases);
      _cartItems.clear();

      await _saveCart();
      await _savePurchases();
      notifyListeners();
    } catch (e) {
      _setError('Failed to checkout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _cartItems
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList('cart_items', cartJson);
  }

  Future<void> _savePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasesJson = _purchases
        .map((purchase) => jsonEncode(purchase.toJson()))
        .toList();
    await prefs.setStringList('purchases', purchasesJson);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
