import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class BrandModel {
  final String logo;
  final String name;

  const BrandModel({required this.logo, required this.name});
}

class ShopByBrandSection extends StatelessWidget {
  final List<BrandModel> brands;
  final ValueChanged<BrandModel>? onBrandTap;

  const ShopByBrandSection({
    super.key,
    required this.brands,
    this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.17;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: TextContext(
            text: 'Shop By Brand',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ColorConstant.headlineTextColor,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        SizedBox(
          height: circleSize + size.height * 0.045,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            itemCount: brands.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.05),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return GestureDetector(
                onTap: () => onBrandTap?.call(brand),
                child: Column(
                  children: [
                    Container(
                      height: circleSize,
                      width: circleSize,
                      decoration: BoxDecoration(
                        color: ColorConstant.fieldFillColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: ColorConstant.borderColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          brand.logo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.storefront_rounded,
                            color: ColorConstant.placeholderColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.007),
                    TextContext(
                      text: brand.name,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.bodyTextColor,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}