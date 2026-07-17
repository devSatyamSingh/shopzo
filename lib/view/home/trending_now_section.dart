import 'package:flutter/material.dart';
import 'package:shopzo/view/home/product_card.dart';
import 'package:shopzo/view/home/product_model.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class TrendingNowSection extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onAddTap;

  const TrendingNowSection({
    super.key,
    required this.products,
    this.onProductTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = (size.width - size.width * 0.05 * 2 - size.width * 0.04) / 2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextContext(
            text: 'Trending Now',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorConstant.headlineTextColor,
          ),
          SizedBox(height: size.height * 0.02),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: size.height * 0.02,
              crossAxisSpacing: size.width * 0.04,
              childAspectRatio: cardWidth / (size.height * 0.28),
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                width: cardWidth,
                variant: ProductCardVariant.trending,
                onTap: () => onProductTap?.call(product),
                onAddTap: () => onAddTap?.call(product),
              );
            },
          ),
        ],
      ),
    );
  }
}