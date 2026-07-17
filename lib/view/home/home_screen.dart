import 'package:flutter/material.dart';
import 'package:shopzo/view/home/product_model.dart';
import 'package:shopzo/view/home/quick_category_grid.dart';
import 'package:shopzo/view/home/shop_by_brand_screen.dart';
import 'package:shopzo/view/home/top_picks_section.dart';
import 'package:shopzo/view/home/trending_now_section.dart';
import '../../res/color_constant.dart';
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

  // 👉 replace all of this with real API data
  static const List<ProductModel> _flashDeals = [
    ProductModel(
      image: 'assets/images/pro3.jpg',
      name: 'Nebula Phone X',
      price: 54999,
      originalPrice: 72999,
    ),
    ProductModel(
      image: 'assets/images/pro12.jpg',
      name: 'Solaris Frames',
      price: 8500,
      originalPrice: 10000,
    ),
    ProductModel(
      image: 'assets/images/pro1.jpg',
      name: 'Aero Buds Pro',
      price: 3499,
      originalPrice: 4999,
    ),
  ];

  static const List<ProductModel> _topPicks = [
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
  ];

  static const List<ProductModel> _trending = [
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
    BrandModel(logo: 'assets/images/pro3.jpg', name: 'Amazon'),
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
        child: RefreshIndicator(
          color: ColorConstant.primaryColor,
          onRefresh: () async {
            // 👉 reload home data here
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- APP BAR ----------------
                const HomeAppBar(),

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
                  products: HomeScreen._flashDeals,
                  onProductTap: (product) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductDetailScreen(),
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
                  products: HomeScreen._topPicks,
                  onProductTap: (product) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductDetailScreen(),
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

                // ---------------- TRENDING NOW ----------------
                TrendingNowSection(
                  products: HomeScreen._trending,
                  onProductTap: (product) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductDetailScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}