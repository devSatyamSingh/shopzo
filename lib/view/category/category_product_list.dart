import 'package:flutter/material.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';

/// Shopzo — single product model for the category listing grid.
/// 👉 once API is wired, replace `_dummyProducts` with the real
/// fetch (filtered by `categoryId`) inside `initState`.
class CategoryProductModel {
  final String image;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final bool isWishlisted;

  const CategoryProductModel({
    required this.image,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    this.isWishlisted = false,
  });

  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}

/// One screen for every category — pass in the category's id/name/tint
/// (same tint used on the category card in CategoryScreen) and this
/// screen re-themes itself to match. Navigate to it like:
///
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => CategoryProductsScreen(
///     categoryId: item.id,       // 👉 use this to filter the API call
///     categoryName: item.name,
///     tintColor: item.tintColor,
///   ),
/// ));
class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color tintColor;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.tintColor,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSortIndex = -1;
  bool _isLoading = false; // 👉 flip true while the real API call is in-flight

  // ---- dummy data — replace with API result filtered by widget.categoryId ----
  late final List<CategoryProductModel> _products = const [
    CategoryProductModel(
      image: 'assets/images/pro1.jpg',
      name: 'Urban Runner Sneakers',
      price: 2499,
      originalPrice: 3999,
      rating: 4.6,
      reviewCount: 340,
    ),
    CategoryProductModel(
      image: 'assets/images/pro2.jpg',
      name: 'Classic Canvas Shoes',
      price: 1299,
      rating: 4.4,
      reviewCount: 128,
    ),
    CategoryProductModel(
      image: 'assets/images/pro3.jpg',
      name: 'ProFlex Running Shoes',
      price: 3299,
      originalPrice: 4499,
      rating: 4.8,
      reviewCount: 512,
    ),
    CategoryProductModel(
      image: 'assets/images/pro4.jpg',
      name: 'Everyday Slip-Ons',
      price: 999,
      rating: 4.2,
      reviewCount: 87,
    ),
    CategoryProductModel(
      image: 'assets/images/pro8.jpg',
      name: 'Trail Grip Boots',
      price: 2899,
      originalPrice: 3599,
      rating: 4.5,
      reviewCount: 203,
    ),
    CategoryProductModel(
      image: 'assets/images/pro9.jpg',
      name: 'Lightweight Sports Shoes',
      price: 1799,
      rating: 4.3,
      reviewCount: 156,
    ),
  ];

  static const List<String> _sortOptions = ['Popular', 'Price: Low', 'Price: High', 'Rating'];

  void _onProductTap(CategoryProductModel product) {
    // 👉 navigate to product detail screen
  }

  void _onWishlistTap(CategoryProductModel product) {
    // 👉 toggle wishlist via API/state
  }

  void _onAddTap(CategoryProductModel product) {
    // 👉 add to cart via API/state
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: Text(widget.categoryName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.015),

                  // ---------------- SEARCH BAR ----------------
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'Search in ${widget.categoryName}',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: ColorConstant.placeholderColor, size: 22),
                    suffixIcon: InkWell(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded,
                          color: ColorConstant.placeholderColor, size: 20),
                    ),
                    fillColor: ColorConstant.fieldFillColor,
                    borderRadius: 16,
                    showBorder: false,
                    onChanged: (value) => setState(() {}),
                  ),

                  SizedBox(height: size.height * 0.018),

                  // ---------------- CATEGORY BANNER STRIP ----------------
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.016,
                    ),
                    decoration: BoxDecoration(
                      color: widget.tintColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextContext(
                                text: widget.categoryName,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: ColorConstant.headlineTextColor,
                              ),
                              const SizedBox(height: 3),
                              TextContext(
                                text: '${_products.length} products available',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: ColorConstant.labelTextColor,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.local_offer_rounded,
                            size: 30, color: ColorConstant.headlineTextColor.withOpacity(.3)),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.018),

                  // ---------------- SORT CHIPS ----------------
                  SizedBox(
                    height: size.height * 0.04,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sortOptions.length,
                      separatorBuilder: (_, __) => SizedBox(width: size.width * 0.02),
                      itemBuilder: (context, index) {
                        final selected = index == _selectedSortIndex;
                        return GestureDetector(
                          onTap: () => setState(
                                  () => _selectedSortIndex = selected ? -1 : index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? ColorConstant.primaryColor : ColorConstant.whiteColor,
                              borderRadius: BorderRadius.circular(20),
                              border: selected
                                  ? null
                                  : Border.all(color: ColorConstant.borderColor),
                            ),
                            child: Text(
                              _sortOptions[index],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : ColorConstant.bodyTextColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: size.height * 0.018),
                ],
              ),
            ),

            // ---------------- PRODUCT GRID ----------------
            Expanded(
              child: _isLoading
                  ? Center(
                  child: CircularProgressIndicator(color: ColorConstant.primaryColor))
                  : _products.isEmpty
                  ? _EmptyState(categoryName: widget.categoryName)
                  : GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.045,
                  0,
                  size.width * 0.045,
                  size.height * 0.02,
                ),
                itemCount: _products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: size.width * 0.026,
                  mainAxisSpacing: size.width * 0.026,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _CategoryProductCard(
                    product: product,
                    tintColor: widget.tintColor,
                    onTap: () => _onProductTap(product),
                    onWishlistTap: () => _onWishlistTap(product),
                    onAddTap: () => _onAddTap(product),
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

/// ---------------- PRODUCT CARD (same visual language as CategoryScreen cards) ----------------
class _CategoryProductCard extends StatelessWidget {
  final CategoryProductModel product;
  final Color tintColor;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onAddTap;

  const _CategoryProductCard({
    required this.product,
    required this.tintColor,
    required this.onTap,
    required this.onWishlistTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- image area ----
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    color: tintColor,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Image.asset(
                          product.image,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: ColorConstant.headlineTextColor.withOpacity(.25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.discountPercent != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColorConstant.discountBadgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
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
                ],
              ),
            ),

            // ---- info area ----
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 13, color: ColorConstant.ratingStarColor),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.headlineTextColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${product.reviewCount})',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.5,
                            color: ColorConstant.labelTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextContext(
                      text: product.name,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConstant.headlineTextColor,
                                ),
                              ),
                              if (product.originalPrice != null) ...[
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '₹${product.originalPrice!.toStringAsFixed(0)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.5,
                                      color: ColorConstant.placeholderColor,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddTap,
                          child: Container(
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              color: ColorConstant.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- EMPTY STATE ----------------
class _EmptyState extends StatelessWidget {
  final String categoryName;
  const _EmptyState({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 52, color: ColorConstant.placeholderColor),
            const SizedBox(height: 14),
            TextContext(
              text: 'No products in $categoryName yet',
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              color: ColorConstant.labelTextColor,
            ),
          ],
        ),
      ),
    );
  }
}