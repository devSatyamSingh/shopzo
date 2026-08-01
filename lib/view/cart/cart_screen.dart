import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../model/cart_model.dart';
import '../../viewmodel/cart_viewmodel.dart';
import '../../viewmodel/coupon_viewmodel.dart';
import '../../viewmodel/order_checkout_viewmodel.dart';
import '../account/coupons_screen.dart'; // CouponsScreen + CouponApplyResult

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ---- Item selection state (which lines proceed to checkout) ----
  final Set<String> _selectedItemIds = {};
  Set<String> _knownItemIds = {};

  final TextEditingController _couponController = TextEditingController();

  // Prevents scheduling multiple coupon-invalidation callbacks for the
  // same drift event (build() can run several times before the first
  // post-frame callback fires).
  bool _invalidationScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().fetchCart(showLoader: false);
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  /// Keeps _selectedItemIds in sync with the live cart:
  ///  - newly-seen items (first load, or items just added) get
  ///    auto-selected by default
  ///  - items removed from the cart get dropped from the selection
  void _syncSelection(CartViewModel vm) {
    final currentIds = vm.cart.items
        .where((i) => !i.isUnavailable)
        .map((e) => e.id)
        .toSet();

    _selectedItemIds.removeWhere((id) => !currentIds.contains(id));

    final allCurrentIds = vm.cart.items.map((e) => e.id).toSet();
    for (final id in allCurrentIds) {
      if (!_knownItemIds.contains(id) && currentIds.contains(id)) {
        _selectedItemIds.add(id);
      }
    }
    _knownItemIds = allCurrentIds;
  }

  List<CartItemModel> _selectedItems(CartViewModel vm) =>
      vm.cart.items.where((i) => _selectedItemIds.contains(i.id)).toList();

  double _selectedSubtotal(CartViewModel vm) =>
      _selectedItems(vm).fold(0.0, (sum, item) => sum + item.lineTotal);

  /// The discount that is SAFE to show right now. Even if the coupon
  /// object hasn't been cleared from CouponViewModel yet (invalidation
  /// runs one frame later via addPostFrameCallback), this guarantees the
  /// UI never displays a discount that doesn't match the current
  /// selection — no negative totals, no stale numbers, ever.
  double _effectiveDiscount(CartViewModel vm, CouponViewModel couponVm) {
    if (!couponVm.hasCouponApplied) return 0;
    final currentSubtotal = _selectedSubtotal(vm);
    if (currentSubtotal <= 0.009) return 0;
    if (couponVm.appliedSubtotal != null &&
        (couponVm.appliedSubtotal! - currentSubtotal).abs() > 0.009) {
      return 0; // stale — will be auto-removed by the guard below
    }
    return couponVm.discount;
  }

  /// Runs once per drift event: if the coupon's applied-subtotal no
  /// longer matches the currently-selected subtotal (item removed,
  /// checkbox unselected, quantity changed, cart refreshed from server —
  /// any reason at all), the coupon is stale. Drop it and tell the user.
  void _guardCouponValidity(CartViewModel vm, CouponViewModel couponVm) {
    if (!couponVm.hasCouponApplied || couponVm.appliedSubtotal == null) return;
    final currentSubtotal = _selectedSubtotal(vm);
    final bool driftDetected =
        (couponVm.appliedSubtotal! - currentSubtotal).abs() > 0.009;

    if (driftDetected && !_invalidationScheduled) {
      _invalidationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _invalidationScheduled = false;
        if (!mounted) return;
        couponVm.removeCoupon();
        AppUtils.warning(context, "Coupon removed — your cart selection changed");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // CouponViewModel scoped to this screen only.
    return ChangeNotifierProvider<CouponViewModel>(
      create: (_) => CouponViewModel(),
      child: Builder(
        builder: (context) => _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<CartViewModel>();
    final couponVm = context.watch<CouponViewModel>();

    if (vm.hasLoadedOnce) {
      _syncSelection(vm);
      _guardCouponValidity(vm, couponVm);
    }

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, size, vm),
            Expanded(child: _buildBody(context, size, vm, couponVm)),
            if (vm.hasLoadedOnce && !vm.isEmpty)
              _buildCheckoutBar(context, size, vm, couponVm),
          ],
        ),
      ),
    );
  }

  /// ---------------- BODY SWITCH: loading / error / empty / content ----------------
  Widget _buildBody(
      BuildContext context, Size size, CartViewModel vm, CouponViewModel couponVm) {
    if (vm.isLoading && !vm.hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor));
    }

    if (vm.isError && !vm.hasLoadedOnce) {
      return _buildErrorState(size, vm);
    }

    if (vm.isEmpty) {
      return _buildEmptyState(size);
    }

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
            _buildSelectAllRow(size, vm, couponVm),
            SizedBox(height: size.height * 0.01),
            for (final item in vm.cart.items) ...[
              _buildCartItemCard(context, size, vm, couponVm, item),
              if (item.isLowStock && !item.isUnavailable)
                _buildLowStockBanner(size, "Only ${item.availableStock} left in stock — order soon"),
              if (!item.inStockEnough && !item.isUnavailable)
                _buildLowStockBanner(size, "Only ${item.availableStock} available. Reduce quantity to continue."),
              SizedBox(height: size.height * 0.018),
            ],
            SizedBox(height: size.height * 0.006),
            _buildBillDetailsCard(context, size, vm, couponVm),
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

  /// ---------------- SELECT ALL ROW ----------------
  Widget _buildSelectAllRow(Size size, CartViewModel vm, CouponViewModel couponVm) {
    final selectableItems = vm.cart.items.where((i) => !i.isUnavailable).toList();
    final bool allSelected =
        selectableItems.isNotEmpty && selectableItems.every((i) => _selectedItemIds.contains(i.id));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.006),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            activeColor: ColorConstant.primaryColor,
            onChanged: selectableItems.isEmpty
                ? null
                : (checked) {
              setState(() {
                if (checked == true) {
                  _selectedItemIds.addAll(selectableItems.map((e) => e.id));
                } else {
                  _selectedItemIds.clear();
                }
              });
              // Selection just changed the total — the coupon guard in
              // build() will pick this up on the next frame and drop
              // the coupon automatically if it no longer matches.
            },
          ),
          TextContext(
            text: "Select All (${_selectedItemIds.length}/${selectableItems.length})",
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ColorConstant.headlineTextColor,
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
  Widget _buildCartItemCard(BuildContext context, Size size, CartViewModel vm,
      CouponViewModel couponVm, CartItemModel item) {
    final bool isUnavailable = item.isUnavailable;
    final bool isUpdating = vm.isItemUpdating(item.id);
    final bool isSelected = _selectedItemIds.contains(item.id);
    final double thumbSize = (size.width * 0.2).clamp(64.0, 90.0);

    return Opacity(
      opacity: isUnavailable ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(18),
          border: isSelected && !isUnavailable
              ? Border.all(color: ColorConstant.primaryColor.withOpacity(0.4), width: 1.2)
              : null,
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
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteName.productDetail,
                  arguments: item.productId,
                );
              },
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- Selection checkbox ----
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Checkbox(
                            value: isSelected,
                            activeColor: ColorConstant.primaryColor,
                            onChanged: isUnavailable
                                ? null
                                : (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedItemIds.add(item.id);
                                } else {
                                  _selectedItemIds.remove(item.id);
                                }
                              });
                              // Coupon guard in build() re-checks the
                              // new subtotal on the next frame.
                            },
                          ),
                        ),

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
                                ? () async {
                              await vm.incrementQuantity(item, context: context);
                              // Quantity change moves the subtotal — the
                              // coupon guard in build() re-checks on the
                              // next frame and clears a now-stale coupon.
                            }
                                : () => AppUtils.warning(
                              context,
                              "Only ${item.availableStock} in stock",
                            ),
                            onDecrement: () async {
                              await vm.decrementQuantity(item, context: context);
                            },
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

  /// ---------------- COUPON APPLY (manual field, above bill) ----------------
  Widget _buildCouponSection(BuildContext context, Size size, CartViewModel vm, CouponViewModel couponVm) {
    final double selectedSubtotal = _selectedSubtotal(vm);
    final double effectiveDiscount = _effectiveDiscount(vm, couponVm);
    final bool showAppliedBanner = couponVm.hasCouponApplied && effectiveDiscount > 0;
    final bool isTypedCodeValidating = couponVm.isValidating &&
        couponVm.validatingCode == _couponController.text.trim().toUpperCase();

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAppliedBanner) ...[
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(color: ColorConstant.successColor, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextContext(
                        text: "${couponVm.appliedCoupon!.code} Applied",
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.successColor,
                      ),
                      TextContext(
                        text: "You saved ${AppUtils.formatCurrency(effectiveDiscount)}",
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.successColor,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: couponVm.removeCoupon,
                  child: const TextContext(
                    text: "Remove",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.errorColor,
                  ),
                ),
              ],
            ),
          ] else ...[
            const TextContext(
              text: "Have a coupon code?",
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: ColorConstant.fieldFillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      enabled: !couponVm.isValidating && _selectedItemIds.isNotEmpty,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, fontFamily: "Poppins"),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "ENTER CODE",
                        hintStyle: TextStyle(fontSize: 12.5, color: ColorConstant.placeholderColor, fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 42,
                  width: 84,
                  child: CustomButton(
                    text: isTypedCodeValidating ? "" : "Apply",
                    height: 42,
                    fontSize: 13,
                    borderRadius: BorderRadius.circular(10),
                    onTap: (couponVm.isValidating || _selectedItemIds.isEmpty)
                        ? null
                        : () async {
                      final code = _couponController.text.trim();
                      if (code.isEmpty) {
                        AppUtils.warning(context, "Please enter a coupon code");
                        return;
                      }
                      final currentSubtotal = _selectedSubtotal(vm);
                      final ok = await couponVm.applyCoupon(code: code, subtotal: currentSubtotal);
                      if (!mounted) return;
                      if (ok) {
                        AppUtils.success(context, couponVm.validationMessage ?? "Coupon applied");
                        _couponController.clear();
                        AppUtils.hideKeyboard(context);
                      } else {
                        AppUtils.error(context, couponVm.validationMessage ?? "Invalid coupon");
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_selectedItemIds.isEmpty) ...[
              const SizedBox(height: 6),
              const TextContext(
                text: "Select at least one item to apply a coupon",
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: ColorConstant.placeholderColor,
              ),
            ],
            SizedBox(height: size.height * 0.01),
            InkWell(
              onTap: _selectedItemIds.isEmpty
                  ? null
                  : () async {
                final currentSubtotal = _selectedSubtotal(vm);
                final result = await Navigator.push<CouponApplyResult>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CouponsScreen(subtotal: currentSubtotal),
                  ),
                );
                if (result != null && mounted) {
                  // Re-validate against the *current* selected subtotal
                  // (not the one captured before navigating), in case
                  // anything changed while the coupon screen was open.
                  final refreshedSubtotal = _selectedSubtotal(vm);
                  await couponVm.applyCoupon(code: result.code, subtotal: refreshedSubtotal);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.local_offer_outlined, size: 15, color: ColorConstant.primaryColor),
                  SizedBox(width: 6),
                  TextContext(
                    text: "View all coupons",
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ---------------- BILL DETAILS CARD ----------------
  Widget _buildBillDetailsCard(
      BuildContext context, Size size, CartViewModel vm, CouponViewModel couponVm) {
    final double itemTotal = _selectedSubtotal(vm);
    final double discount = _effectiveDiscount(vm, couponVm);
    const double deliveryFee = 0;
    const double platformFee = 0;
    final double totalPayable = (itemTotal - discount + deliveryFee + platformFee)
        .clamp(0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCouponSection(context, size, vm, couponVm),
        SizedBox(height: size.height * 0.018),
        Container(
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
              _billRow("Item Total (${_selectedItemIds.length} item${_selectedItemIds.length == 1 ? '' : 's'})",
                  AppUtils.formatCurrency(itemTotal)),
              if (discount > 0) ...[
                SizedBox(height: size.height * 0.012),
                _billRow(
                  "Coupon Discount",
                  "-${AppUtils.formatCurrency(discount)}",
                  valueColor: ColorConstant.successColor,
                ),
              ],
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
        ),
      ],
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
  Widget _buildCheckoutBar(
      BuildContext context, Size size, CartViewModel vm, CouponViewModel couponVm) {
    final selectedItems = _selectedItems(vm);
    final bool hasBlockingIssue =
    selectedItems.any((i) => i.isUnavailable || !i.inStockEnough);
    final double itemTotal = _selectedSubtotal(vm);
    final double discount = _effectiveDiscount(vm, couponVm);
    final double payable = (itemTotal - discount).clamp(0, double.infinity);

    final bool canProceed = selectedItems.isNotEmpty && !hasBlockingIssue;

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
                    text: AppUtils.formatCurrency(payable),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  TextContext(
                    text: "${selectedItems.length} item${selectedItems.length == 1 ? '' : 's'} selected",
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
                text: selectedItems.isEmpty
                    ? "Select Items"
                    : hasBlockingIssue
                    ? "Review Cart"
                    : "Proceed to Checkout",
                height: 49,
                fontSize: 14,
                icon: Icons.arrow_forward_rounded,
                iconSize: 18,
                onTap: !canProceed
                    ? () {
                  AppUtils.warning(
                    context,
                    selectedItems.isEmpty
                        ? "Select at least one item to continue"
                        : "Please remove unavailable / out-of-stock items to continue",
                  );
                }
                    : () {
                  // Selected cart items (1, kai, ya sab) ko checkout line items
                  // me convert karke CheckoutViewModel me daal do
                  final checkoutItems = selectedItems
                      .map((item) => CheckoutLineItem.fromCartItem(item))
                      .toList();

                  final checkoutVm = context.read<CheckoutViewModel>();
                  checkoutVm.startCheckout(checkoutItems);

                  // agar cart me coupon apply tha to wahi code checkout me carry karo —
                  // applyCoupon khud preview API se re-validate kar lega (naye items
                  // ke against), koi discount value manually pass karne ki zaroorat nahi
                  if (couponVm.hasCouponApplied && couponVm.appliedCoupon != null) {
                    checkoutVm.applyCoupon(couponVm.appliedCoupon!.code);
                  }

                  Navigator.pushNamed(context, RouteName.checkoutAddress);
                },
              ),
            ),          ],
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
      await vm.removeItem(itemId: item.id, context: context);
      // Removal changes the subtotal — coupon guard in build() picks
      // this up automatically and clears a now-stale coupon.
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
      await vm.clearCart(context: context);
      setState(() => _selectedItemIds.clear());
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