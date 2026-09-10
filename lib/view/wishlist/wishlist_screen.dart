import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/wishlist_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/wishlist_viewmodel.dart';
import '../product_details/product_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistViewModel>().fetchWishlist();
    });
  }

  Future<void> _removeItem(WishlistItemModel item) async {
    final vm = context.read<WishlistViewModel>();
    final ok = await vm.removeItem(item);
    if (!mounted) return;
    if (ok) {
      AppUtils.success(
        null,
        'wishlist.removed_success'.tr(),
      );
    } else {
      AppUtils.error(
        null,
        'wishlist.remove_failed'.tr(),
      );
    }
  }

  Future<void> _moveToCart(WishlistItemModel item) async {
    final vm = context.read<WishlistViewModel>();
    final ok = await vm.moveToCart(item);
    if (!mounted) return;
    if (ok) {
      AppUtils.success(
        null,
        'wishlist.moved_to_cart'.tr(
          args: [item.displayName],
        ),
      );
    } else {
      AppUtils.error(
        null,
        'wishlist.move_to_cart_failed'.tr(),
      );
    }
  }

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
              child: Consumer<WishlistViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading && vm.items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: ColorConstant.primaryColor, strokeWidth: 2.6),
                    );
                  }

                  if (vm.hasError && vm.items.isEmpty) {
                    return _buildErrorState(size, vm);
                  }

                  if (vm.isEmpty) {
                    return _buildEmptyState(context, size);
                  }

                  return RefreshIndicator(
                    color: ColorConstant.primaryColor,
                    onRefresh: () => vm.fetchWishlist(showLoader: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStaggeredGrid(context, size, vm),
                          SizedBox(height: size.height * 0.022),
                          _buildBrowseMoreFooter(context, size),
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  );
                },
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
      padding: EdgeInsets.fromLTRB(size.width * 0.03, size.height * 0.014, size.width * 0.045, size.height * 0.018),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(0.045), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_rounded, color: ColorConstant.headlineTextColor, size: 20),
            ),
          ),
          Expanded(
            child: Consumer<WishlistViewModel>(
              builder: (context, vm, _) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_rounded, color: ColorConstant.wishlistColor, size: 15),
                        const SizedBox(width: 6),
                        TextContext(
                          text: 'wishlist.my_wishlist'.tr(),
                          fontSize: 17,
                          color: ColorConstant.headlineTextColor,
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorConstant.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextContext(
                        text: vm.items.length == 1
                            ? 'wishlist.item'.tr(args: [vm.items.length.toString()])
                            : 'wishlist.items'.tr(args: [vm.items.length.toString()]),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.primaryColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 38), // symmetry
        ],
      ),
    );
  }

  /// ---------------- 2-COLUMN STAGGERED GRID ----------------
  Widget _buildStaggeredGrid(BuildContext context, Size size, WishlistViewModel vm) {
    final left = <WishlistItemModel>[];
    final right = <WishlistItemModel>[];
    for (int i = 0; i < vm.items.length; i++) {
      (i.isEven ? left : right).add(vm.items[i]);
    }

    final double spacing = size.width * 0.03;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumn(context, size, left, spacing, vm)),
        SizedBox(width: spacing),
        Expanded(child: _buildColumn(context, size, right, spacing, vm)),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, Size size, List<WishlistItemModel> items, double spacing, WishlistViewModel vm) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          buildProductCard(context, size, items[i], vm),
          if (i != items.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }

  /// ---------------- PRODUCT CARD ----------------
  Widget buildProductCard(BuildContext context, Size size, WishlistItemModel item, WishlistViewModel vm) {
    final double cardImageHeight = (size.width * 0.34).clamp(110.0, 170.0);
    final bool isOutOfStock = !item.isAvailable || item.stock <= 0;
    final bool isRemoving = vm.isRemoving(item.id);
    final bool isMoving = vm.isMoving(item.id);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isRemoving ? 0.5 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorConstant.borderColor.withOpacity(0.4), width: 1),
          boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: item.productId))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: cardImageHeight,
                    width: double.infinity,
                    color: ColorConstant.fieldFillColor,
                    alignment: Alignment.center,
                    child: Builder(
                      builder: (_) {
                        final imageUrl = vm.imageFor(item.productId, variantId: item.variantId);
                        final isLoadingImage = vm.isImageLoading(item.productId, variantId: item.variantId);

                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          return Image.network(
                            imageUrl,
                            height: cardImageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_outlined, size: 34, color: ColorConstant.placeholderColor),
                          );
                        }

                        if (isLoadingImage) {
                          return const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor),
                          );
                        }

                        return const Icon(Icons.image_outlined, size: 34, color: ColorConstant.placeholderColor);
                      },
                    ),
                  ),
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            'wishlist.out_of_stock'.tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600, fontFamily: "Poppins"),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: isRemoving ? null : () => _removeItem(item),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: ColorConstant.whiteColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        alignment: Alignment.center,
                        child: isRemoving
                            ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor))
                            : const Icon(Icons.favorite_rounded, color: ColorConstant.wishlistColor, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(
                      text: item.displayName,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    TextContext(
                      text: "₹${item.displayPrice.toStringAsFixed(0)}",
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    isOutOfStock
                        ? CustomButton(
                      text: 'wishlist.notify_me'.tr(),
                      height: 40,
                      fontSize: 13,
                      outlined: true,
                      borderColor: ColorConstant.borderColor,
                      textColor: ColorConstant.placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // TODO: subscribe to back-in-stock notification (no API given yet)
                      },
                    )
                        : CustomButton(
                      text: isMoving ? 'wishlist.adding'.tr() : 'wishlist.add_to_cart'.tr(),
                      height: 40,
                      fontSize: 13,
                      outlined: true,
                      borderColor: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      onTap: isMoving ? null : () => _moveToCart(item),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Size size, WishlistViewModel vm) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(color: ColorConstant.errorColor.withOpacity(0.1), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.wifi_off_rounded, size: 30, color: ColorConstant.errorColor),
            ),
            SizedBox(height: size.height * 0.018),
            TextContext(
              text: vm.errorMessage ?? 'wishlist.load_failed'.tr(),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ColorConstant.labelTextColor,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.02),
            CustomButton(
              text: 'wishlist.retry'.tr(),
              width: 140,
              height: 44,
              borderRadius: BorderRadius.circular(30),
              onTap: () => vm.fetchWishlist(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ColorConstant.wishlistColor.withOpacity(0.15), ColorConstant.wishlistColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.favorite_border_rounded, color: ColorConstant.wishlistColor, size: 34),
            ),
            SizedBox(height: size.height * 0.022),
            TextContext(
              text: 'wishlist.empty_title'.tr(),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorConstant.headlineTextColor,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            TextContext(
              text: 'wishlist.empty_message'.tr(),
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: ColorConstant.labelTextColor,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.024),
            CustomButton(
              text: 'wishlist.browse_products'.tr(),
              width: size.width * 0.55,
              height: 48,
              icon: Icons.arrow_forward_rounded,
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseMoreFooter(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.032),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorConstant.primaryColor.withOpacity(0.08), ColorConstant.primaryColor.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorConstant.primaryColor.withOpacity(0.12), width: 1),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: ColorConstant.whiteColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.favorite_border_rounded, color: ColorConstant.primaryColor, size: 24),
          ),
          SizedBox(height: size.height * 0.016),
          TextContext(
            text: 'wishlist.looking_for_more'.tr(),
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: ColorConstant.headlineTextColor,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          TextContext(
            text: 'wishlist.explore_trending'.tr(),
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: ColorConstant.labelTextColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),
          CustomButton(
            text: 'wishlist.browse_products'.tr(),
            width: size.width * 0.55,
            height: 46,
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}