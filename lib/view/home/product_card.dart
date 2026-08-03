import 'package:flutter/material.dart';
import '../../model/product/product_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

enum ProductCardVariant { deal, pick, trending }

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final ProductCardVariant variant;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.width,
    this.variant = ProductCardVariant.pick,
    this.onTap,
    this.onWishlistTap,
    this.onAddTap,
  });

  bool get _isNetworkImage => product.image.startsWith('http');

  Widget _buildImage(double imageHeight) {
    if (product.image.isEmpty) {
      return Container(
        height: imageHeight,
        width: width,
        color: ColorConstant.fieldFillColor,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: ColorConstant.placeholderColor, size: 28),
      );
    }

    if (_isNetworkImage) {
      return Image.network(
        product.image,
        height: imageHeight,
        width: width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: imageHeight,
            width: width,
            color: ColorConstant.fieldFillColor,
            alignment: Alignment.center,
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: imageHeight,
          width: width,
          color: ColorConstant.fieldFillColor,
          alignment: Alignment.center,
          child: Icon(Icons.image_outlined, color: ColorConstant.placeholderColor, size: 28),
        ),
      );
    }

    return Image.asset(
      product.image,
      height: imageHeight,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: imageHeight,
        width: width,
        color: ColorConstant.fieldFillColor,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: ColorConstant.placeholderColor, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = width * 0.92;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColorConstant.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- IMAGE + OVERLAYS ----------------
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: _buildImage(imageHeight),
                ),

                // ---- top-left badge (discount % OR NEW/BESTSELLER) ----
                if (variant == ProductCardVariant.deal &&
                    product.discountPercent != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      text: '-${product.discountPercent}%',
                      color: ColorConstant.discountBadgeColor,
                    ),
                  ),
                if (variant == ProductCardVariant.trending &&
                    product.badgeText != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      text: product.badgeText!,
                      color: product.badgeText == 'NEW'
                          ? ColorConstant.successColor
                          : ColorConstant.orangeColor,
                    ),
                  ),

                // ---- top-right wishlist heart ----
                if (variant == ProductCardVariant.deal)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: ColorConstant.whiteColor.withOpacity(.9),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          product.isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 15,
                          color: ColorConstant.wishlistColor,
                        ),
                      ),
                    ),
                  ),

                // ---- bottom-right add-to-cart (trending variant) ----
                if (variant == ProductCardVariant.trending)
                  Positioned(
                    bottom: 8,
                    right: 10,
                    child: GestureDetector(
                      onTap: onAddTap,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: ColorConstant.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ColorConstant.primaryColor.withOpacity(.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: variant == ProductCardVariant.trending ? 12 : 8),

            // ---------------- RATING (pick / trending) ----------------
            if (variant != ProductCardVariant.deal && product.rating != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 14, color: ColorConstant.ratingStarColor),
                    const SizedBox(width: 3),
                    TextContext(
                      text: product.rating!.toStringAsFixed(1),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),
                    if (product.reviewCount != null) ...[
                      const SizedBox(width: 3),
                      TextContext(
                        text: '(${product.reviewCount})',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ],
                ),
              ),

            if (variant != ProductCardVariant.deal && product.rating != null)
              const SizedBox(height: 4),

            // ---------------- NAME ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextContext(
                text: product.name,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: ColorConstant.headlineTextColor,
              ),
            ),

            const SizedBox(height: 4),

            // ---------------- PRICE ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  TextContext(
                    text: product.formattedPrice,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.headlineTextColor,
                  ),
                  if (product.formattedOriginalPrice != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      product.formattedOriginalPrice!,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        color: ColorConstant.placeholderColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: variant == ProductCardVariant.trending ? 18 : 10),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}