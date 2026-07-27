import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/category/category_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/skelton_box.dart';
import '../../viewmodel/category_subcategory/category_viewmodel.dart';


class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  // Same tint cycle as CategoryScreen, so a category feels visually
  // consistent whichever screen it's shown on.
  static const List<Color> _tints = [
    Color(0xFFE0EEF7),
    Color(0xFFF3E9E3),
    Color(0xFFE9ECF5),
    Color(0xFFF6EFD9),
    Color(0xFFF8E6EC),
    Color(0xFFE6F2E4),
    Color(0xFFEFEFEF),
    Color(0xFFE3EEF0),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  void _onChildTap(CategoryViewModel viewModel, CategoryModel child) {
    if (viewModel.hasChildren(child.id)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubCategoryScreen(
            categoryId: child.id,
            categoryName: child.name,
          ),
        ),
      );
    } else {
      Navigator.pushNamed(
        context,
        RouteName.categoryProducts,
        arguments: {
          'categoryId': child.id,
          'categoryName': child.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.scaffoldBgColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ColorConstant.headlineTextColor),
        title: TextContext(
          text: widget.categoryName,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
      ),
      body: SafeArea(
        child: Consumer<CategoryViewModel>(
          builder: (context, viewModel, _) {
            // ---------------- SKELETON ----------------
            if (viewModel.isLoading && viewModel.categories.isEmpty) {
              return _SubCategorySkeletonGrid(size: size);
            }

            // ---------------- ERROR ----------------
            if (viewModel.status == CategoryLoadStatus.error && viewModel.categories.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 46, color: ColorConstant.placeholderColor),
                      SizedBox(height: size.height * 0.015),
                      TextContext(
                        text: viewModel.errorMessage ?? 'Something went wrong',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                        color: ColorConstant.labelTextColor,
                      ),
                      SizedBox(height: size.height * 0.02),
                      TextButton(
                        onPressed: () => viewModel.fetchCategories(forceRefresh: true),
                        child: TextContext(
                          text: 'Retry',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final children = viewModel.childrenOf(widget.categoryId);

            // ---------------- EMPTY ----------------
            if (children.isEmpty) {
              return Center(
                child: TextContext(
                  text: 'No subcategories found',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.labelTextColor,
                ),
              );
            }

            // ---------------- REAL DATA ----------------
            return GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              itemCount: children.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: size.height * 0.02,
                crossAxisSpacing: size.width * 0.03,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final child = children[index];
                final tint = _tints[index % _tints.length];
                return _SubCategoryCard(
                  category: child,
                  tint: tint,
                  onTap: () => _onChildTap(viewModel, child),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Compact version of CategoryScreen's category card — same white-card +
/// tinted-image + shadow language, just scaled down for a 3-column grid.
class _SubCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final Color tint;
  final VoidCallback onTap;

  const _SubCategoryCard({
    required this.category,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- image area ----
            Expanded(
              flex: 6,
              child: Container(
                color: tint,
                alignment: Alignment.center,
                child: category.image != null
                    ? Image.network(
                  category.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox.shrink();
                  },
                  errorBuilder: (context, error, stack) => Icon(
                    Icons.category_rounded,
                    size: 26,
                    color: ColorConstant.primaryColor,
                  ),
                )
                    : Icon(
                  Icons.category_rounded,
                  size: 26,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ),
            // ---- text area ----
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextContext(
                      text: category.name,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: ColorConstant.headlineTextColor,
                    ),
                    const SizedBox(height: 2),
                    TextContext(
                      text: '${category.productCount} items',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.labelTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategorySkeletonGrid extends StatelessWidget {
  final Size size;
  const _SubCategorySkeletonGrid({required this.size});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      ),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: size.height * 0.02,
        crossAxisSpacing: size.width * 0.03,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blackColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                flex: 6,
                child: SkeletonBox(width: double.infinity, height: double.infinity),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(7, 8, 7, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(width: 48, height: 10, borderRadius: BorderRadius.circular(4)),
                      const SizedBox(height: 5),
                      SkeletonBox(width: 34, height: 8, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}