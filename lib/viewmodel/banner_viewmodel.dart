import 'package:flutter/material.dart';
import '../model/banner_model.dart';
import '../repo/banner_repo.dart';

enum BannerStatus { loading, loaded, error }

class BannerViewModel extends ChangeNotifier {
  final BannerRepository _repository = BannerRepository();

  List<BannerModel> _banners = [];
  List<BannerModel> get banners => List.unmodifiable(_banners);

  BannerStatus _status = BannerStatus.loading;
  BannerStatus get status => _status;
  bool get isLoading => _status == BannerStatus.loading;
  bool get hasError => _status == BannerStatus.error;
  bool get isEmpty => _status == BannerStatus.loaded && _banners.isEmpty;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBanners({bool showLoader = true}) async {
    if (showLoader) {
      _status = BannerStatus.loading;
      notifyListeners();
    }

    final response = await _repository.getBanners();

    if (response.isCompleted) {
      _banners = response.data ?? [];
      _status = BannerStatus.loaded;
      _errorMessage = null;
    } else {
      _status = BannerStatus.error;
      _errorMessage = response.message ?? 'Failed to load banners';
    }
    notifyListeners();
  }
}