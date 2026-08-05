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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Brands API not wired yet — keeping this static for now.
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

            return RefreshIndicator(
              color: ColorConstant.primaryColor,
              onRefresh: () async {
                filterProvider.clearAllFilters();
                await productListVm.fetchProducts(forceRefresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- APP BAR ----------------
                    HomeAppBar(
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
                    const HomeSearchBar(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                    // ---------------- TOP CATEGORY ICONS ----------------
                    const CategoryIconsSection(),
                    // ---------------- HERO BANNER ----------------
                    const HeroBannerSection(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                    // ---------------- QUICK CATEGORY GRID ----------------
                    const QuickCategoryGrid(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                    // ---------------- LOADING SKELETON ----------------
                    if (productListVm.isLoading && apiProducts.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                              width: 140,
                              height: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
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
                          ],
                        ),
                      )

                    // ---------------- ERROR ----------------
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
                                text: productListVm.errorMessage ?? 'Failed to load products',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ColorConstant.labelTextColor,
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => productListVm.fetchProducts(forceRefresh: true),
                                child: TextContext(
                                  text: 'Retry',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
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
                                  text: 'Results (${filteredProducts.length})',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.headlineTextColor,
                                ),
                                TextButton(
                                  onPressed: filterProvider.clearAllFilters,
                                  child: TextContext(
                                    text: 'Clear Filters',
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
                                      text: 'No products found',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstant.bodyTextColor,
                                    ),
                                    TextContext(
                                      text: 'Try adjusting your filters',
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
                                text: 'No products available right now',
                                fontSize: 13.5,
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