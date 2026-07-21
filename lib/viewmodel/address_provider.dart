// lib/view/home/address_provider.dart
import 'package:flutter/material.dart';
import '../view/address/address_list_screen.dart';

class AddressProvider extends ChangeNotifier {
  String _selectedAddress = 'Mumbai 400001';
  SavedAddressModel? _selectedAddressModel;

  String get selectedAddress => _selectedAddress;
  SavedAddressModel? get selectedAddressModel => _selectedAddressModel;

  void updateAddress(SavedAddressModel address) {
    _selectedAddress = address.address.split(',').last.trim(); // Show city/pincode
    _selectedAddressModel = address;
    notifyListeners();
  }

  void resetAddress() {
    _selectedAddress = 'Mumbai 400001';
    _selectedAddressModel = null;
    notifyListeners();
  }
}