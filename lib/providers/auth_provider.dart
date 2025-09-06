import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already exists (in a real app, this would be an API call)
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('users') ?? [];
      
      for (final userJson in existingUsers) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.email == email) {
          _setError('User with this email already exists');
          return;
        }
      }

      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        username: username,
        createdAt: DateTime.now(),
      );

      // Save user to local storage
      existingUsers.add(jsonEncode(newUser.toJson()));
      await prefs.setStringList('users', existingUsers);

      // Set current user
      _currentUser = newUser;
      await prefs.setString('current_user', jsonEncode(newUser.toJson()));

      notifyListeners();
    } catch (e) {
      _setError('Failed to create account: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Check credentials (in a real app, this would be an API call)
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('users') ?? [];
      
      for (final userJson in existingUsers) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.email == email) {
          // In a real app, you would verify the password hash
          _currentUser = user;
          await prefs.setString('current_user', jsonEncode(user.toJson()));
          notifyListeners();
          return;
        }
      }

      _setError('Invalid email or password');
    } catch (e) {
      _setError('Failed to sign in: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  Future<void> updateProfile({
    String? username,
    String? profileImage,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        username: username,
        profileImage: profileImage,
      );

      // Update in local storage
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('users') ?? [];
      
      for (int i = 0; i < existingUsers.length; i++) {
        final user = User.fromJson(jsonDecode(existingUsers[i]));
        if (user.id == _currentUser!.id) {
          existingUsers[i] = jsonEncode(updatedUser.toJson());
          break;
        }
      }
      
      await prefs.setStringList('users', existingUsers);
      await prefs.setString('current_user', jsonEncode(updatedUser.toJson()));

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
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
