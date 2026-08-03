import 'package:flutter/material.dart';
import '../../model/address/address_model.dart';

/// Shopzo — holds whichever address is currently selected for delivery,
/// shown in HomeAppBar ("Deliver to ..."). Separate from AddressViewModel
/// (which owns the full CRUD list) — this just tracks the ONE choice the
/// user made on SelectAddressScreen.
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