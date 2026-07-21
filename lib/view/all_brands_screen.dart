import 'package:flutter/material.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';
import '../../routes/route_name.dart';
import 'home/shop_by_brand_screen.dart';

/// Shopzo — All Brands screen.
/// Reached from "View All" on the Shop By Brand section. Tapping any
/// brand opens the SAME product-listing screen used for categories
/// (CategoryProductsScreen) — a brand is just filtered the same way
/// a category is, so there's no need for a separate listing screen.
class AllBrandsScreen extends StatefulWidget {
  final List<BrandModel> brands;

  const AllBrandsScreen({super.key, required this.brands});

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<BrandModel> get _filteredBrands {
    if (_query.trim().isEmpty) return widget.brands;
    final q = _query.trim().toLowerCase();
    return widget.brands.where((b) => b.name.toLowerCase().contains(q)).toList();
  }

  void _onBrandTap(BrandModel brand) {
    Navigator.pushNamed(
      context,
      RouteName.categoryProducts,
      arguments: {
        'categoryId': brand.name,
        'categoryName': brand.name,
        'tintColor': ColorConstant.fieldFillColor,
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final brands = _filteredBrands;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('All Brands'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.015,
              ),
              child: CustomTextField(
                controller: _searchController,
                hintText: 'Search brands',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: ColorConstant.placeholderColor, size: 22),
                suffixIcon: _query.isEmpty
                    ? null
                    : InkWell(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  child: const Icon(Icons.close_rounded,
                      color: ColorConstant.placeholderColor, size: 20),
                ),
                fillColor: ColorConstant.fieldFillColor,
                borderRadius: 16,
                showBorder: false,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),

            Expanded(
              child: brands.isEmpty
                  ? Center(
                child: TextContext(
                  text: 'No brands found',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.labelTextColor,
                ),
              )
                  : GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.05,
                  0,
                  size.width * 0.05,
                  size.height * 0.02,
                ),
                itemCount: brands.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: size.width * 0.03,
                  mainAxisSpacing: size.height * 0.022,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  return _BrandGridTile(
                    brand: brand,
                    onTap: () => _onBrandTap(brand),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandGridTile extends StatelessWidget {
  final BrandModel brand;
  final VoidCallback onTap;

  const _BrandGridTile({required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.19;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: circleSize,
            width: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstant.whiteColor,
              border: Border.all(color: ColorConstant.borderColor.withOpacity(.6)),
              boxShadow: [
                BoxShadow(
                  color: ColorConstant.blackColor.withOpacity(.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                brand.logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.storefront_rounded,
                  size: circleSize * 0.4,
                  color: ColorConstant.placeholderColor,
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.008),
          TextContext(
            text: brand.name,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: ColorConstant.headlineTextColor,
          ),
          if (brand.productCount != null)
            TextContext(
              text: '${brand.productCount} Products',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: ColorConstant.placeholderColor,
            ),
        ],
      ),
    );
  }
}