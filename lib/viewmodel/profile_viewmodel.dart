import 'package:flutter/material.dart';
import '../../utils/app_storage.dart';
import '../model/profile_model.dart';
import '../repo/profile_repo.dart';

enum ProfileStatus { loading, loaded, error }

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool _isDisposed = false;
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  ProfileStatus _status = ProfileStatus.loading;
  ProfileStatus get status => _status;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get hasError => _status == ProfileStatus.error;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _saveError;
  String? get saveError => _saveError;

  Future<void> fetchProfile({bool showLoader = true}) async {
    if (showLoader) {
      _status = ProfileStatus.loading;
      _safeNotify();
    }

    final response = await _repository.getProfile();
    if (_isDisposed) return;

    if (response.isCompleted && response.data != null) {
      _profile = response.data;
      _status = ProfileStatus.loaded;
      _errorMessage = null;
    } else {
      _errorMessage = response.message ?? 'Failed to load profile';
      _status = ProfileStatus.error;
    }
    _safeNotify();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String email,
    DateTime? dob,
    String? gender,
  }) async {
    _isSaving = true;
    _saveError = null;
    _safeNotify();

    final response = await _repository.updateProfile(
      name: name,
      phone: phone,
      email: email,
      dob: dob,
      gender: gender,
    );

    if (_isDisposed) return false;

    if (response.isCompleted && response.data != null) {
      _profile = response.data;
      _status = ProfileStatus.loaded;

      // keep locally stored customer data (used elsewhere, e.g. AppStorage.getCustomer())
      // in sync with the freshly updated profile
      await AppStorage.saveCustomer({
        'id': _profile!.id,
        'name': _profile!.name,
        'phone': _profile!.phone,
        'email': _profile!.email,
        'createdAt': _profile!.createdAt?.toIso8601String(),
      });

      _isSaving = false;
      _safeNotify();
      return true;
    } else {
      _saveError = response.message ?? 'Failed to update profile';
      _isSaving = false;
      _safeNotify();
      return false;
    }
  }
}