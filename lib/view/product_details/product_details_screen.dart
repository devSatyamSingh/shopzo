import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../model/product/product_detail_model.dart';
import '../../utils/utils.dart';
import '../../viewmodel/order_checkout/order_checkout_viewmodel.dart';
import '../../viewmodel/productdetails_and_list/product_details_viewmodel.dart';
import '../../viewmodel/cart/cart_viewmodel.dart';
import '../../viewmodel/wishlist_viewmodel.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailViewModel()..fetchProduct(productId),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView();

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  final PageController _imageController = PageController();
  final TextEditingController _pincodeController = TextEditingController();

  int _currentImageIndex = 0;
  bool _isTogglingWishlist = false;
  bool _isBuyNowLoading = false;

  final List<bool> _accordionExpanded = [true, false, false, false];
  final List<String> _accordionTitles = const
  [
    "Product Details",
    "Features",
    "Delivery & Returns",
    "Warranty Info",
  ];

  @override
  void dispose() {
    _imageController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  String _timeAgo(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (diff.inDays >= 1) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    } else if (diff.inHours >= 1) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
    }
    return 'Just now';
  }

  void _openFullScreenViewer({
    required List<String> images,
    required int initialIndex,
    List<_ReviewOverlayInfo>? reviewInfo,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageViewer(
            images: images,
            initialIndex: initialIndex,
            reviewInfo: reviewInfo,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistVm = context.read<WishlistViewModel>();
      if (wishlistVm.status != WishlistStatus.loaded) {
        wishlistVm.fetchWishlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: Consumer<ProductDetailViewModel>(
        builder: (context, vm, child) {
          // ---------------- LOADING ----------------
          if (vm.isLoading && vm.product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---------------- ERROR ----------------
          if (vm.status == ProductDetailStatus.error && vm.product == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 42,
                      color: ColorConstant.placeholderColor,
                    ),
                    const SizedBox(height: 10),
                    TextContext(
                      text: vm.errorMessage ?? 'Failed to load product',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => vm.fetchProduct(vm.productId),
                      child: TextContext(
                        text: 'Retry',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final product = vm.product!;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageGallery(context, size, vm),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.045,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.018),
                            _buildTitleBlock(size, product),
                            SizedBox(height: size.height * 0.014),
                            _buildPriceBlock(size, vm),
                            SizedBox(height: size.height * 0.022),
                            if (vm.hasVariants) ...[
                              _buildVariantSelectors(size, vm),
                              SizedBox(height: size.height * 0.022),
                            ],
                            _buildDeliveryCard(size),
                            SizedBox(height: size.height * 0.02),
                            _buildQuantityUrgencyRow(size, vm),
                            SizedBox(height: size.height * 0.022),
                            _buildAccordions(size, product, vm),
                            SizedBox(height: size.height * 0.024),
                            _buildReviewsSection(size, product),
                            SizedBox(height: size.height * 0.02),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomActionBar(context, size, product, vm),
            ],
          );
        },
      ),
    );
  }

  /// ---------------- IMAGE GALLERY ----------------
  Widget _buildImageGallery(
    BuildContext context,
    Size size,
    ProductDetailViewModel vm,
  ) {
    final double galleryHeight = (size.height * 0.36).clamp(260.0, 360.0);
    final images = vm.effectiveImages;
    final itemCount = images.isEmpty ? 1 : images.length;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: galleryHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDCE6F0), Color(0xFFEFF1F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: PageView.builder(
                  controller: _imageController,
                  itemCount: itemCount,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (context, index) {
                    if (images.isEmpty) {
                      return Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: ColorConstant.placeholderColor,
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => _openFullScreenViewer(
                        images: images,
                        initialIndex: index,
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'product_image_$index',
                          child: Image.network(
                            images[index],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: ColorConstant.placeholderColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Back button
              Positioned(
                top: 10,
                left: size.width * 0.04,
                child: _circleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),

              // Share + wishlist buttons
              Positioned(
                top: 10,
                right: size.width * 0.04,
                child: Row(
                  children: [
                    _circleIconButton(
                      icon: Icons.share_rounded,
                      onTap: () {
                        // TODO: share product link
                      },
                    ),
                    const SizedBox(width: 10),
                    Consumer<WishlistViewModel>(
                      builder: (context, wishlistVm, _) {
                        final variantId = vm.selectedVariant?.id;
                        final isWishlisted = wishlistVm.isWishlisted(vm.product!.id, variantId: variantId);

                        return _circleIconButton(
                          icon: _isTogglingWishlist
                              ? Icons.favorite_border_rounded // spinner ke waqt bhi icon jagah nahi badalti, neeche loader dikhega
                              : (isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                          iconColor: isWishlisted ? ColorConstant.wishlistColor : ColorConstant.headlineTextColor,
                          onTap: _isTogglingWishlist
                              ? () {}
                              : () async {
                            setState(() => _isTogglingWishlist = true);
                            final result = await wishlistVm.toggleFromProductDetail(
                              productId: vm.product!.id,
                              variantId: variantId,
                              productName: vm.product!.name,
                              variantName: vm.selectedVariant?.name,
                              slug: vm.product!.slug,
                              displayPrice: vm.effectivePrice,
                              stock: vm.effectiveStock,
                            );
                            if (!mounted) return;
                            setState(() => _isTogglingWishlist = false);

                            if (result == null) {
                              AppUtils.error(context, 'Failed to update wishlist. Please try again.');
                            } else {
                              AppUtils.success(
                                context,
                                result ? 'Added to wishlist' : 'Removed from wishlist',
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Dot indicator
              if (itemCount > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(itemCount, (index) {
                      final bool active = index == _currentImageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: active ? 16 : 6,
                        decoration: BoxDecoration(
                          color: active
                              ? ColorConstant.primaryColor
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),

          // ---- Thumbnails (highlight syncs with slide) ----
          if (images.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.045,
                vertical: size.height * 0.014,
              ),
              child: SizedBox(
                height: size.width * 0.15,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: size.width * 0.025),
                  itemBuilder: (context, index) {
                    final bool isSelected = index == _currentImageIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _currentImageIndex = index);
                        _imageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: size.width * 0.15,
                        decoration: BoxDecoration(
                          color: ColorConstant.fieldFillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? ColorConstant.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_outlined,
                              color: ColorConstant.placeholderColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = ColorConstant.headlineTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  /// ---------------- TITLE + RATING ----------------
  Widget _buildTitleBlock(Size size, ProductDetailModel product) {
    final allReviews = product.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.category?.name != null)
          TextContext(
            text: product.category!.name.toUpperCase(),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: ColorConstant.labelTextColor,
          ),
        const SizedBox(height: 6),
        TextContext(
          text: product.name,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
        const SizedBox(height: 10),
        if (product.avgRating > 0)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      product.avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextContext(
                text:
                    "(${allReviews.length} rating${allReviews.length == 1 ? '' : 's'})",
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
              ),
            ],
          ),
      ],
    );
  }

  /// ---------------- PRICE ----------------
  Widget _buildPriceBlock(Size size, ProductDetailViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextContext(
          text: vm.effectiveFormattedPrice,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ],
    );
  }

  /// ---------------- VARIANT / ATTRIBUTE SELECTORS ----------------
  Widget _buildVariantSelectors(Size size, ProductDetailViewModel vm) {
    final options = vm.product!.attributeOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.entries.map((entry) {
        final attrName = entry.key;
        final values = entry.value;
        final selectedValue = vm.selectedAttributes[attrName];

        return Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextContext(
                    text: attrName,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  if (selectedValue != null)
                    TextContext(
                      text: selectedValue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                ],
              ),
              SizedBox(height: size.height * 0.012),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final value = values[i];
                    final bool isAvailable = vm.isAttributeValueAvailable(
                      attrName,
                      value,
                    );
                    final bool isSelected = selectedValue == value;

                    return GestureDetector(
                      onTap: isAvailable
                          ? () => vm.toggleAttribute(attrName, value)
                          : null,
                      child: Container(
                        height: 44,
                        constraints: const BoxConstraints(minWidth: 44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ColorConstant.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? ColorConstant.primaryColor
                                : ColorConstant.borderColor,
                          ),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            decoration: isAvailable
                                ? null
                                : TextDecoration.lineThrough,
                            color: isSelected
                                ? Colors.white
                                : isAvailable
                                ? ColorConstant.headlineTextColor
                                : ColorConstant.placeholderColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// ---------------- DELIVERY CHECK CARD ----------------
  Widget _buildDeliveryCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextContext(
            text: "DELIVERY DETAILS",
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: ColorConstant.labelTextColor,
          ),
          SizedBox(height: size.height * 0.012),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13.5, fontFamily: "Poppins"),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Enter Pincode",
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: ColorConstant.placeholderColor,
                      fontFamily: "Poppins",
                    ),
                    filled: true,
                    fillColor: ColorConstant.whiteColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ColorConstant.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ColorConstant.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ColorConstant.primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CustomButton(
                text: "Check",
                width: 80,
                height: 44,
                fontSize: 13,
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // TODO: call pincode-serviceability API
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- QUANTITY + URGENCY ----------------
  Widget _buildQuantityUrgencyRow(Size size, ProductDetailViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: ColorConstant.fieldFillColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(
                Icons.remove_rounded,
                () => vm.setQuantity(vm.quantity - 1),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  "${vm.quantity}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              _qtyButton(
                Icons.add_rounded,
                () => vm.setQuantity(vm.quantity + 1),
              ),
            ],
          ),
        ),
        if (!vm.isInStock)
          TextContext(
            text: "Out of stock",
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ColorConstant.orangeColor,
          )
        else if (vm.isLowStock)
          Row(
            children: [
              const _PulsingDot(),
              const SizedBox(width: 6),
              TextContext(
                text: "Only ${vm.effectiveStock} left!",
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorConstant.orangeColor,
              ),
            ],
          ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 28,
        width: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: ColorConstant.primaryColor),
      ),
    );
  }

  /// ---------------- ACCORDIONS ----------------
  Widget _buildAccordions(
    Size size,
    ProductDetailModel product,
    ProductDetailViewModel vm,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstant.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_accordionTitles.length, (index) {
          final bool isExpanded = _accordionExpanded[index];
          final bool isLast = index == _accordionTitles.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _accordionExpanded[index] = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextContext(
                        text: _accordionTitles[index],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextContext(
                    text: _accordionBody(index, product, vm),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                    height: 1.6,
                  ),
                ),
              if (!isLast)
                const Divider(height: 1, color: ColorConstant.dividerColor),
            ],
          );
        }),
      ),
    );
  }

  String _accordionBody(
    int index,
    ProductDetailModel product,
    ProductDetailViewModel vm,
  ) {
    switch (index) {
      case 0:
        return (product.description != null &&
                product.description!.trim().isNotEmpty)
            ? product.description!
            : "No description available for this product.";
      case 1:
        final attrs = vm.selectedVariant?.attributeMap ?? const {};
        if (attrs.isEmpty) return "No additional details available.";
        return attrs.entries.map((e) => "${e.key}: ${e.value}").join(' • ');
      case 2:
        return "Delivery and return details will be shown here once available for this product.";
      default:
        return "Warranty details will be shown here once available for this product.";
    }
  }

  /// ---------------- REVIEWS SECTION ----------------
  Widget _buildReviewsSection(Size size, ProductDetailModel product) {
    final reviews = product.reviews;

    // rating distribution built from actual review data
    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      if (counts.containsKey(r.rating))
        counts[r.rating] = counts[r.rating]! + 1;
    }
    final total = reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextContext(
          text: "Customer Reviews",
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: size.height * 0.016),

        if (reviews.isEmpty)
          TextContext(
            text: "No reviews yet for this product.",
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorConstant.labelTextColor,
          )
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  TextContext(
                    text: product.avgRating.toStringAsFixed(1),
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 4),
                  TextContext(
                    text: "$total review${total == 1 ? '' : 's'}",
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),
              SizedBox(width: size.width * 0.05),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final fraction = total == 0
                        ? 0.0
                        : (counts[star] ?? 0) / total;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                            child: Text(
                              "$star",
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontFamily: "Poppins",
                                color: ColorConstant.labelTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 6,
                                backgroundColor: ColorConstant.borderColor,
                                valueColor: const AlwaysStoppedAnimation(
                                  ColorConstant.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          for (final review in reviews) ...[
            _buildReviewCard(size, review),
            SizedBox(height: size.height * 0.014),
          ],
        ],
      ],
    );
  }

  Widget _buildReviewCard(Size size, ProductReviewModel review) {
    final initial = review.customerName.isNotEmpty
        ? review.customerName[0].toUpperCase()
        : '?';

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: const BoxDecoration(
                  color: ColorConstant.primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(
                      text: review.customerName,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: i < review.rating
                              ? ColorConstant.ratingStarColor
                              : ColorConstant.borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextContext(
                text: _timeAgo(review.createdAt),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: ColorConstant.placeholderColor,
              ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            TextContext(
              text: review.comment!,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: ColorConstant.bodyTextColor,
              height: 1.5,
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _openFullScreenViewer(
                    images: review.images,
                    initialIndex: i,
                    // Har image ke saath same customer ka naam + comment jaayega,
                    // kyunki ye sab ek hi review ki images hain.
                    reviewInfo: List.generate(
                      review.images.length,
                      (_) => _ReviewOverlayInfo(
                        name: review.customerName,
                        comment: review.comment,
                        rating: review.rating,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      review.images[i],
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: ColorConstant.borderColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
      BuildContext context,
      Size size,
      ProductDetailModel product,
      ProductDetailViewModel vm,
      ) {
    final cartVm = context.watch<CartViewModel>();

    final String? variantId = vm.selectedVariant?.id;
    final bool canAct = vm.isInStock && vm.isSelectionComplete;

    final bool isAddingRaw = cartVm.isAdding(product.id);
    final bool isAddToCartLoading = isAddingRaw && !_isBuyNowLoading;
    final bool alreadyInCart = cartVm.isInCart(
      product.id,
      variantId: variantId,
    );

    // 🔧 NEW — user ko batao kyu button kaam nahi kar raha
    String? blockedReason() {
      if (!vm.isInStock) return "This item is out of stock right now";
      if (!vm.isSelectionComplete) return "Please select all options first";
      return null;
    }

    final bool isBusy = isAddingRaw || _isBuyNowLoading;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: size.height * 0.014,
        ),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: isAddToCartLoading
                    ? "Adding..."
                    : alreadyInCart
                    ? "Go to Cart"
                    : "Add to Cart",
                outlined: !alreadyInCart,
                height: 52,
                icon: alreadyInCart
                    ? Icons.shopping_cart_rounded
                    : Icons.shopping_cart_outlined,
                iconSize: 18,
                color: (!canAct && !alreadyInCart)
                    ? ColorConstant.placeholderColor
                    : null,
                onTap: isBusy
                    ? null
                    : () async {
                  final reason = blockedReason();
                  if (reason != null) {
                    AppUtils.warning(context, reason);
                    return;
                  }
                  if (alreadyInCart) {
                    Navigator.pushNamed(context, RouteName.cart);
                    return;
                  }
                  await cartVm.addToCart(
                    productId: product.id,
                    variantId: variantId,
                    quantity: vm.quantity,
                    context: context,
                  );
                },
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: CustomButton(
                text: _isBuyNowLoading ? "Please wait..." : "Buy Now",
                height: 52,
                color: !canAct ? ColorConstant.placeholderColor : null, // 🔧
                onTap: isBusy
                    ? null
                    : () async {
                  final reason = blockedReason();
                  if (reason != null) {
                    AppUtils.warning(context, reason);   // 🔧 message on tap
                    return;
                  }
                  setState(() => _isBuyNowLoading = true);
                  try {
                    final bool alreadyThere =
                    cartVm.isInCart(product.id, variantId: variantId);

                    if (!alreadyThere) {
                      final added = await cartVm.addToCart(
                        productId: product.id,
                        variantId: variantId,
                        quantity: vm.quantity,
                        context: context,
                        silent: true,
                      );
                      if (!added) return;
                    } else {
                      final existing =
                      cartVm.cart.findItem(product.id, variantId);
                      if (existing != null &&
                          existing.quantity != vm.quantity) {
                        await cartVm.updateQuantity(
                          itemId: existing.id,
                          quantity: vm.quantity,
                          context: context,
                        );
                      }
                    }

                    if (!context.mounted) return;

                    final cartItem =
                    cartVm.cart.findItem(product.id, variantId);
                    if (cartItem == null) {
                      AppUtils.error(context,
                          'Something went wrong. Please try again.');
                      return;
                    }

                    context.read<CheckoutViewModel>().startCheckout([
                      CheckoutLineItem.fromCartItem(cartItem),
                    ]);

                    if (!context.mounted) return;
                    Navigator.pushNamed(context, RouteName.checkoutAddress);
                  } finally {
                    if (mounted) setState(() => _isBuyNowLoading = false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pulsing dot used next to the "Only X left!" urgency text.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
      child: Container(
        height: 8,
        width: 8,
        decoration: const BoxDecoration(
          color: ColorConstant.orangeColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Holds the reviewer name/comment/rating shown under a review image
/// in the full-screen viewer.
class _ReviewOverlayInfo {
  final String name;
  final String? comment;
  final int rating;

  const _ReviewOverlayInfo({
    required this.name,
    this.comment,
    required this.rating,
  });
}

/// ---------------- SHARED FULL-SCREEN ZOOMABLE IMAGE VIEWER ----------------
/// Used for both the product gallery and review photos.
/// - Pinch/double-tap to zoom (InteractiveViewer)
/// - Swipe left/right to move between all images from the API
/// - If [reviewInfo] is provided, shows customer name + comment + stars
///   below the image (Flipkart-style review photo viewer)
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final List<_ReviewOverlayInfo>? reviewInfo;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
    this.reviewInfo,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info =
        (widget.reviewInfo != null && widget.reviewInfo!.length > _currentIndex)
        ? widget.reviewInfo![_currentIndex]
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ---- Zoomable, swipeable images ----
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Hero(
                      tag: 'product_image_$index',
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ---- Close button ----
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),

            // ---- Page counter (e.g. "2 / 5") ----
            if (widget.images.length > 1)
              Positioned(
                top: 14,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${widget.images.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),

            // ---- Customer name + comment overlay (review images only) ----
            if (info != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            info.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: i < info.rating
                                    ? ColorConstant.ratingStarColor
                                    : Colors.white30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (info.comment != null &&
                          info.comment!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          info.comment!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontFamily: "Poppins",
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // ---- Dot indicator (only when no review overlay, to avoid clutter) ----
            if (widget.images.length > 1 && info == null)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (index) {
                    final bool active = index == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: active ? 16 : 6,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
