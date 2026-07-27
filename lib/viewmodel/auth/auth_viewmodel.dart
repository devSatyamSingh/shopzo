import 'package:flutter/material.dart';
import '../../model/auth/login_model.dart';
import '../../model/auth/register_model.dart';
import '../../model/auth/user_model.dart';
import '../../repo/auth/auth_repo.dart';
import '../../utils/app_storage.dart';



class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CustomerModel? _customer;
  CustomerModel? get customer => _customer;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Returns true on success. On success, session (accessToken +
  /// refreshToken + customer) is already saved to AppStorage.
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authRepository.login(
      LoginRequestModel(phone: phone, password: password),
    );

    _setLoading(false);

    if (result.isCompleted && result.data != null) {
      _customer = result.data!.customer;
      await AppStorage.saveSession(
        accessToken: result.data!.accessToken,
        refreshToken: result.data!.refreshToken,
        customer: _customer!.toJson(),
      );
      notifyListeners();
      return true;
    }

    _errorMessage = result.message ?? 'Login failed. Please try again.';
    notifyListeners();
    return false;
  }

  /// Returns true on success. NOTE: register does not return tokens — no
  /// session is saved here. Screen should send the user to Login next.
  Future<bool> register({
    required String name,
    required String phone,
    String email = '',
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authRepository.register(
      RegisterRequestModel(name: name, phone: phone, email: email, password: password),
    );

    _setLoading(false);

    if (result.isCompleted && result.data != null) {
      notifyListeners();
      return true;
    }

    _errorMessage = result.message ?? 'Registration failed. Please try again.';
    notifyListeners();
    return false;
  }

  /// Clears session locally regardless of whether the server call succeeds,
  /// so the user is never stuck unable to log out because of a bad network.
  Future<void> logout() async {
    await _authRepository.logout();
    await AppStorage.logout();
    _customer = null;
    notifyListeners();
  }
}