import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import 'all_brands_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BrandModel {
  final String logo;
  final String name;
  final int? productCount;

  const BrandModel({
    required this.logo,
    required this.name,
    this.productCount,
  });
}

class ShopByBrandSection extends StatelessWidget {
  final List<BrandModel> brands;
  final ValueChanged<BrandModel>? onBrandTap;

  const ShopByBrandSection({
    super.key,
    required this.brands,
    this.onBrandTap,
  });

  void _onViewAll(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AllBrandsScreen(brands: brands)),
    );
  }

  void _onBrandTap(BuildContext context, BrandModel brand) {
    // let the parent know too (e.g. for analytics), then navigate
    onBrandTap?.call(brand);

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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.18;
    context.watch<LanguageProvider>();


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============ HEADER ============
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextContext(
                text: 'brands.shop_by_brand'.tr(),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
              InkWell(
                onTap: () => _onViewAll(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      TextContext(
                        text: 'brands.view_all'.tr(),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: ColorConstant.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.018),

        // ============ BRANDS HORIZONTAL LIST ============
        SizedBox(
          height: circleSize + size.height * 0.045,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            itemCount: brands.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.045),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return _buildBrandItem(context, size, brand, circleSize);
            },
          ),
        ),
      ],
    );
  }

  // ============ BRAND ITEM ============
  Widget _buildBrandItem(BuildContext context, Size size, BrandModel brand, double circleSize) {
    return GestureDetector(
      onTap: () => _onBrandTap(context, brand),
      child: Column(
        children: [
          // Circle with gradient shadow
          Container(
            height: circleSize,
            width: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorConstant.primaryColor.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorConstant.fieldFillColor,
                    Colors.white,
                  ],
                ),
                border: Border.all(
                  color: ColorConstant.borderColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
          ),

          SizedBox(height: size.height * 0.008),

          // Brand Name
          TextContext(
            text: brand.name,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorConstant.headlineTextColor,
          ),

          // Product Count (if available)
          if (brand.productCount != null) ...[
            SizedBox(height: size.height * 0.002),
            TextContext(
              text: 'brands.products'.tr(
                args: [brand.productCount.toString()],
              ),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: ColorConstant.placeholderColor,
            ),
          ],
        ],
      ),
    );
  }
}