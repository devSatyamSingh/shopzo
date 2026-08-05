// lib/view/home/top_picks_section.dart
import 'package:flutter/material.dart';
import 'package:shopzo/view/home/product_card.dart';
import 'package:shopzo/model/product/product_model.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import 'top_picks_screen.dart';

class TopPicksSection extends StatelessWidget {
  final List<ProductModel> products;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<ProductModel>? onProductTap;

  const TopPicksSection({
    super.key,
    required this.products,
    this.onSeeAllTap,
    this.onProductTap,
  });

  void _navigateToTopPicksScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopPicksScreen(
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Row(
            children: [
              TextContext(
                text: 'Top Picks For You',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAllTap ?? () => _navigateToTopPicksScreen(context),
                child: TextContext(
                  text: 'See All',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.015),

        SizedBox(
          height: size.height * 0.26,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.03),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                width: size.width * 0.4,
                variant: ProductCardVariant.pick,
                onTap: () => onProductTap?.call(product),
              );
            },
          ),
        ),
      ],
    );
  }
}