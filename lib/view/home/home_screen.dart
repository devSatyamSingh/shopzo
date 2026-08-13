import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/view/flash_deals/flash_deals_screen.dart';
import 'package:shopzo/view/home/product_card.dart';
import 'package:shopzo/view/quick_category/quick_category_grid.dart';
import 'package:shopzo/view/shop_by_brand/shop_by_brand_screen.dart';
import 'package:shopzo/view/top_picks/top_picks_section.dart';
import 'package:shopzo/view/trending_now/trending_now_section.dart';
import 'package:shopzo/view/top_picks/top_picks_screen.dart';
import '../../model/address/address_model.dart';
import '../../model/product/product_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/skelton_box.dart';
import '../../viewmodel/address/address_provider.dart';
import '../../viewmodel/banner_viewmodel.dart';
import '../../viewmodel/productdetails_and_list/product_list_viewmodel.dart';
import '../address/address_list_screen.dart';
import '../filter_model.dart';
import '../notification/notification_screen.dart';
import '../product_details/product_details_screen.dart';
import 'category_icons_section.dart';
import 'filter_bar_section.dart';
import '../flash_deals/flash_deals_section.dart';
import 'hero_banner_section.dart';
import 'home_appbar.dart';
import 'home_searchbar.dart';
import 'loyalty_banner_section.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const List<BrandModel> _brands = [
    BrandModel(logo: 'assets/images/pro4.jpg', name: 'Apple'),
    BrandModel(logo: 'assets/images/pro3.jpg', name: 'Samsung'),
    BrandModel(logo: 'assets/images/pro1.jpg', name: 'Adidas'),
    BrandModel(logo: 'assets/images/pro3.jpg', name: 'Amazon'),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // pull-to-refresh ke time manually true karte hain, taaki VM ke isLoading
  // ka wait kiye bina turant skeleton dikh jaye
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListViewModel>().fetchProducts();
      context.read<BannerViewModel>().fetchBanners();
    });
  }

  void _openProductDetail(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  Future<void> _handleRefresh(
      FilterProvider filterProvider, ProductListViewModel productListVm) async {
    setState(() => _isRefreshing = true); // skeleton turant ON
    filterProvider.clearAllFilters();
    await Future.wait([
      productListVm.fetchProducts(forceRefresh: true),
      context.read<BannerViewModel>().fetchBanners(),
    ]);
    if (mounted) setState(() => _isRefreshing = false); // skeleton OFF, sab data ready
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        bottom: false,
        child: Consumer3<FilterProvider, AddressProvider, ProductListViewModel>(
          builder: (context, filterProvider, addressProvider, productListVm, child) {
            // real API products, converted for ProductCard
            final apiProducts =
            productListVm.products.map((p) => ProductModel.fromApi(p)).toList();
            final filteredProducts = filterProvider.applyFilters(apiProducts);

            // ---------------- SINGLE UNIFIED LOADING FLAG ----------------
            // Ye ek hi condition decide karta hai poore home screen ke liye:
            // appbar, searchbar, aur neeche ka pura content — cold start ho
            // ya pull-to-refresh, sab isi flag se skeleton dikhayenge.
            final bool showSkeleton = _isRefreshing || productListVm.isLoading;

            return RefreshIndicator(
              color: ColorConstant.primaryColor,
              onRefresh: () => _handleRefresh(filterProvider, productListVm),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- APP BAR ----------------
                    showSkeleton
                        ? const _HomeAppBarSkeleton()
                        : HomeAppBar(
                      location: addressProvider.selectedAddress,
                      onNotificationTap: () {
                        Navigator.pushNamed(context, RouteName.notifications);
                      },
                      onLocationTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectAddressScreen(),
                          ),
                        );

                        if (result != null && result is AddressModel) {
                          addressProvider.updateAddress(result);
                        }
                      },
                    ),
                    // ---------------- SEARCH BAR ----------------
                    showSkeleton
                        ? const _HomeSearchBarSkeleton()
                        : const HomeSearchBar(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.012),

                    // ---------------- SKELETON (cold start + refresh, dono ke liye same) ----------------
                    if (showSkeleton)
                      const _HomeContentSkeleton()

                    // ---------------- ERROR (sirf tab jab loading khatam ho gaya ho aur data bhi na aaya ho) ----------------
                    else if (productListVm.status == ProductListStatus.error &&
                        apiProducts.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.04,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.wifi_off_rounded,
                                  size: 42, color: ColorConstant.placeholderColor),
                              const SizedBox(height: 10),
                              TextContext(
                                text: productListVm.errorMessage ??
                                    'home.failed_to_load_products'.tr(),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ColorConstant.labelTextColor,
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => productListVm.fetchProducts(forceRefresh: true),
                                child: TextContext(
                                  text: 'home.retry'.tr(),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    // ---------------- ACTUAL CONTENT ----------------
                    else ...[
                        // ---------------- TOP CATEGORY ICONS ----------------
                        const CategoryIconsSection(),
                        // ---------------- HERO BANNER ----------------
                        const HeroBannerSection(),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                        // ---------------- QUICK CATEGORY GRID ----------------
                        const QuickCategoryGrid(),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                        // ---------------- FLASH DEALS ----------------
                        if (apiProducts.isNotEmpty)
                          FlashDealsSection(
                            products: apiProducts.take(3).toList(),
                            onProductTap: (product) => _openProductDetail(product.id!),
                            onSeeAllTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FlashDealsScreen(products: apiProducts),
                                ),
                              );
                            },
                          ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        // ---------------- LOYALTY BANNER ----------------
                        const LoyaltyBannerSection(),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                        // ---------------- TOP PICKS ----------------
                        if (apiProducts.length > 3)
                          TopPicksSection(
                            products: apiProducts.skip(3).take(3).toList(),
                            onProductTap: (product) => _openProductDetail(product.id!),
                            onSeeAllTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopPicksScreen(),
                                ),
                              );
                            },
                          ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                        // ---------------- SHOP BY BRAND ----------------
                        ShopByBrandSection(brands: HomeScreen._brands),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        // ---------------- FILTER BAR ----------------
                        const FilterBarSection(),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        // ---------------- FILTERED RESULTS ----------------
                        if (filterProvider.state.isFilterApplied) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextContext(
                                  text: 'home.results'.tr(
                                    args: [
                                      filteredProducts.length.toString(),
                                    ],
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.headlineTextColor,
                                ),
                                TextButton(
                                  onPressed: filterProvider.clearAllFilters,
                                  child: TextContext(
                                    text: 'home.clear_filters'.tr(),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstant.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (filteredProducts.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.05),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredProducts.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: MediaQuery.of(context).size.height * 0.02,
                                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.04,
                                  childAspectRatio: (MediaQuery.of(context).size.width * 0.45) /
                                      (MediaQuery.of(context).size.height * 0.29),
                                ),
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return ProductCard(
                                    product: product,
                                    width: MediaQuery.of(context).size.width * 0.45,
                                    variant: ProductCardVariant.pick,
                                    onTap: () => _openProductDetail(product.id!),
                                  );
                                },
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.height * 0.1,
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 60,
                                      color: ColorConstant.placeholderColor,
                                    ),
                                    const SizedBox(height: 16),
                                    TextContext(
                                      text: 'home.no_products_found'.tr(),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstant.bodyTextColor,
                                    ),
                                    TextContext(
                                      text: 'home.try_adjusting_filters'.tr(),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorConstant.placeholderColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        // ---------------- TRENDING NOW (real data, shown always) ----------------
                        if (!filterProvider.state.isFilterApplied && apiProducts.isNotEmpty)
                          TrendingNowSection(
                            products: apiProducts,
                            onProductTap: (product) => _openProductDetail(product.id!),
                          ),
                        if (!filterProvider.state.isFilterApplied && apiProducts.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.06,
                            ),
                            child: Center(
                              child: TextContext(
                                text: 'home.no_products_available'.tr(),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ColorConstant.labelTextColor,
                              ),
                            ),
                          ),
                      ],
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// HomeAppBar (address + notification icon) ka skeleton placeholder
class _HomeAppBarSkeleton extends StatelessWidget {
  const _HomeAppBarSkeleton();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // location pin icon placeholder
          SkeletonBox(
            width: 22,
            height: 22,
            borderRadius: BorderRadius.circular(11),
          ),
          SizedBox(width: w * 0.02),
          // address text placeholder (two lines: "Deliver to" + address)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(
                  width: w * 0.22,
                  height: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                SkeletonBox(
                  width: w * 0.5,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.03),
          // notification bell placeholder
          SkeletonBox(
            width: 38,
            height: 38,
            borderRadius: BorderRadius.circular(19),
          ),
        ],
      ),
    );
  }
}

