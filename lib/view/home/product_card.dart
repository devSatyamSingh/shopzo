import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/product/product_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/cart/cart_viewmodel.dart';
import '../../viewmodel/wishlist_viewmodel.dart';

enum ProductCardVariant { deal, pick, trending }

class _CardMetrics {
  final double cardPadding;
  final double cardRadius;
  final double imageRadius;
  final double imageHeight;
  final double contentGapAfterImage;
  final double gapRatingName;
  final double gapNamePrice;
  final double bottomPadding;
  final double nameFontSize;
  final double priceFontSize;
  final double ratingFontSize;
  final double badgeIconSize;
  final double horizontalTextPad;
  final double buttonSize;
  final double totalHeight;

  _CardMetrics._({
    required this.cardPadding,
    required this.cardRadius,
    required this.imageRadius,
    required this.imageHeight,
    required this.contentGapAfterImage,
    required this.gapRatingName,
    required this.gapNamePrice,
    required this.bottomPadding,
    required this.nameFontSize,
    required this.priceFontSize,
    required this.ratingFontSize,
    required this.badgeIconSize,
    required this.horizontalTextPad,
    required this.buttonSize,
    required this.totalHeight,
  });

  factory _CardMetrics(
      Size screenSize,
      double width,
      ProductCardVariant variant,
      bool hasRating,
      ) {
    final cardPadding = width * 0.032;
    final cardRadius = width * 0.055;
    final imageRadius = width * 0.045;
    final imageHeight = width * 0.92;
    final horizontalTextPad = screenSize.width * 0.020;
    final nameFontSize = screenSize.width * 0.029;
    final priceFontSize = screenSize.width * 0.025;
    final ratingFontSize = screenSize.width * 0.022;
    final badgeIconSize = screenSize.width * 0.028;
    final buttonSize = width * 0.19;

    // Sirf 'trending' variant me floating add-to-cart button image ke
    // bottom edge se HALF overlap karta hai — usko clear karne ke liye
    // itna hi extra gap milta hai. Baaki sab kuch SAME rehta hai.
    final gapAfterImage = screenSize.height * 0.010 +
        (variant == ProductCardVariant.trending ? (buttonSize / 2) + 4 : 0);

    const gapRatingName = 4.0;
    const gapNamePrice = 6.0;
    const bottomPadding = 8.0; // <-- ab HAR variant me SAME hai

    final showsRating = hasRating && variant != ProductCardVariant.deal;
    final ratingBlock = showsRating ? (ratingFontSize * 1.2) + gapRatingName : 0.0;

    final totalHeight = (cardPadding * 2) +
        imageHeight +
        gapAfterImage +
        ratingBlock +
        (nameFontSize * 1.3) + // 1-line name
        gapNamePrice +
        (priceFontSize * 1.9) + // price chip
        bottomPadding +
        5; // safety buffer, taaki kabhi 1-2px overflow na aaye

    return _CardMetrics._(
      cardPadding: cardPadding,
      cardRadius: cardRadius,
      imageRadius: imageRadius,
      imageHeight: imageHeight,
      contentGapAfterImage: gapAfterImage,
      gapRatingName: gapRatingName,
      gapNamePrice: gapNamePrice,
      bottomPadding: bottomPadding,
      nameFontSize: nameFontSize,
      priceFontSize: priceFontSize,
      ratingFontSize: ratingFontSize,
      badgeIconSize: badgeIconSize,
      horizontalTextPad: horizontalTextPad,
      buttonSize: buttonSize,
      totalHeight: totalHeight,
    );
  }
}

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

  /// Horizontal lists (Flash Deals / Top Picks / Trending) apne SizedBox
  /// wrapper ke liye is height ko use karein — na kam na zyada, jitni
  /// card ko chahiye utni hi. Isse "niche extra space" wala issue khatam.
  static double previewHeight(
      BuildContext context,
      double width, {
        ProductCardVariant variant = ProductCardVariant.pick,
        bool hasRating = true,
      }) {
    final size = MediaQuery.of(context).size;
    return _CardMetrics(size, width, variant, hasRating).totalHeight;
  }

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
    final hasRating = product.rating != null;
    final m = _CardMetrics(size, width, variant, hasRating);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(m.cardPadding),
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(m.cardRadius),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(.06),
              blurRadius: 18,
              offset: Offset(0, size.height * 0.008),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // <-- content jitna hai utni hi height, extra gap nahi banega
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- FRAMED IMAGE ----------------
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(m.imageRadius),
                  child: _buildImage(m.imageHeight, m.imageRadius),
                ),

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
                              size: m.badgeIconSize,
                              color: ColorConstant.wishlistColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // ---- floating add-to-cart circle: ab genuinely image ke
                // bottom edge se HALF bahar overlap karta hai. Pehle
                // 'bottom: 0' tha jisse ye button image ke andar hi
                // baitha rehta tha (bug), signature look nahi mil raha tha ----
                if (variant == ProductCardVariant.trending)
                  Positioned(
                    bottom: -(m.buttonSize / 2),
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
                            height: m.buttonSize,
                            width: m.buttonSize,
                            decoration: BoxDecoration(
                              color: inCart ? ColorConstant.errorColor : ColorConstant.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: ColorConstant.cardBgColor, width: width * 0.012),
                              boxShadow: [
                                BoxShadow(
                                  color: (inCart ? ColorConstant.errorColor : ColorConstant.primaryColor)
                                      .withOpacity(.35),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: isAdding
                                ? SizedBox(
                              height: m.buttonSize * 0.4,
                              width: m.buttonSize * 0.4,
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Icon(
                              inCart ? Icons.remove_rounded : Icons.add_rounded,
                              color: Colors.white,
                              size: m.buttonSize * 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            SizedBox(height: m.contentGapAfterImage),
            if (variant != ProductCardVariant.deal) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: m.horizontalTextPad),
                child: Opacity(
                  opacity: hasRating ? 1 : 0,
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: m.ratingFontSize * 1.2, color: ColorConstant.ratingStarColor),
                      SizedBox(width: size.width * 0.008),
                      TextContext(
                        text: (product.rating ?? 0.0).toStringAsFixed(1),
                        fontSize: m.ratingFontSize,
                        fontWeight: FontWeight.w700,
                        color: ColorConstant.headlineTextColor,
                      ),
                      SizedBox(width: size.width * 0.008),
                      TextContext(
                        text: '(${product.reviewCount ?? 0})',
                        fontSize: m.ratingFontSize * 0.92,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: m.gapRatingName),
            ],

            // ---------------- NAME ----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.horizontalTextPad),
              child: TextContext(
                text: product.name,
                fontSize: m.nameFontSize,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: ColorConstant.headlineTextColor,
              ),
            ),

            SizedBox(height: m.gapNamePrice),

            // ---------------- PRICE TAG ----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.horizontalTextPad),
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
                        fontSize: m.priceFontSize,
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
                          fontSize: m.priceFontSize * 0.7,
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
            SizedBox(height: m.bottomPadding), // <-- ab teeno variant me SAME
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