import 'package:flutter/material.dart';
import '../../model/address/address_model.dart';
import '../../repo/address/address_repo.dart';

enum AddressLoadStatus { idle, loading, loaded, error }

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _repository = AddressRepository();

  AddressLoadStatus _status = AddressLoadStatus.idle;
  AddressLoadStatus get status => _status;
  bool get isLoading => _status == AddressLoadStatus.loading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  AddressModel? get defaultAddress {
    for (final a in _addresses) {
      if (a.isDefault) return a;
    }
    return _addresses.isNotEmpty ? _addresses.first : null;
  }

  Future<void> fetchAddresses({bool forceRefresh = false}) async {
    if (_status == AddressLoadStatus.loaded && !forceRefresh) return;

    _status = AddressLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getMyAddresses();

    if (result.isCompleted && result.data != null) {
      _addresses = result.data!;
      _status = AddressLoadStatus.loaded;
    } else {
      _errorMessage = result.message ?? 'Failed to load addresses';
      _status = AddressLoadStatus.error;
    }
    notifyListeners();
  }

  /// Returns true on success. On success, the new address is inserted at
  /// the top of the list — no need to refetch.
  Future<bool> addAddress(AddressRequestModel request) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.createAddress(request);
    _isSaving = false;

    if (result.isCompleted && result.data != null) {
      if (result.data!.isDefault) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }
      _addresses.insert(0, result.data!);
      notifyListeners();
      return true;
    }

    _errorMessage = result.message ?? 'Failed to save address';
    notifyListeners();
    return false;
  }

  /// Returns true on success.
  Future<bool> updateAddress(String id, AddressRequestModel request) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updateAddress(id, request);
    _isSaving = false;

    if (result.isCompleted && result.data != null) {
      if (result.data!.isDefault) {
        _addresses = _addresses.map((a) => a.id == id ? a : a.copyWith(isDefault: false)).toList();
      }
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = result.data!;
      }
      notifyListeners();
      return true;
    }

    _errorMessage = result.message ?? 'Failed to update address';
    notifyListeners();
    return false;
  }

  /// Returns true on success.
  Future<bool> deleteAddress(String id) async {
    final result = await _repository.deleteAddress(id);

    if (result.isCompleted) {
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    }

    _errorMessage = result.message ?? 'Failed to delete address';
    notifyListeners();
    return false;
  }
}