/// HomeSearchBar ka skeleton placeholder
class _HomeSearchBarSkeleton extends StatelessWidget {
  const _HomeSearchBarSkeleton();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: SkeletonBox(
        width: double.infinity,
        height: 46,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _HomeContentSkeleton extends StatelessWidget {
  const _HomeContentSkeleton();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
              itemBuilder: (_, __) => Column(
                children: [
                  SkeletonBox(
                    width: 52,
                    height: 52,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  const SizedBox(height: 6),
                  SkeletonBox(
                    width: 40,
                    height: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: h * 0.02),
          // hero banner
          SkeletonBox(
            width: double.infinity,
            height: h * 0.18,
            borderRadius: BorderRadius.circular(16),
          ),
          SizedBox(height: h * 0.02),
          // quick category grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, __) => Column(
              children: [
                SkeletonBox(
                  width: 50,
                  height: 50,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 6),
                SkeletonBox(width: 40, height: 8, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
          SizedBox(height: h * 0.025),
          // section title
          SkeletonBox(width: 140, height: 16, borderRadius: BorderRadius.circular(4)),
          SizedBox(height: h * 0.015),
          // flash deals row (2 cards)
          Row(
            children: List.generate(
              2,
                  (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 0 ? 12 : 0),
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 220,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: h * 0.03),
          // loyalty banner
          SkeletonBox(
            width: double.infinity,
            height: h * 0.09,
            borderRadius: BorderRadius.circular(14),
          ),
          SizedBox(height: h * 0.025),
          // top picks title + row (3 cards)
          SkeletonBox(width: 120, height: 16, borderRadius: BorderRadius.circular(4)),
          SizedBox(height: h * 0.015),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
              itemBuilder: (_, __) => SkeletonBox(
                width: w * 0.4,
                height: 220,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          SizedBox(height: h * 0.03),
          // trending grid (4 items)
          SkeletonBox(width: 130, height: 16, borderRadius: BorderRadius.circular(4)),
          SizedBox(height: h * 0.015),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: h * 0.02,
              crossAxisSpacing: w * 0.04,
              childAspectRatio: (w * 0.45) / (h * 0.29),
            ),
            itemBuilder: (_, __) => SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}