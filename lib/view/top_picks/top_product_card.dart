import 'package:flutter/material.dart';
import '../../model/top_product_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

class TopProductCard extends StatelessWidget {
  final TopProductModel product;
  final double width;
  final VoidCallback onTap;
  final IconData? badgeIcon;
  final String? badgeLabel;
  final Color? badgeColor;

  const TopProductCard({
    super.key,
    required this.product,
    required this.width,
    required this.onTap,
    this.badgeIcon,
    this.badgeLabel,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final double imgHeight = width * 1.0;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: ColorConstant.blackColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: imgHeight,
                  width: double.infinity,
                  child: (product.image != null && product.image!.isNotEmpty)
                      ? Image.network(
                    product.image!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : Container(
                      color: ColorConstant.fieldFillColor,
                      alignment: Alignment.center,
                      child: const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorBuilder: (_, __, ___) => Container(
                      color: ColorConstant.fieldFillColor,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined, size: 30, color: ColorConstant.placeholderColor),
                    ),
                  )
                      : Container(
                    color: ColorConstant.fieldFillColor,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, size: 30, color: ColorConstant.placeholderColor),
                  ),
                ),
                if (badgeLabel != null)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor ?? ColorConstant.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badgeIcon != null) ...[
                            Icon(badgeIcon, size: 11, color: Colors.white),
                            const SizedBox(width: 3),
                          ],
                          Text(badgeLabel!, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700, fontFamily: "Poppins")),
                        ],
                      ),
                    ),
                  ),
                if (!product.inStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: const Text("Out of Stock",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: "Poppins")),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(text: product.name, fontSize: 13, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (product.category != null) ...[
                    const SizedBox(height: 2),
                    TextContext(text: product.category!.name, fontSize: 10.5, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextContext(text: "₹${product.displayPrice.toStringAsFixed(0)}", fontSize: 14, fontWeight: FontWeight.w700, color: ColorConstant.primaryColor),
                      if (product.reviewCount > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: ColorConstant.ratingStarColor),
                            const SizedBox(width: 2),
                            Text(product.avgRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, fontFamily: "Poppins", color: ColorConstant.headlineTextColor)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}