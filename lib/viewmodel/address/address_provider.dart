import 'package:flutter/material.dart';
import '../../model/address/address_model.dart';


class AddressProvider extends ChangeNotifier {
  String _selectedAddress = 'Select delivery address';
  String get selectedAddress => _selectedAddress;

  AddressModel? _selectedAddressModel;
  AddressModel? get selectedAddressModel => _selectedAddressModel;

  void updateAddress(AddressModel address) {
    _selectedAddressModel = address;
    _selectedAddress = address.city.isNotEmpty
        ? '${address.city}${address.postalCode.isNotEmpty ? ' ${address.postalCode}' : ''}'
        : address.fullAddress;
    notifyListeners();
  }
}