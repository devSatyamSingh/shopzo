import 'package:flutter/material.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';


class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  // ---- Dummy data — replace with real data from your ViewModel/repo ----
  static final List<_CategoryItem> _categories = [
    _CategoryItem(
      image: "assets/images/pro1.jpg",
      name: "Footwear",
      itemCount: "128 items",
      badgeText: "UP TO 60% OFF",
      tintColor: const Color(0xFFE0EEF7),
    ),
    _CategoryItem(
      image: "assets/images/pro2.jpg",
      name: "Apparel",
      itemCount: "452 items",
      badgeText: "STARTING ₹299",
      tintColor: const Color(0xFFF3E9E3),
    ),
    _CategoryItem(
      image: "assets/images/pro3.jpg",
      name: "Electronics",
      itemCount: "85 items",
      badgeText: "NEW DEALS",
      tintColor: const Color(0xFFE9ECF5),
    ),
    _CategoryItem(
      image: "assets/images/pro4.jpg",
      name: "Home & Living",
      itemCount: "210 items",
      badgeText: "FLAT 20% OFF",
      tintColor: const Color(0xFFF6EFD9),
    ),
    _CategoryItem(
      image: "assets/images/pro12.jpg",
      name: "Beauty",
      itemCount: "320 items",
      badgeText: "LUXE RANGE",
      tintColor: const Color(0xFFF8E6EC),
    ),
    _CategoryItem(
      image: "assets/images/pro8.jpg",
      name: "Grocery",
      itemCount: "1.2k items",
      badgeText: "FAST DELIVERY",
      tintColor: const Color(0xFFE6F2E4),
    ),
    _CategoryItem(
      image: "assets/images/pro9.jpg",
      name: "Accessories",
      itemCount: "190 items",
      badgeText: "UP TO 50% OFF",
      tintColor: const Color(0xFFEFEFEF),
    ),
    _CategoryItem(
      image: "assets/images/pro10.jpg",
      name: "Sports",
      itemCount: "95 items",
      badgeText: "FITNESS SALE",
      tintColor: const Color(0xFFE3EEF0),
    ),
  ];

  static const List<_QuickChip> _quickChips = [
    _QuickChip(
      label: "New Arrivals",
      icon: Icons.verified_rounded,
      color: ColorConstant.successColor,
    ),
    _QuickChip(
      label: "Best Sellers",
      icon: Icons.local_fire_department_rounded,
      color: ColorConstant.orangeColor,
    ),
    _QuickChip(
      label: "Deals",
      icon: Icons.sell_rounded,
      color: ColorConstant.primaryColor,
    ),
    _QuickChip(
      label: "Top Brands",
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    _buildSearchBar(size),
                    SizedBox(height: size.height * 0.022),
                    _buildFeaturedBanner(size),
                    SizedBox(height: size.height * 0.026),
                    _buildQuickChips(size),
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
        InkWell(
          onTap: () {
            // TODO: open drawer / side menu
          },
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.menu_rounded, color: ColorConstant.primaryDark, size: 24),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        const Expanded(
          child: TextContext(
            text: "All Categories",
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ColorConstant.primaryDark,
          ),
        ),
      ],
    );
  }

  /// ---------------- SEARCH BAR ----------------
  Widget _buildSearchBar(Size size) {
    return CustomTextField(
      controller: _searchController,
      hintText: "Search categories or products",
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: ColorConstant.placeholderColor,
        size: 22,
      ),
      suffixIcon: InkWell(
        onTap: () {
          _searchController.clear();
          setState(() {});
        },
        child: const Icon(
          Icons.close_rounded,
          color: ColorConstant.placeholderColor,
          size: 20,
        ),
      ),
      fillColor: ColorConstant.fieldFillColor,
      borderRadius: 16,
      showBorder: false,
      onChanged: (value) {
        setState(() {});
        // Yahin search/filter logic chalega
      },
    );
  }

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
                  "Trending: Summer\nCollection",
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
                  children: const [
                    Text(
                      "Explore",
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

  /// ---------------- QUICK-ACCESS CHIPS ----------------
  Widget _buildQuickChips(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: CategoryScreen._quickChips.map((chip) {
        return Column(
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
              text: chip.label,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),
          ],
        );
      }).toList(),
    );
  }

  /// ---------------- MAIN CATEGORY GRID ----------------
  Widget _buildCategoryGrid(Size size) {
    final double spacing = size.width * 0.026;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: CategoryScreen._categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.99,
      ),
      itemBuilder: (context, index) => _buildCategoryCard(size, CategoryScreen._categories[index]),
    );
  }

  Widget _buildCategoryCard(Size size, _CategoryItem item) {
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
          Expanded(
            flex: 5,
            child: Container(
              color: item.tintColor,
              alignment: Alignment.center,
              child: Center(
                child: Container(
                  width: 110,
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(item.image),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextContext(
                        text: item.name,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      TextContext(
                        text: item.itemCount,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: ColorConstant.orangeGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w700,
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

class _CategoryItem {
  final String image;// placeholder — swap for `image` (network/asset) later
  final String name;
  final String itemCount;
  final String badgeText;
  final Color tintColor;

  _CategoryItem({
    required this.image,
    required this.name,
    required this.itemCount,
    required this.badgeText,
    required this.tintColor,
  });
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