import 'package:flutter/material.dart';
import '../model/cms_page_model.dart';
import '../repo/cms_repo.dart';

enum CmsPageStatus { idle, loading, loaded, error }

class CmsPageViewModel extends ChangeNotifier {
  final CmsRepository _repo = CmsRepository();

  CmsPageStatus _status = CmsPageStatus.idle;
  CmsPageStatus get status => _status;
  bool get isLoading => _status == CmsPageStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CmsPageDetailModel? _page;
  CmsPageDetailModel? get page => _page;

  String _type = '';

  Future<void> fetchPage(String type) async {
    _type = type;
    _status = CmsPageStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _repo.getPageByType(type);

    if (response.isCompleted && response.data != null) {
      _page = response.data!;
      _status = CmsPageStatus.loaded;
    } else {
      _errorMessage = response.message;
      _status = CmsPageStatus.error;
    }
    notifyListeners();
  }

  void retry() {
    if (_type.isNotEmpty) fetchPage(_type);
  }
}