import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';
import '../models/chat_message.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('orders') ?? [];
      
      _orders = ordersJson
          .map((json) => Order.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load orders: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createOrder(Order order) async {
    _setLoading(true);
    _clearError();

    try {
      _orders.insert(0, order);
      await _saveOrders();
      notifyListeners();
    } catch (e) {
      _setError('Failed to create order: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        await _saveOrders();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update order: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addMessageToOrder(String orderId, ChatMessage message) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final updatedMessages = List<ChatMessage>.from(_orders[index].messages)
          ..add(message);
        
        _orders[index] = _orders[index].copyWith(
          messages: updatedMessages,
          updatedAt: DateTime.now(),
        );
        await _saveOrders();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add message: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  List<Order> getOrdersForUser(String userId, {bool isSeller = false}) {
    if (isSeller) {
      return _orders.where((o) => o.sellerId == userId).toList();
    } else {
      return _orders.where((o) => o.buyerId == userId).toList();
    }
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<Order> getPendingOrdersForSeller(String sellerId) {
    return _orders.where((o) => 
      o.sellerId == sellerId && o.status == OrderStatus.pending
    ).toList();
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = _orders
        .map((order) => jsonEncode(order.toJson()))
        .toList();
    await prefs.setStringList('orders', ordersJson);
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
