import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/skelton_box.dart';
import '../../viewmodel/category_subcategory/category_viewmodel.dart';


class CategoryIconsSection extends StatefulWidget {
  final ValueChanged<int>? onSelected;

  const CategoryIconsSection({super.key, this.onSelected});

  @override
  State<CategoryIconsSection> createState() => _CategoryIconsSectionState();
}

class _CategoryIconsSectionState extends State<CategoryIconsSection> {
  int _selectedIndex = 0;


  static const List<Color> _tints = [
    Color(0xFFE9ECF5),
    Color(0xFFF3E9E3),
    Color(0xFFF6EFD9),
    Color(0xFFF8E6EC),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  void _onItemTap(int index, String categoryId, String categoryName) {
    setState(() => _selectedIndex = index);
    widget.onSelected?.call(index);

    Navigator.pushNamed(
      context,
      RouteName.subCategory,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.13;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.015,
      ),
      child: Consumer<CategoryViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.categories.isEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Column(
                  children: [
                    SkeletonBox(width: circleSize, height: circleSize, shape: BoxShape.circle),
                    SizedBox(height: size.height * 0.007),
                    SkeletonBox(width: circleSize * 0.7, height: 10, borderRadius: BorderRadius.circular(4)),
                  ],
                );
              }),
            );
          }

          // ---------------- ERROR ----------------
          if (viewModel.status == CategoryLoadStatus.error && viewModel.categories.isEmpty) {
            return GestureDetector(
              onTap: () => viewModel.fetchCategories(forceRefresh: true),
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 18, color: ColorConstant.labelTextColor),
                  const SizedBox(width: 8),
                  TextContext(
                    text: 'Couldn\'t load categories — tap to retry',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),
            );
          }

          final items = viewModel.topLevelCategories;
          if (items.isEmpty) return const SizedBox.shrink();

          // ---------------- REAL DATA ----------------
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final bool isActive = index == _selectedIndex;
              final category = items[index];
              final tint = _tints[index % _tints.length];

              return GestureDetector(
                onTap: () => _onItemTap(index, category.id, category.name),
                child: Column(
                  children: [
                    Container(
                      height: circleSize,
                      width: circleSize,
                      decoration: BoxDecoration(
                        color: isActive ? ColorConstant.primaryLight : tint,
                        shape: BoxShape.circle,
                        border: isActive
                            ? Border.all(color: ColorConstant.primaryColor, width: 1.6)
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: category.image != null
                          ? Image.network(
                        category.image!,
                        fit: BoxFit.cover,
                        width: circleSize,
                        height: circleSize,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SkeletonBox(
                            width: circleSize,
                            height: circleSize,
                            shape: BoxShape.circle,
                          );
                        },
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.category_rounded,
                          size: circleSize * 0.42,
                          color: isActive
                              ? ColorConstant.primaryColor
                              : ColorConstant.labelTextColor,
                        ),
                      )
                          : Icon(
                        Icons.category_rounded,
                        size: circleSize * 0.42,
                        color: isActive
                            ? ColorConstant.primaryColor
                            : ColorConstant.labelTextColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.007),
                    TextContext(
                      text: category.name,
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? ColorConstant.primaryColor
                          : ColorConstant.labelTextColor,
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}