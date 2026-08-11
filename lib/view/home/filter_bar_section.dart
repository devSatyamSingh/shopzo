// lib/view/home/filter/filter_bar_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../filter_model.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterBarSection extends StatelessWidget {
  final ValueChanged<int>? onChipTap;

  const FilterBarSection({super.key, this.onChipTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return SizedBox(
          height: size.height * 0.05,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            itemCount: 4,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.025),
            itemBuilder: (context, index) {
              return _buildFilterChip(context, index, filterProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, int index, FilterProvider provider) {
    final size = MediaQuery.of(context).size;
    Widget chip;

    switch (index) {
      case 0:
        chip = _SortFilterChip(provider: provider);
        break;
      case 1:
        chip = _PriceFilterChip(provider: provider);
        break;
      case 2:
        chip = _FiltersFilterChip(provider: provider);
        break;
      default:
        chip = const SizedBox.shrink();
    }

    return chip;
  }
}

// Sort Filter Chip
class _SortFilterChip extends StatefulWidget {
  final FilterProvider provider;

  const _SortFilterChip({required this.provider});

  @override
  State<_SortFilterChip> createState() => _SortFilterChipState();
}

class _SortFilterChipState extends State<_SortFilterChip> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentSort = widget.provider.state.sortOption;
    final sortLabel = _getSortLabel(currentSort);

    return GestureDetector(
      onTap: () => _showSortBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.provider.state.isFilterApplied && currentSort != SortOption.popularity
                ? ColorConstant.primaryColor
                : ColorConstant.borderColor,
            width: widget.provider.state.isFilterApplied && currentSort != SortOption.popularity ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert_rounded, size: 16, color: ColorConstant.bodyTextColor),
            const SizedBox(width: 6),
            TextContext(
              text: sortLabel,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.bodyTextColor,
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: ColorConstant.bodyTextColor),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.popularity:
        return 'filters.sort'.tr();
      case SortOption.priceLowToHigh:
        return 'filters.price_low_high'.tr();
      case SortOption.priceHighToLow:
        return 'filters.price_high_low'.tr();
      case SortOption.rating:
        return 'filters.rating'.tr();
      case SortOption.newest:
        return 'filters.newest'.tr();
    }
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorConstant.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextContext(
                text: 'filters.sort_by'.tr(),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
              const SizedBox(height: 16),
              ...SortOption.values.map((option) {
                final isSelected = widget.provider.state.sortOption == option;
                return ListTile(
                  leading: Radio<SortOption>(
                    value: option,
                    groupValue: widget.provider.state.sortOption,
                    activeColor: ColorConstant.primaryColor,
                    onChanged: (value) {
                      if (value != null) {
                        widget.provider.updateSort(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: TextContext(
                    text: _getSortLabel(option).replaceFirst('Sort', ''),
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? ColorConstant.primaryColor
                        : ColorConstant.bodyTextColor,
                  ),
                  onTap: () {
                    widget.provider.updateSort(option);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// Price Filter Chip
class _PriceFilterChip extends StatefulWidget {
  final FilterProvider provider;

  const _PriceFilterChip({required this.provider});

  @override
  State<_PriceFilterChip> createState() => _PriceFilterChipState();
}

class _PriceFilterChipState extends State<_PriceFilterChip> {
  RangeValues _tempRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    _tempRange = widget.provider.state.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final priceRange = widget.provider.state.priceRange;
    final isPriceFiltered = priceRange.start > 0 || priceRange.end < 100000;

    return GestureDetector(
      onTap: () => _showPriceBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPriceFiltered
                ? ColorConstant.primaryColor
                : ColorConstant.borderColor,
            width: isPriceFiltered ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.currency_rupee_rounded, size: 16, color: ColorConstant.bodyTextColor),
            const SizedBox(width: 6),
            TextContext(
              text: isPriceFiltered
                  ? '₹${_formatPrice(priceRange.start)} - ₹${_formatPrice(priceRange.end)}'
                  : 'filters.price'.tr(),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.bodyTextColor,
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: ColorConstant.bodyTextColor),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  void _showPriceBottomSheet(BuildContext context) {
    _tempRange = widget.provider.state.priceRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorConstant.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextContext(
                        text: 'filters.price_range'.tr(),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.headlineTextColor,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _tempRange = const RangeValues(0, 100000);
                          });
                        },
                        child: TextContext(
                          text: 'filters.reset'.tr(),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceChip('₹0', _tempRange.start == 0),
                      _buildPriceChip('₹${_formatPrice(_tempRange.start)}', true),
                      _buildPriceChip('₹${_formatPrice(_tempRange.end)}', true),
                      _buildPriceChip('₹1L+', _tempRange.end == 100000),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _tempRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: ColorConstant.primaryColor,
                    inactiveColor: ColorConstant.borderColor,
                    labels: RangeLabels(
                      '₹${_formatPrice(_tempRange.start)}',
                      '₹${_formatPrice(_tempRange.end)}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _tempRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: ColorConstant.borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: TextContext(
                            text: 'filters.cancel'.tr(),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.bodyTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.provider.updatePriceRange(_tempRange);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: ColorConstant.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: TextContext(
                            text: 'Apply',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? ColorConstant.primaryColor.withOpacity(.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
        ),
      ),
      child: TextContext(
        text: label,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? ColorConstant.primaryColor : ColorConstant.bodyTextColor,
      ),
    );
  }
}

// Filters Filter Chip
class _FiltersFilterChip extends StatefulWidget {
  final FilterProvider provider;

  const _FiltersFilterChip({required this.provider});

  @override
  State<_FiltersFilterChip> createState() => _FiltersFilterChipState();
}

class _FiltersFilterChipState extends State<_FiltersFilterChip> {
  List<String> _tempCategories = [];

  final List<String> _availableCategories = [
    'Electronics',
    'Fashion',
    'Home & Living',
    'Beauty',
    'Sports',
    'Books',
    'Toys',
    'Automotive',
  ];

  @override
  void initState() {
    super.initState();
    _tempCategories = List.from(widget.provider.state.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isFiltered = widget.provider.state.selectedCategories.isNotEmpty;

    return GestureDetector(
      onTap: () => _showFiltersBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isFiltered
                ? ColorConstant.primaryColor
                : ColorConstant.borderColor,
            width: isFiltered ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 16, color: ColorConstant.bodyTextColor),
            const SizedBox(width: 6),
            TextContext(
              text: isFiltered
                  ? 'Filters (${widget.provider.state.selectedCategories.length})'
                  : 'Filters',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.bodyTextColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    _tempCategories = List.from(widget.provider.state.selectedCategories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorConstant.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextContext(
                        text: 'filters.categories'.tr(),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.headlineTextColor,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _tempCategories.clear();
                          });
                        },
                        child: TextContext(
                          text: 'filters.clear_all'.tr(),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((category) {
                      final isSelected = _tempCategories.contains(category);
                      return FilterChip(
                        label: TextContext(
                          text: category,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? ColorConstant.whiteColor
                              : ColorConstant.bodyTextColor,
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tempCategories.add(category);
                            } else {
                              _tempCategories.remove(category);
                            }
                          });
                        },
                        backgroundColor: ColorConstant.whiteColor,
                        selectedColor: ColorConstant.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? ColorConstant.primaryColor
                                : ColorConstant.borderColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: ColorConstant.borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: TextContext(
                            text: 'Cancel',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.bodyTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.provider.updateCategories(_tempCategories);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: ColorConstant.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: TextContext(
                            text: 'Apply',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
//
// // Gender Filter Chip
// class _GenderFilterChip extends StatefulWidget {
//   final FilterProvider provider;
//
//   const _GenderFilterChip({required this.provider});
//
//   @override
//   State<_GenderFilterChip> createState() => _GenderFilterChipState();
// }
//
// class _GenderFilterChipState extends State<_GenderFilterChip> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final currentGender = widget.provider.state.genderOption;
//     final isGenderFiltered = currentGender != GenderOption.all;
//
//     return GestureDetector(
//       onTap: () => _showGenderBottomSheet(context),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: BoxDecoration(
//           color: ColorConstant.whiteColor,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isGenderFiltered
//                 ? ColorConstant.primaryColor
//                 : ColorConstant.borderColor,
//             width: isGenderFiltered ? 2 : 1,
//           ),
//         ),
//         alignment: Alignment.center,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.person_outline_rounded, size: 16, color: ColorConstant.bodyTextColor),
//             const SizedBox(width: 6),
//             TextContext(
//               text: _getGenderLabel(currentGender),
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: ColorConstant.bodyTextColor,
//             ),
//             const SizedBox(width: 4),
//             Icon(Icons.keyboard_arrow_down_rounded,
//                 size: 16, color: ColorConstant.bodyTextColor),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getGenderLabel(GenderOption option) {
//     switch (option) {
//       case GenderOption.all:
//         return 'Gender';
//       case GenderOption.men:
//         return 'Men';
//       case GenderOption.women:
//         return 'Women';
//       case GenderOption.unisex:
//         return 'Unisex';
//     }
//   }
//
//   void _showGenderBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: ColorConstant.borderColor,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextContext(
//                 text: 'Gender',
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: ColorConstant.headlineTextColor,
//               ),
//               const SizedBox(height: 16),
//               ...GenderOption.values.map((option) {
//                 final isSelected = widget.provider.state.genderOption == option;
//                 return ListTile(
//                   leading: Radio<GenderOption>(
//                     value: option,
//                     groupValue: widget.provider.state.genderOption,
//                     activeColor: ColorConstant.primaryColor,
//                     onChanged: (value) {
//                       if (value != null) {
//                         widget.provider.updateGender(value);
//                         Navigator.pop(context);
//                       }
//                     },
//                   ),
//                   title: TextContext(
//                     text: _getGenderLabel(option),
//                     fontSize: 15,
//                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                     color: isSelected
//                         ? ColorConstant.primaryColor
//                         : ColorConstant.bodyTextColor,
//                   ),
//                   onTap: () {
//                     widget.provider.updateGender(option);
//                     Navigator.pop(context);
//                   },
//                 );
//               }),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }