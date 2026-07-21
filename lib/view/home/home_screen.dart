import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/view/flash_deals_screen.dart';
import 'package:shopzo/view/home/product_card.dart';
import 'package:shopzo/view/home/product_model.dart';
import 'package:shopzo/view/home/quick_category_grid.dart';
import 'package:shopzo/view/home/shop_by_brand_screen.dart';
import 'package:shopzo/view/home/top_picks_section.dart';
import 'package:shopzo/view/home/trending_now_section.dart';
import 'package:shopzo/view/top_picks_screen.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../viewmodel/address_provider.dart';
import '../address/address_list_screen.dart';
import '../filter_model.dart';
import '../notification_screen.dart';
import '../product_details/product_details_screen.dart';
import 'category_icons_section.dart';
import 'filter_bar_section.dart';
import 'flash_deals_section.dart';
import 'hero_banner_section.dart';
import 'home_appbar.dart';
import 'home_searchbar.dart';
import 'loyalty_banner_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const List<ProductModel> _allProducts = [
    // Add all your products here - combine flash deals, top picks, trending
    ProductModel(
      image: 'assets/images/pro3.jpg',
      name: 'Nebula Phone X',
      price: 54999,
      originalPrice: 72999,
      rating: 4.7,
    ),
    ProductModel(
      image: 'assets/images/pro12.jpg',
      name: 'Solaris Frames',
      price: 8500,
      originalPrice: 10000,
      rating: 4.5,
    ),
    ProductModel(
      image: 'assets/images/pro1.jpg',
      name: 'Aero Buds Pro',
      price: 3499,
      originalPrice: 4999,
      rating: 4.3,
    ),
    ProductModel(
      image: 'assets/images/pro2.jpg',
      name: 'Luxe Glow Serum',
      price: 1899,
      rating: 4.8,
      reviewCount: 1200,
    ),
    ProductModel(
      image: 'assets/images/pro8.jpg',
      name: 'SonicWave Portable',
      price: 3450,
      rating: 4.6,
      reviewCount: 850,
    ),
    ProductModel(
      image: 'assets/images/pro7.jpg',
      name: 'Aura Desk Lamp',
      price: 1299,
      rating: 4.7,
      reviewCount: 430,
    ),
    ProductModel(
      image: 'assets/images/pro7.jpg',
      name: 'Barista Pro X1',
      price: 12499,
      rating: 4.9,
      badgeText: 'NEW',
    ),
    ProductModel(
      image: 'assets/images/pro8.jpg',
      name: 'ErgoFit Desk Chair',
      price: 8900,
      rating: 4.7,
      badgeText: 'BESTSELLER',
    ),
    ProductModel(
      image: 'assets/images/pro9.jpg',
      name: 'Forest Tote Bag',
      price: 3200,
      rating: 4.5,
    ),
    ProductModel(
      image: 'assets/images/pro10.jpg',
      name: 'Terra Dinner Set',
      price: 4599,
      rating: 4.8,
    ),
  ];

  static const List<BrandModel> _brands = [
    BrandModel(logo: 'assets/images/pro4.jpg', name: 'Apple'),
    BrandModel(logo: 'assets/images/pro3.jpg', name: 'Samsung'),
    BrandModel(logo: 'assets/images/pro1.jpg', name: 'Adidas'),
    BrandModel (logo: 'assets/images/pro3.jpg', name: 'Amazon'),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        bottom: false,
        child: Consumer2<FilterProvider, AddressProvider>(
          builder: (context, filterProvider, addressProvider, child) {
            final filteredProducts = filterProvider.applyFilters(HomeScreen._allProducts);

            return RefreshIndicator(
              color: ColorConstant.primaryColor,
              onRefresh: () async {
                filterProvider.clearAllFilters();
                await Future.delayed(const Duration(milliseconds: 800));
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

                        if (result != null && result is SavedAddressModel) {
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
                    // ---------------- FLASH DEALS ----------------
                    FlashDealsSection(
                      products: HomeScreen._allProducts.take(3).toList(),
                      onProductTap: (product) {
                        Navigator.pushNamed(context, RouteName.productDetail);
                      },
                      onSeeAllTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashDealsScreen(
                              products: HomeScreen._allProducts,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    // ---------------- LOYALTY BANNER ----------------
                    const LoyaltyBannerSection(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                    // ---------------- TOP PICKS ----------------
                    TopPicksSection(
                      products: HomeScreen._allProducts.skip(3).take(3).toList(),
                      onProductTap: (product) {
                        Navigator.pushNamed(context, RouteName.productDetail);
                      },
                      onSeeAllTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopPicksScreen(
                              products: HomeScreen._allProducts,
                            ),
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
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
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
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredProducts.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: MediaQuery.of(context).size.height * 0.02,
                              crossAxisSpacing: MediaQuery.of(context).size.width * 0.04,
                              childAspectRatio: (MediaQuery.of(context).size.width * 0.45) / (MediaQuery.of(context).size.height * 0.30),
                            ),
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                width: MediaQuery.of(context).size.width * 0.45,
                                variant: ProductCardVariant.pick,
                                onTap: () {
                                  Navigator.pushNamed(context, RouteName.productDetail);
                                },
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
                    // ---------------- TRENDING NOW (shown always) ----------------
                    if (!filterProvider.state.isFilterApplied)
                      TrendingNowSection(
                        products: HomeScreen._allProducts,
                        onProductTap: (product) {
                          Navigator.pushNamed(context, RouteName.productDetail);
                        },
                      ),
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