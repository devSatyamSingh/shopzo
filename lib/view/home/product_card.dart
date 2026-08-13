import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/product/product_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/cart/cart_viewmodel.dart';
import '../../viewmodel/wishlist_viewmodel.dart';

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

  Widget _buildImage(double imageHeight, double imageRadius) {
    Widget fallback() => Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorConstant.fieldFillColor, ColorConstant.primaryLight.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: ColorConstant.placeholderColor, size: imageHeight * 0.24),
    );

    if (product.image.isEmpty) return fallback();

    if (_isNetworkImage) {
      return Image.network(
        product.image,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: imageHeight,
            width: double.infinity,
            color: ColorConstant.fieldFillColor,
            alignment: Alignment.center,
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor),
            ),
          );
        },
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    return Image.asset(
      product.image,
      height: imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ---- responsive tokens, sab jagah inhi se derive honge ----
    final double cardPadding = size.width * 0.022;
    final double cardRadius = size.width * 0.05;
    final double imageRadius = size.width * 0.042;
    final double imageHeight = width * 0.88;
    final double contentGap = size.height * 0.006;
    final double horizontalTextPad = size.width * 0.020;
    final double nameFontSize = size.width * 0.029;
    final double priceFontSize = size.width * 0.025;
    final double ratingFontSize = size.width * 0.022;
    final double badgeIconSize = size.width * 0.028;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(.06),
              blurRadius: 18,
              offset: Offset(0, size.height * 0.008),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- FRAMED IMAGE ----------------
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(imageRadius),
                  child: _buildImage(imageHeight, imageRadius),
                ),

                // ---- top-left badge (discount % OR NEW/BESTSELLER) ----
                if (variant == ProductCardVariant.deal && product.discountPercent != null)
                  Positioned(
                    top: size.height * 0.01,
                    left: size.width * 0.02,
                    child: _Badge(
                      text: '-${product.discountPercent}%',
                      color: ColorConstant.discountBadgeColor,
                      fontSize: size.width * 0.026,
                    ),
                  ),
                if (variant == ProductCardVariant.trending && product.badgeText != null)
                  Positioned(
                    top: size.height * 0.01,
                    left: size.width * 0.02,
                    child: _Badge(
                      text: product.badgeText!,
                      color: product.badgeText == 'NEW'
                          ? ColorConstant.successColor
                          : ColorConstant.orangeColor,
                      fontSize: size.width * 0.026,
                    ),
                  ),

                // ---- top-right wishlist heart (glassy floating circle) ----
                if (variant == ProductCardVariant.deal)
                  Positioned(
                    top: size.height * 0.009,
                    right: size.width * 0.015,
                    child: Consumer<WishlistViewModel>(
                      builder: (context, wishlistVm, _) {
                        final isWishlisted = wishlistVm.isWishlisted(product.id!);

                        return GestureDetector(
                          onTap: onWishlistTap ??
                                  () async {
                                final result = await wishlistVm.toggleFromProductDetail(
                                  productId: product.id!,
                                  productName: product.name,
                                  displayPrice: product.price,
                                );
                                if (result == null) {
                                  AppUtils.error(null, 'Failed to update wishlist. Please try again.');
                                } else {
                                  AppUtils.success(null, result ? 'Added to wishlist' : 'Removed from wishlist');
                                }
                              },
                          child: Container(
                            height: size.width * 0.070,
                            width: size.width * 0.070,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: ColorConstant.blackColor.withOpacity(.10), blurRadius: 8),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: badgeIconSize,
                              color: ColorConstant.wishlistColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // ---- signature: floating add-to-cart circle, half over
                // the image's bottom edge (trending variant) ----
                if (variant == ProductCardVariant.trending)
                  Positioned(
                    bottom: -(size.width * 0.0),
                    right: size.width * 0.018,
                    child: Consumer<CartViewModel>(
                      builder: (context, cartVm, _) {
                        final bool inCart = cartVm.isInCart(product.id!);
                        final bool isAdding = cartVm.isAdding(product.id!);

                        return GestureDetector(
                          onTap: isAdding
                              ? null
                              : () async {
                            if (inCart) {
                              final item = cartVm.cart.findItem(product.id!, null);
                              if (item != null) {
                                await cartVm.removeItem(itemId: item.id, context: context);
                              }
                            } else {
                              await cartVm.addToCart(
                                productId: product.id!,
                                quantity: 1,
                                context: context,
                              );
                            }
                            onAddTap?.call();
                          },
                          child: Container(
                            height: size.width * 0.075,
                            width: size.width * 0.075,
                            decoration: BoxDecoration(
                              color: inCart ? ColorConstant.errorColor : ColorConstant.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: ColorConstant.cardBgColor, width: size.width * 0.005),
                              boxShadow: [
                                BoxShadow(
                                  color: (inCart ? ColorConstant.errorColor : ColorConstant.primaryColor)
                                      .withOpacity(.35),
                                  blurRadius: 5
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: isAdding
                                ? SizedBox(
                              height: size.width * 0.045,
                              width: size.width * 0.045,
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Icon(
                              inCart ? Icons.remove_rounded : Icons.add_rounded,
                              color: Colors.white,
                              size: size.width * 0.05,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            SizedBox(height: variant == ProductCardVariant.trending ? contentGap * 2.2 : contentGap * 1.4),

            // ---------------- RATING (pick / trending) ----------------
            if (variant != ProductCardVariant.deal && product.rating != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalTextPad),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: ratingFontSize * 1.2, color: ColorConstant.ratingStarColor),
                    SizedBox(width: size.width * 0.008),
                    TextContext(
                      text: product.rating!.toStringAsFixed(1),
                      fontSize: ratingFontSize,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.headlineTextColor,
                    ),
                    if (product.reviewCount != null) ...[
                      SizedBox(width: size.width * 0.008),
                      TextContext(
                        text: '(${product.reviewCount})',
                        fontSize: ratingFontSize * 0.92,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ],
                ),
              ),

            if (variant != ProductCardVariant.deal && product.rating != null)
              SizedBox(height: contentGap * 0.5),

            // ---------------- NAME ----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalTextPad),
              child: TextContext(
                text: product.name,
                fontSize: nameFontSize,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: ColorConstant.headlineTextColor,
              ),
            ),

            SizedBox(height: contentGap * 0.8),

            // ---------------- PRICE TAG ----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalTextPad),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.004,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.circular(size.width * 0.02),
                    ),
                    child: Text(
                      product.formattedPrice,
                      style: TextStyle(
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  if (product.formattedOriginalPrice != null) ...[
                    SizedBox(width: size.width * 0.016),
                    Flexible(
                      child: Text(
                        product.formattedOriginalPrice!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: priceFontSize * 0.7,
                          fontFamily: 'Poppins',
                          color: ColorConstant.placeholderColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: variant == ProductCardVariant.trending ? contentGap * 1.8 : contentGap * 0.9),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const _Badge({required this.text, required this.color, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.7, vertical: fontSize * 0.32),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(fontSize * 0.6),
        boxShadow: [
          BoxShadow(color: color.withOpacity(.4), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}