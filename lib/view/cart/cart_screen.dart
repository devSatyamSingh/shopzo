import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../model/cart_model.dart';
import '../../viewmodel/cart_viewmodel.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart right after first frame (context not ready inside initState body)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().fetchCart(showLoader: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<CartViewModel>();

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, size, vm),
            Expanded(child: _buildBody(context, size, vm)),
            if (vm.hasLoadedOnce && !vm.isEmpty) _buildCheckoutBar(context, size, vm),
          ],
        ),
      ),
    );
  }

  /// ---------------- BODY SWITCH: loading / error / empty / content ----------------
  Widget _buildBody(BuildContext context, Size size, CartViewModel vm) {
    // First load, nothing on screen yet
    if (vm.isLoading && !vm.hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor));
    }

    // Load failed and we have nothing to show
    if (vm.isError && !vm.hasLoadedOnce) {
      return _buildErrorState(size, vm);
    }

    // Loaded successfully but cart has no items
    if (vm.isEmpty) {
      return _buildEmptyState(size);
    }

    // Happy path — real cart content, pull-to-refresh enabled
    return RefreshIndicator(
      color: ColorConstant.primaryColor,
      onRefresh: () => vm.fetchCart(showLoader: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: size.height * 0.018,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAddressStrip(size),
            SizedBox(height: size.height * 0.02),
            for (final item in vm.cart.items) ...[
              _buildCartItemCard(context, size, vm, item),
              if (item.isLowStock && !item.isUnavailable)
                _buildLowStockBanner(size, "Only ${item.availableStock} left in stock — order soon"),
              if (!item.inStockEnough && !item.isUnavailable)
                _buildLowStockBanner(size, "Only ${item.availableStock} available. Reduce quantity to continue."),
              SizedBox(height: size.height * 0.018),
            ],
            SizedBox(height: size.height * 0.006),
            _buildBillDetailsCard(size, vm),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, Size size, CartViewModel vm) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.03,
        size.height * 0.012,
        size.width * 0.045,
        size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.scaffoldBgColor,
        border: const Border(
          bottom: BorderSide(color: ColorConstant.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextContext(
                  text: "My Cart",
                  fontSize: 19,
                  color: ColorConstant.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 2),
                TextContext(
                  text: vm.hasLoadedOnce
                      ? "${vm.cart.totalLines} item${vm.cart.totalLines == 1 ? '' : 's'}"
                      : " ",
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ],
            ),
          ),
          if (vm.hasLoadedOnce && !vm.isEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _confirmClearCart(context, vm),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.delete_outline_rounded,
                    color: ColorConstant.errorColor, size: 22),
              ),
            ),
        ],
      ),
    );
  }

  /// ---------------- EMPTY STATE ----------------
  Widget _buildEmptyState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: ColorConstant.primaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.shopping_cart_outlined,
                  color: ColorConstant.primaryColor, size: 46),
            ),
            SizedBox(height: size.height * 0.024),
            const TextContext(
              text: "Your cart is empty",
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),
            SizedBox(height: size.height * 0.008),
            const TextContext(
              text: "Looks like you haven't added anything yet",
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ColorConstant.labelTextColor,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.028),
            CustomButton(
              text: "Start Shopping",
              height: 46,
              fontSize: 14,
              onTap: () {
                // TODO: confirm this is your actual bottom-nav / home route name
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteName.home,
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- ERROR STATE ----------------
  Widget _buildErrorState(Size size, CartViewModel vm) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: ColorConstant.placeholderColor, size: 46),
            SizedBox(height: size.height * 0.02),
            const TextContext(
              text: "Couldn't load your cart",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: size.height * 0.008),
            TextContext(
              text: vm.errorMessage ?? "Something went wrong. Please try again.",
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ColorConstant.labelTextColor,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.024),
            CustomButton(
              text: "Retry",
              height: 44,
              fontSize: 14,
              onTap: () => vm.fetchCart(),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- DELIVERY ADDRESS STRIP ----------------
  Widget _buildAddressStrip(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstant.borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: ColorConstant.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.location_on_rounded,
                color: ColorConstant.primaryColor, size: 18),
          ),
          SizedBox(width: size.width * 0.03),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: "DELIVER TO",
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: ColorConstant.placeholderColor,
                ),
                SizedBox(height: 2),
                TextContext(
                  // TODO: wire to real selected-address once Address module is connected
                  text: "Select delivery address",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // TODO: open address list / picker (RouteName.addressList)
            },
            child: const TextContext(
              text: "Change",
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: ColorConstant.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- CART ITEM CARD ----------------
  Widget _buildCartItemCard(
      BuildContext context, Size size, CartViewModel vm, CartItemModel item) {
    final bool isUnavailable = item.isUnavailable;
    final bool isUpdating = vm.isItemUpdating(item.id);
    final double thumbSize = (size.width * 0.2).clamp(64.0, 90.0);

    return Opacity(
      opacity: isUnavailable ? 0.6 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // TODO: ProductDetailScreen currently takes no constructor params
          // (see audit) — update its route/constructor to accept productId
          // before this navigation will show the correct product.
          Navigator.pushNamed(
            context,
            RouteName.productDetail,
            arguments: {'productId': item.productId},
          );
        },
        child: Container(
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blackColor.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Thumbnail ----
                  Container(
                    height: thumbSize,
                    width: thumbSize,
                    decoration: BoxDecoration(
                      color: ColorConstant.fieldFillColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (item.image != null && item.image!.trim().isNotEmpty)
                          ? Image.network(
                        item.image!,
                        fit: BoxFit.cover,
                        height: thumbSize,
                        width: thumbSize,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorConstant.primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: ColorConstant.placeholderColor,
                          size: 26,
                        ),
                      )
                          : const Icon(
                        Icons.image_not_supported_outlined,
                        color: ColorConstant.placeholderColor,
                        size: 26,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.035),

                  // ---- Name / variant / price ----
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextContext(
                          text: item.productName,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          color: isUnavailable
                              ? ColorConstant.placeholderColor
                              : ColorConstant.headlineTextColor,
                        ),
                        if (item.variantSku != null && item.variantSku!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          TextContext(
                            text: item.variantSku!,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorConstant.labelTextColor,
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (isUnavailable)
                          const TextContext(
                            text: "Currently unavailable",
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.errorColor,
                          )
                        else
                          Row(
                            children: [
                              TextContext(
                                text: AppUtils.formatCurrency(item.unitPrice),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              TextContext(
                                text: "Total: ${AppUtils.formatCurrency(item.lineTotal)}",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: ColorConstant.labelTextColor,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.014),
              const Divider(height: 1, color: ColorConstant.dividerColor),
              SizedBox(height: size.height * 0.012),

              // ---- Remove + Quantity stepper ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: isUpdating ? null : () => _confirmRemoveItem(context, vm, item),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.delete_outline_rounded,
                            size: 17, color: ColorConstant.errorColor),
                        SizedBox(width: 4),
                        TextContext(
                          text: "Remove",
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.errorColor,
                        ),
                      ],
                    ),
                  ),
                  if (!isUnavailable)
                    isUpdating
                        ? const SizedBox(
                      height: 26,
                      width: 70,
                      child: Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorConstant.primaryColor,
                          ),
                        ),
                      ),
                    )
                        : _QuantityStepper(
                      quantity: item.quantity,
                      onIncrement: item.quantity < item.availableStock
                          ? () => vm.incrementQuantity(item, context: context)
                          : () => AppUtils.warning(
                        context,
                        "Only ${item.availableStock} in stock",
                      ),
                      onDecrement: () => vm.decrementQuantity(item, context: context),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- LOW STOCK / STOCK WARNING BANNER ----------------
  Widget _buildLowStockBanner(Size size, String message) {
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.008),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.034,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.orangeLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: ColorConstant.orangeColor, size: 18),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: TextContext(
              text: message,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ColorConstant.orangeDark,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- BILL DETAILS CARD ----------------
  Widget _buildBillDetailsCard(Size size, CartViewModel vm) {
    final double itemTotal = vm.subtotal;
    // TODO: wire real delivery fee / platform fee once /checkout/summary is integrated
    const double deliveryFee = 0;
    const double platformFee = 0;
    final double totalPayable = itemTotal + deliveryFee + platformFee;

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextContext(
            text: "Bill Details",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: size.height * 0.016),
          _billRow("Item Total", AppUtils.formatCurrency(itemTotal)),
          SizedBox(height: size.height * 0.012),
          _billRow(
            "Delivery Fee",
            deliveryFee == 0 ? "FREE" : AppUtils.formatCurrency(deliveryFee),
            valueColor: deliveryFee == 0 ? ColorConstant.successColor : null,
          ),
          SizedBox(height: size.height * 0.012),
          _billRow(
            "Platform Fee",
            platformFee == 0 ? "FREE" : AppUtils.formatCurrency(platformFee),
          ),
          SizedBox(height: size.height * 0.016),
          const Divider(height: 1, color: ColorConstant.dividerColor),
          SizedBox(height: size.height * 0.016),
          _billRow(
            "To Pay",
            AppUtils.formatCurrency(totalPayable),
            bold: true,
            valueColor: ColorConstant.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextContext(
          text: label,
          fontSize: bold ? 15.5 : 13.5,
          fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
          color: bold ? ColorConstant.headlineTextColor : ColorConstant.labelTextColor,
        ),
        TextContext(
          text: value,
          fontSize: bold ? 17 : 13.5,
          fontWeight: bold ? FontWeight.w500 : FontWeight.w600,
          color: valueColor ?? ColorConstant.headlineTextColor,
        ),
      ],
    );
  }

  /// ---------------- STICKY BOTTOM CHECKOUT BAR ----------------
  Widget _buildCheckoutBar(BuildContext context, Size size, CartViewModel vm) {
    final bool hasBlockingIssue =
    vm.cart.items.any((i) => i.isUnavailable || !i.inStockEnough);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: size.height * 0.016,
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
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextContext(
                    text: AppUtils.formatCurrency(vm.subtotal),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  TextContext(
                    text: "${vm.itemCount} item${vm.itemCount == 1 ? '' : 's'}",
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              flex: 6,
              child: CustomButton(
                text: hasBlockingIssue ? "Review Cart" : "Proceed to Checkout",
                height: 49,
                fontSize: 14,
                icon: Icons.arrow_forward_rounded,
                iconSize: 18,
                onTap: hasBlockingIssue
                    ? () => AppUtils.warning(
                  context,
                  "Please remove unavailable / out-of-stock items to continue",
                )
                    : () => Navigator.pushNamed(context, RouteName.checkoutAddress),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- CONFIRM DIALOGS ----------------
  Future<void> _confirmRemoveItem(
      BuildContext context, CartViewModel vm, CartItemModel item) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: "Remove item?",
      message: "Remove \"${item.productName}\" from your cart?",
      confirmText: "Remove",
      isDestructive: true,
    );
    if (confirmed) {
      // ignore: use_build_context_synchronously
      vm.removeItem(itemId: item.id, context: context);
    }
  }

  Future<void> _confirmClearCart(BuildContext context, CartViewModel vm) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: "Clear cart?",
      message: "This will remove all items from your cart.",
      confirmText: "Clear",
      isDestructive: true,
    );
    if (confirmed) {
      // ignore: use_build_context_synchronously
      vm.clearCart(context: context);
    }
  }
}

/// ---------------- Quantity Stepper (- 1 +) ----------------
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstant.primaryLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(Icons.remove_rounded, onDecrement),
          SizedBox(
            width: 26,
            child: Text(
              "$quantity",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: "Poppins",
                color: ColorConstant.headlineTextColor,
              ),
            ),
          ),
          _stepButton(Icons.add_rounded, onIncrement),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 26,
        width: 26,
        alignment: Alignment.center,
        child: Icon(icon, size: 15, color: ColorConstant.primaryColor),
      ),
    );
  }
}