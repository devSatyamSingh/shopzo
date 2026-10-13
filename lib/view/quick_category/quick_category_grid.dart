import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import '../../../routes/route_name.dart';
import '../../../utils/skelton_box.dart';
import '../../localization/language_provider.dart';
import '../../model/category/category_model.dart';
import '../../viewmodel/category_subcategory/category_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';


class QuickCategoryGrid extends StatefulWidget {
  final ValueChanged<int>? onTap;

  const QuickCategoryGrid({super.key, this.onTap});

  @override
  State<QuickCategoryGrid> createState() => _QuickCategoryGridState();
}

class _QuickCategoryGridState extends State<QuickCategoryGrid> {
  bool _expanded = false;

  static const int _collapsedCount = 7;

  static const List<Color> _tints = [
    Color(0xFFE9ECF5),
    Color(0xFFF3E9E3),
    Color(0xFFF6EFD9),
    Color(0xFFE6F2E4),
    Color(0xFFF8E6EC),
    Color(0xFFE0EEF7),
    Color(0xFFEFEFEF),
  ];

  @override
  void initState() {
    super.initState();
    // Cached after first load — cheap to call again even if Home already did.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  void _onCategoryTap(int index, CategoryModel category) {
    widget.onTap?.call(index);
    Navigator.pushNamed(
      context,
      RouteName.categoryProducts,
      arguments: {
        'categoryId': category.id,
        'categoryName': category.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();


    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.012,
      ),
      child: Consumer<CategoryViewModel>(
        builder: (context, viewModel, _) {
          // ---------------- SKELETON ----------------
          if (viewModel.isLoading && viewModel.categories.isEmpty) {
            return _QuickCategorySkeletonGrid(size: size);
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
                    text: 'quick_categories.category_load_error'.tr(),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),
            );
          }

          // Every category that is NOT top-level — flattened, any depth.
          final subCategories = viewModel.categories.where((c) => !c.isTopLevel).toList();

          if (subCategories.isEmpty) return const SizedBox.shrink();

          final bool needsToggle = subCategories.length > _collapsedCount;
          final int visibleCount = _expanded ? subCategories.length : (needsToggle ? _collapsedCount : subCategories.length);
          final int gridItemCount = needsToggle ? visibleCount + 1 : subCategories.length;

          // ---------------- REAL DATA ----------------
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridItemCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 9,
              childAspectRatio: 0.90,
            ),
            itemBuilder: (context, index) {
              // ---- last cell: toggle tile ----
              if (needsToggle && index == visibleCount) {
                return _ToggleTile(
                  expanded: _expanded,
                  onTap: () => setState(() => _expanded = !_expanded),
                );
              }

              // ---- regular subcategory tile ----
              final category = subCategories[index];
              final tint = _tints[index % _tints.length];
              final double tileSize = size.width * 0.15;

              return GestureDetector(
                onTap: () => _onCategoryTap(index, category),
                child: Column(
                  children: [
                    Container(
                      height: tileSize,
                      width: tileSize,
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: category.image != null
                          ? Image.network(
                        category.image!,
                        fit: BoxFit.cover,
                        width: tileSize,
                        height: tileSize,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox.shrink();
                        },
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.image_search_outlined,
                          size: size.width * 0.065,
                          color: ColorConstant.primaryColor,
                        ),
                      )
                          : Icon(
                        Icons.image_search_outlined,
                        size: size.width * 0.065,
                        color: ColorConstant.primaryColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.007),
                    TextContext(
                      text: category.name,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                      color: ColorConstant.bodyTextColor,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ---------------- MORE / HIDE TOGGLE TILE ----------------
class _ToggleTile extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _ToggleTile({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: size.width * 0.15,
            width: size.width * 0.15,
            decoration: BoxDecoration(
              color: ColorConstant.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorConstant.primaryColor.withOpacity(.3)),
            ),
            alignment: Alignment.center,
            child: Icon(
              expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: size.width * 0.065,
              color: ColorConstant.primaryColor,
            ),
          ),
          SizedBox(height: size.height * 0.007),
          TextContext(
            text: expanded
                ? 'quick_categories.hide'.tr()
                : 'quick_categories.more'.tr(),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            color: ColorConstant.primaryColor,
          ),
        ],
      ),
    );
  }
}

/// ---------------- SKELETON GRID (first load) ----------------
class _QuickCategorySkeletonGrid extends StatelessWidget {
  final Size size;
  const _QuickCategorySkeletonGrid({required this.size});

  @override
  Widget build(BuildContext context) {
    final double tileSize = size.width * 0.15;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 4,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            SkeletonBox(width: tileSize, height: tileSize, borderRadius: BorderRadius.circular(16)),
            SizedBox(height: size.height * 0.007),
            SkeletonBox(width: tileSize * 0.7, height: 9, borderRadius: BorderRadius.circular(4)),
          ],
        );
      },
    );
  }
}