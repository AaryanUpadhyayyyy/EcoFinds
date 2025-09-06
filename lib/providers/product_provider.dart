import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  String get searchQuery => _searchQuery;
  ProductCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getStringList('products') ?? [];
      
      _products = productsJson
          .map((json) => Product.fromJson(jsonDecode(json)))
          .toList();
      
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      _products.insert(0, product);
      
      // Save to local storage
      await _saveProducts();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add product: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        await _saveProducts();
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update product: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProduct(String productId) async {
    _setLoading(true);
    _clearError();

    try {
      _products.removeWhere((p) => p.id == productId);
      await _saveProducts();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete product: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  List<Product> getUserProducts(String userId) {
    return _products.where((p) => p.sellerId == userId).toList();
  }

  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Filter by availability
      if (!product.isAvailable) return false;

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.title.toLowerCase().contains(query) &&
            !product.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != null && product.category != _selectedCategory) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = _products
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await prefs.setStringList('products', productsJson);
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
