import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';


class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // ---- Dummy data — replace with real data from your ViewModel/repo ----
  final List<_WishlistItem> _items = [
    _WishlistItem(
      image: "assets/images/pro1.jpg",
      name: "Elite Wireless Pro",
      price: 189,
      mrp: 249,
      discountPercent: 20,
      rating: 4.8,
      reviewCount: "214",
      badgeText: "Price Dropped",
      badgeColor: ColorConstant.orangeColor,
      state: _CardState.addToCart,
    ),
    _WishlistItem(
      image: "assets/images/pro7.jpg",
      name: "Smart Horizon Watch",
      price: 320,
      rating: 4.9,
      reviewCount: "1.2k",
      badgeText: "Only 2 left",
      badgeColor: ColorConstant.errorColor,
      state: _CardState.added,
    ),
    _WishlistItem(
      image: "assets/images/pro2.jpg",
      name: "Urban Comfort Chair",
      price: 115,
      rating: 4.6,
      reviewCount: "89",
      state: _CardState.outOfStock,
    ),
    _WishlistItem(
      image: "assets/images/pro10.jpg",
      name: "SonicBoom Portable Mug",
      price: 79,
      rating: 4.7,
      reviewCount: "450",
      badgeText: "Back in Stock",
      badgeColor: ColorConstant.successColor,
      state: _CardState.addToCart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.045,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPriceDropBanner(size),
                    SizedBox(height: size.height * 0.022),
                    _buildStaggeredGrid(context, size),
                    SizedBox(height: size.height * 0.022),
                    _buildBrowseMoreFooter(context, size),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.03,
        size.height * 0.012,
        size.width * 0.045,
        size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button — soft rounded tap target instead of a bare icon
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorConstant.fieldFillColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: ColorConstant.headlineTextColor,
                size: 22,
              ),
            ),
          ),

          // Title + item count — centered in remaining space
          Expanded(
            child: Column(
              children: [
                 TextContext(
                  text: "My Wishlist",
                  fontSize: 17,
                  color: ColorConstant.primaryColor,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                TextContext(
                  text: "${_items.length * 6} items",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Clear All — small pill-style destructive action
          InkWell(
            onTap: () {
              // TODO: call your clear-wishlist API / provider action
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 16, color: ColorConstant.errorColor),
                  const SizedBox(width: 4),
                  TextContext(
                    text: "Clear All",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.errorColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- PRICE DROP ALERT BANNER ----------------
  Widget _buildPriceDropBanner(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.035,
        vertical: size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.orangeLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: ColorConstant.orangeColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: "3 items just got cheaper!",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.headlineTextColor,
                ),
                SizedBox(height: 2),
                TextContext(
                  text: "Grab them before price goes up again",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: ColorConstant.orangeColor, size: 24),
        ],
      ),
    );
  }

  /// ---------------- 2-COLUMN STAGGERED GRID ----------------
  /// Uses two independent Columns instead of GridView so each side can
  /// have a different height (the "Out of Stock" card is taller because
  /// of its extra "Notify Me" line) without clipping or forcing a fixed
  /// aspect ratio on every card.
  Widget _buildStaggeredGrid(BuildContext context, Size size) {
    final left = <_WishlistItem>[];
    final right = <_WishlistItem>[];
    for (int i = 0; i < _items.length; i++) {
      (i.isEven ? left : right).add(_items[i]);
    }

    final double spacing = size.width * 0.03;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumn(context, size, left, spacing)),
        SizedBox(width: spacing),
        Expanded(child: _buildColumn(context, size, right, spacing)),
      ],
    );
  }

  Widget _buildColumn(
      BuildContext context,
      Size size,
      List<_WishlistItem> items,
      double spacing,
      ) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          buildProductCard(context, size, items[i]),
          if (i != items.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }

  /// ---------------- PRODUCT CARD ----------------
  Widget buildProductCard(BuildContext context, Size size, _WishlistItem item) {
    final double cardImageHeight = (size.width * 0.34).clamp(110.0, 170.0);
    final bool isOutOfStock = item.state == _CardState.outOfStock;

    return Container(
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Image + badges ----
          Stack(
            children: [
              Container(
                height: cardImageHeight,
                width: double.infinity,
                color: ColorConstant.fieldFillColor,
                alignment: Alignment.center,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              if (isOutOfStock)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Out of Stock",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                ),

              if (item.badgeText != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: item.badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: ColorConstant.whiteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorConstant.blackColor.withOpacity(0.08),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: ColorConstant.wishlistColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          // ---- Details ----
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: item.name,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // ---- Price row ----
                Row(
                  children: [
                    TextContext(
                      text: "\$${item.price.toStringAsFixed(0)}",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.primaryColor,
                    ),
                    if (item.mrp != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        "\$${item.mrp!.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontFamily: "Poppins",
                          color: ColorConstant.placeholderColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.discountPercent != null) ...[
                  const SizedBox(height: 2),
                  TextContext(
                    text: "-${item.discountPercent}%",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.successColor,
                  ),
                ],

                const SizedBox(height: 6),

                // ---- Rating row ----
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: ColorConstant.ratingStarColor, size: 16),
                    const SizedBox(width: 3),
                    TextContext(
                      text: "${item.rating}  (${item.reviewCount})",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ---- Action button (per card state) ----
                _buildCardAction(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(_WishlistItem item) {
    switch (item.state) {
      case _CardState.added:
        return CustomButton(
          text: "Added",
          height: 40,
          fontSize: 13,
          icon: Icons.check_circle_rounded,
          iconSize: 16,
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: navigate to cart or toggle back to "Add to Cart"
          },
        );

      case _CardState.outOfStock:
        return Column(
          children: [
            CustomButton(
              text: "Add to Cart",
              height: 40,
              fontSize: 13,
              color: ColorConstant.borderColor,
              textColor: ColorConstant.placeholderColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [],
              onTap: null,
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                // TODO: subscribe to back-in-stock notification
              },
              child: TextContext(
                text: "Notify Me",
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorConstant.primaryColor,
                alignment: Alignment.center,
              ),
            ),
          ],
        );

      case _CardState.addToCart:
        return CustomButton(
          text: "Add to Cart",
          height: 40,
          fontSize: 13,
          outlined: true,
          borderColor: ColorConstant.primaryColor,
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: call add-to-cart API
          },
        );
    }
  }

  /// ---------------- FOOTER — "BROWSE MORE" NUDGE ----------------
  Widget _buildBrowseMoreFooter(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.height * 0.035,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: ColorConstant.whiteColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.favorite_border_rounded,
              color: ColorConstant.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(height: size.height * 0.016),
          const TextContext(
            text: "Looking for more?",
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const TextContext(
            text: "Explore trending picks tailored just for you",
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: ColorConstant.labelTextColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),
          CustomButton(
            text: "Browse Products",
            width: size.width * 0.55,
            height: 46,
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              // TODO: navigate to Home / Product listing
            },
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Local model + enum for this screen only.
/// Move to lib/model/wishlist_item_model.dart once wired to a real API.
/// ------------------------------------------------------------
enum _CardState { addToCart, added, outOfStock }

class _WishlistItem {
  final String image; // placeholder — swap for `image` (network/asset) later
  final String name;
  final double price;
  final double? mrp;
  final int? discountPercent;
  final double rating;
  final String reviewCount;
  final String? badgeText;
  final Color? badgeColor;
  final _CardState state;

  _WishlistItem({
    required this.image,
    required this.name,
    required this.price,
    this.mrp,
    this.discountPercent,
    required this.rating,
    required this.reviewCount,
    this.badgeText,
    this.badgeColor,
    required this.state,
  });
}