import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/category/category_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';
import '../../routes/route_name.dart';
import '../../utils/skelton_box.dart';
import '../../viewmodel/category_subcategory/category_viewmodel.dart';
import '../best_seller_screen.dart';
import 'sub_category_screen.dart';
import 'category_product_list.dart';
import 'package:easy_localization/easy_localization.dart';


class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  // Cycled as a card background tint — cosmetic only, API has no color field.
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

  static const List<_QuickChip> _quickChips = [
    _QuickChip(
      label: "category.new_arrivals",
      icon: Icons.verified_rounded,
      color: ColorConstant.successColor,
    ),
    _QuickChip(
      label: "category.best_sellers",
      icon: Icons.local_fire_department_rounded,
      color: ColorConstant.orangeColor,
    ),
    _QuickChip(
      label: "category.deals",
      icon: Icons.sell_rounded,
      color: ColorConstant.primaryColor,
    ),
    _QuickChip(
      label: "category.top_brands",
      icon: Icons.workspace_premium_rounded,
      color: ColorConstant.infoColor,
    ),
  ];

  static const List<_PopularItem> _popular = [
    _PopularItem(icon: Icons.watch_rounded, ringColor: ColorConstant.infoColor),
    _PopularItem(icon: Icons.shopping_bag_rounded, ringColor: ColorConstant.orangeColor),
    _PopularItem(icon: Icons.camera_alt_rounded, ringColor: ColorConstant.primaryColor),
    _PopularItem(icon: Icons.headphones_rounded, ringColor: ColorConstant.headlineTextColor),
  ];

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Cached after first load — cheap to call again here even if Home
    // already triggered it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(CategoryViewModel viewModel, CategoryModel category) {
    if (viewModel.hasChildren(category.id)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubCategoryScreen(
            categoryId: category.id,
            categoryName: category.name,
          ),
        ),
      );
    } else {
      // Top-level category with no subcategories — go straight to its
      // product list.
      Navigator.pushNamed(
        context,
        RouteName.categoryProducts,
        arguments: {
          'categoryId': category.id,
          'categoryName': category.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.012),
                    _buildHeader(context, size),
                    SizedBox(height: size.height * 0.018),
                    // _buildSearchBar(size),
                    SizedBox(height: size.height * 0.022),
                    _buildFeaturedBanner(size),
                    SizedBox(height: size.height * 0.026),
                    // _buildQuickChips(size),
                    _buildBestSellerCard(size),
                    SizedBox(height: size.height * 0.026),
                    _buildCategoryGrid(size),
                    SizedBox(height: size.height * 0.025),
                    // _buildPopularThisWeek(size),
                    // SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ---------------- 
  Widget _buildHeader(BuildContext context, Size size) {
    return Row(
      children: [
        // InkWell(
        //   onTap: () {
        //     // TODO: open drawer / side menu
        //   },
        //   borderRadius: BorderRadius.circular(10),
        //   child: const Padding(
        //     padding: EdgeInsets.all(4),
        //     child: Icon(Icons.menu_rounded, color: ColorConstant.primaryDark, size: 24),
        //   ),
        // ),
        // SizedBox(width: size.width * 0.03),
        Expanded(
          child: TextContext(
            text: 'category.all_categories'.tr(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ColorConstant.primaryDark,
          ),
        ),
      ],
    );
  }

  /// ---------------- SEARCH BAR ----------------
  // Widget _buildSearchBar(Size size) {
  //   return CustomTextField(
  //     controller: _searchController,
  //     hintText: 'category.search_categories_products'.tr(),
  //     prefixIcon: const Icon(
  //       Icons.search_rounded,
  //       color: ColorConstant.placeholderColor,
  //       size: 22,
  //     ),
  //     suffixIcon: InkWell(
  //       onTap: () {
  //         _searchController.clear();
  //         setState(() => _query = '');
  //       },
  //       child: const Icon(
  //         Icons.close_rounded,
  //         color: ColorConstant.placeholderColor,
  //         size: 20,
  //       ),
  //     ),
  //     fillColor: ColorConstant.fieldFillColor,
  //     borderRadius: 16,
  //     showBorder: false,
  //     onChanged: (value) {
  //       setState(() => _query = value.trim().toLowerCase());
  //     },
  //   );
  // }

  /// ---------------- FEATURED GRADIENT BANNER ----------------
  Widget _buildFeaturedBanner(Size size) {
    final double bannerHeight = (size.height * 0.12).clamp(100.0, 140.0);

    return Container(
      height: bannerHeight,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      decoration: BoxDecoration(
        gradient: ColorConstant.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: 8,
            child: Icon(
              Icons.checkroom_rounded,
              size: bannerHeight * 0.85,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'category.trending_summer'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (size.width * 0.044).clamp(17.0, 21.0),
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'category.explore'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellerCard(Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BestSellerScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: size.height * 0.1,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: size.height * 0.01,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFF7931E),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: size.height * 0.05,
              width: size.height * 0.05,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'category.best_sellers'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'category.best_sellers_subtitle'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- QUICK-ACCESS CHIPS ----------------
  Widget _buildQuickChips(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: CategoryScreen._quickChips.map((chip) {
        return GestureDetector(
          onTap: () {
            if (chip.label == "category.best_sellers") {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BestSellerScreen()));
            }
            // TODO: baaki chips (New Arrivals, Deals, Top Brands) ke liye
            // unki respective screens/filters yahan add kar dena
          },
          child: Column(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: chip.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: chip.color.withOpacity(0.35), width: 1.4),
                ),
                alignment: Alignment.center,
                child: Icon(chip.icon, color: chip.color, size: 22),
              ),
              const SizedBox(height: 8),
              TextContext(
                text: chip.label.tr(),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  /// ---------------- MAIN CATEGORY GRID (API-backed) ----------------
  Widget _buildCategoryGrid(Size size) {
    final double spacing = size.width * 0.013;

    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, _) {
        // ---------------- SKELETON (first load only) ----------------
        if (viewModel.isLoading && viewModel.categories.isEmpty) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) => _buildCategoryCardSkeleton(),
          );
        }

        // ---------------- ERROR ----------------
        if (viewModel.status == CategoryLoadStatus.error && viewModel.categories.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 40, color: ColorConstant.placeholderColor),
                  SizedBox(height: size.height * 0.012),
                  TextContext(
                    text: viewModel.errorMessage ?? 'category.failed_load_categories'.tr(),                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                    color: ColorConstant.labelTextColor,
                  ),
                  SizedBox(height: size.height * 0.015),
                  TextButton(
                    onPressed: () => viewModel.fetchCategories(forceRefresh: true),
                    child: TextContext(
                      text: 'category.retry'.tr(),                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final categories = viewModel.topLevelCategories
            .where((c) => _query.isEmpty || c.name.toLowerCase().contains(_query))
            .toList();

        if (categories.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
            child: Center(
              child: TextContext(
                text: 'category.no_categories_found'.tr(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorConstant.labelTextColor,
              ),
            ),
          );
        }

        // ---------------- REAL DATA ----------------
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final tint = CategoryScreen._tints[index % CategoryScreen._tints.length];
            return _buildCategoryCard(size, viewModel, category, tint);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(
      Size size,
      CategoryViewModel viewModel,
      CategoryModel category,
      Color tint,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _onCategoryTap(viewModel, category),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(18),
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
            Expanded(
              flex: 16,
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
                    size: 40,
                    color: ColorConstant.primaryColor,
                  ),
                )
                    : Icon(
                  Icons.category_rounded,
                  size: 40,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 7, 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextContext(
                          text: category.name,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // const SizedBox(height: 2),
                        // TextContext(
                        //   text: '${category.productCount} items',
                        //   fontSize: 11.5,
                        //   fontWeight: FontWeight.w400,
                        //   color: ColorConstant.labelTextColor,
                        // ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (category.taxRate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: ColorConstant.orangeGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'GST ${category.taxRate}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            letterSpacing: 0.2,
                          ),
                        ),
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
  Widget _buildCategoryCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
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
          const Expanded(flex: 5, child: SkeletonBox(width: double.infinity, height: double.infinity)),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 70, height: 12, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 50, height: 10, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 10),
                  SkeletonBox(width: 60, height: 16, borderRadius: BorderRadius.circular(20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// ---------------- POPULAR THIS WEEK ----------------
  Widget _buildPopularThisWeek(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.trending_up_rounded, color: ColorConstant.orangeColor, size: 20),
                SizedBox(width: 6),
                TextContext(
                  text: "Popular This Week",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            const TextContext(
              text: "See All",
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.primaryColor,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.016),
        SizedBox(
          height: size.width * 0.19,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: CategoryScreen._popular.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.045),
            itemBuilder: (context, index) {
              final item = CategoryScreen._popular[index];
              final double avatarSize = size.width * 0.16;

              return Container(
                height: avatarSize,
                width: avatarSize,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: item.ringColor, width: 2.2),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: ColorConstant.fieldFillColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: avatarSize * 0.42, color: ColorConstant.headlineTextColor),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickChip {
  final String label;
  final IconData icon;
  final Color color;

  const _QuickChip({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _PopularItem {
  final IconData icon;
  final Color ringColor;

  const _PopularItem({
    required this.icon,
    required this.ringColor,
  });
}