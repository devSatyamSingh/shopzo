import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../repo/category_repo.dart';

enum CategoryLoadStatus { idle, loading, loaded, error }


class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  CategoryLoadStatus _status = CategoryLoadStatus.idle;
  CategoryLoadStatus get status => _status;
  bool get isLoading => _status == CategoryLoadStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<CategoryModel> get topLevelCategories =>
      _categories.where((c) => c.isTopLevel).toList();

  List<CategoryModel> childrenOf(String parentId) =>
      _categories.where((c) => c.parentId == parentId).toList();

  bool hasChildren(String categoryId) => childrenOf(categoryId).isNotEmpty;

  CategoryModel? findById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }


  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (_status == CategoryLoadStatus.loaded && !forceRefresh) return;

    _status = CategoryLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAllCategories();

    if (result.isCompleted && result.data != null) {
      _categories = result.data!;
      _status = CategoryLoadStatus.loaded;
    } else {
      _errorMessage = result.message ?? 'Failed to load categories';
      _status = CategoryLoadStatus.error;
    }
    notifyListeners();
  }
}