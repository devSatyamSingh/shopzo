// lib/view/home/filter/filter_model.dart
import 'package:flutter/material.dart';
import '../model/product_model.dart';

enum SortOption {
  popularity,
  priceLowToHigh,
  priceHighToLow,
  rating,
  newest,
}

enum GenderOption {
  all,
  men,
  women,
  unisex,
}

class FilterState {
  final SortOption sortOption;
  final GenderOption genderOption;
  final RangeValues priceRange;
  final List<String> selectedCategories;
  final bool isFilterApplied;

  const FilterState({
    this.sortOption = SortOption.popularity,
    this.genderOption = GenderOption.all,
    this.priceRange = const RangeValues(0, 100000),
    this.selectedCategories = const [],
    this.isFilterApplied = false,
  });

  FilterState copyWith({
    SortOption? sortOption,
    GenderOption? genderOption,
    RangeValues? priceRange,
    List<String>? selectedCategories,
    bool? isFilterApplied,
  }) {
    return FilterState(
      sortOption: sortOption ?? this.sortOption,
      genderOption: genderOption ?? this.genderOption,
      priceRange: priceRange ?? this.priceRange,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isFilterApplied: isFilterApplied ?? this.isFilterApplied,
    );
  }
}

class FilterProvider extends ChangeNotifier {
  FilterState _state = const FilterState();

  FilterState get state => _state;

  void updateSort(SortOption sort) {
    _state = _state.copyWith(
      sortOption: sort,
      isFilterApplied: true,
    );
    notifyListeners();
  }

  void updateGender(GenderOption gender) {
    _state = _state.copyWith(
      genderOption: gender,
      isFilterApplied: true,
    );
    notifyListeners();
  }

  void updatePriceRange(RangeValues range) {
    _state = _state.copyWith(
      priceRange: range,
      isFilterApplied: true,
    );
    notifyListeners();
  }

  void updateCategories(List<String> categories) {
    _state = _state.copyWith(
      selectedCategories: categories,
      isFilterApplied: categories.isNotEmpty,
    );
    notifyListeners();
  }

  void clearAllFilters() {
    _state = const FilterState();
    notifyListeners();
  }

  List<ProductModel> applyFilters(List<ProductModel> products) {
    var filtered = products;

    // Apply gender filter
    if (_state.genderOption != GenderOption.all) {
      // You'll need to add gender field to ProductModel
      // filtered = filtered.where((p) => p.gender == _state.genderOption).toList();
    }

    // Apply price filter
    filtered = filtered.where((p) {
      return p.price >= _state.priceRange.start &&
          p.price <= _state.priceRange.end;
    }).toList();

    // Apply category filters
    if (_state.selectedCategories.isNotEmpty) {
      // filtered = filtered.where((p) => _state.selectedCategories.contains(p.category)).toList();
    }

    // Apply sorting
    switch (_state.sortOption) {
      case SortOption.popularity:
      // Sort by rating or default order
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.newest:
      // Implement based on your data
        break;
    }

    return filtered;
  }
}