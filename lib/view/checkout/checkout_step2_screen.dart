import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/order_summary/order_preview_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../viewmodel/order_checkout/order_checkout_viewmodel.dart';
import 'checkout_stepper.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  const CheckoutSummaryScreen({super.key});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  final TextEditingController _couponController = TextEditingController();
  static const double _platformFee = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CheckoutViewModel>();
      // agar address select hote hi preview trigger nahi hua (edge case —
      // e.g. hot reload / direct navigation), yaha se ensure kar do
      if (vm.items.isNotEmpty && vm.preview == null && !vm.isPreviewLoading) {
        vm.fetchPreview();
      }
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _onChangeAddress() => Navigator.pop(context);

  void _onContinue(CheckoutViewModel vm) {
    if (vm.items.isEmpty || vm.hasStockIssue) return;
    Navigator.pushNamed(context, RouteName.checkoutPayment);
  }

  Future<void> _applyCoupon(CheckoutViewModel vm) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      AppUtils.warning(context, "Please enter a coupon code");
      return;
    }
    await vm.applyCoupon(code);
    if (!mounted) return;

    if (vm.hasCouponApplied) {
      AppUtils.success(context, "Coupon applied");
      _couponController.clear();
      AppUtils.hideKeyboard(context);
    } else {
      AppUtils.error(context, vm.couponError ?? "Invalid coupon");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<CheckoutViewModel>();

    if (vm.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 46, color: ColorConstant.placeholderColor),
                const SizedBox(height: 14),
                const TextContext(text: "No items to checkout", fontSize: 15, fontWeight: FontWeight.w600),
                const SizedBox(height: 18),
                CustomButton(
                  text: "Go to Cart",
                  height: 46,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, RouteName.cart, (r) => false),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final address = vm.selectedAddress;
    final preview = vm.preview;
    final bool showSkeleton = vm.isPreviewLoading && preview == null;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const CheckoutStepper(currentStep: 2),
            Expanded(
              child: RefreshIndicator(
                color: ColorConstant.primaryColor,
                onRefresh: () => vm.fetchPreview(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),

                      // ---------------- DELIVER TO ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: ColorConstant.whiteColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: ColorConstant.blackColor.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(color: ColorConstant.primaryLight, borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              child: Icon(Icons.location_on_rounded, size: 18, color: ColorConstant.primaryColor),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextContext(
                                    text: 'DELIVER TO:',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstant.placeholderColor,
                                    letterSpacing: 0.5,
                                  ),
                                  TextContext(
                                    text: address?.type == 'BILLING' ? 'Billing Address' : 'Shipping Address',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstant.headlineTextColor,
                                  ),
                                  TextContext(
                                    text: address?.fullAddress ?? '',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorConstant.labelTextColor,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _onChangeAddress,
                              child: const TextContext(text: 'Change', fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.025),

                      TextContext(
                        text: 'Order Items (${vm.itemCount})',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.headlineTextColor,
                      ),
                      SizedBox(height: size.height * 0.014),

                      // ---------------- ITEMS ----------------
                      if (showSkeleton)
                        _ItemsSkeleton(size: size)
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: ColorConstant.whiteColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: ColorConstant.blackColor.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Column(
                            children: List.generate(vm.items.length, (index) {
                              final localItem = vm.items[index];
                              OrderPreviewItem? previewItem;
                              if (preview != null) {
                                final matches = preview.items.where(
                                      (p) => p.productId == localItem.productId && p.variantId == localItem.variantId,
                                );
                                previewItem = matches.isNotEmpty ? matches.first : null;
                              }

                              final name = previewItem?.productName ?? localItem.productName;
                              final image = previewItem?.image ?? localItem.image;
                              final price = previewItem?.price ?? localItem.unitPrice;
                              final qty = previewItem?.quantity ?? localItem.quantity;
                              final outOfStock = previewItem != null && !previewItem.inStock;
                              final isLast = index == vm.items.length - 1;

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: (image != null && image.isNotEmpty)
                                              ? Image.network(
                                            image,
                                            height: 56,
                                            width: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _imgFallback(),
                                          )
                                              : _imgFallback(),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextContext(
                                                text: name,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                color: ColorConstant.headlineTextColor,
                                              ),
                                              if (outOfStock) ...[
                                                const SizedBox(height: 4),
                                                const TextContext(
                                                  text: "Out of stock",
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorConstant.errorColor,
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              TextContext(
                                                text: AppUtils.formatCurrency(price),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: ColorConstant.headlineTextColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(8)),
                                          child: Text(
                                            'Qty: $qty',
                                            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: ColorConstant.bodyTextColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast) Divider(color: ColorConstant.dividerColor, height: 1),
                                ],
                              );
                            }),
                          ),
                        ),

                      if (vm.hasStockIssue) ...[
                        SizedBox(height: size.height * 0.012),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: ColorConstant.orangeLight, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: [
                              Icon(Icons.error_rounded, color: ColorConstant.orangeColor, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: TextContext(
                                  text: "Some items are out of stock. Please go back and update your cart.",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.orangeDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: size.height * 0.02),

                      // ---------------- COUPON ----------------
                      _buildCouponSection(size, vm),

                      SizedBox(height: size.height * 0.02),

                      // ---------------- BILL DETAILS ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstant.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: ColorConstant.blackColor.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextContext(text: 'Bill Details', fontSize: 15, fontWeight: FontWeight.w600, color: ColorConstant.headlineTextColor),
                            SizedBox(height: size.height * 0.014),
                            if (showSkeleton)
                              _BillSkeleton()
                            else ...[
                              _BillRow(label: 'Item Total', value: AppUtils.formatCurrency(vm.subtotal)),
                              _BillRow(label: 'Tax', value: AppUtils.formatCurrency(vm.tax)),
                              _BillRow(label: 'Delivery Fee', value: 'FREE', valueColor: ColorConstant.successColor),
                              if (vm.discount > 0)
                                _BillRow(
                                  label: 'Coupon Discount',
                                  value: '-${AppUtils.formatCurrency(vm.discount)}',
                                  valueColor: ColorConstant.successColor,
                                ),
                              _BillRow(label: 'Platform Fee', value: AppUtils.formatCurrency(_platformFee)),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
                                child: Divider(color: ColorConstant.dividerColor, height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const TextContext(text: 'To Pay', fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstant.headlineTextColor),
                                  TextContext(text: AppUtils.formatCurrency(vm.total), fontSize: 15, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
            ),

            // ---------------- BOTTOM BAR ----------------
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.015),
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(.06), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextContext(text: AppUtils.formatCurrency(vm.total), fontSize: 16, fontWeight: FontWeight.w500, color: ColorConstant.primaryColor),
                      TextContext(text: '${vm.itemCount} item${vm.itemCount == 1 ? '' : 's'}', fontSize: 11, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor),
                    ],
                  ),
                  Expanded(
                    child: SizedBox(
                      width: size.width * 0.44,
                      child: CustomButton(
                        text: 'Continue To Payment',
                        onTap: (address == null || showSkeleton || vm.hasStockIssue) ? null : () => _onContinue(vm),
                        color: ColorConstant.primaryColor,
                        icon: Icons.arrow_forward,
                        iconColor: ColorConstant.whiteColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
    height: 56,
    width: 56,
    color: ColorConstant.fieldFillColor,
    alignment: Alignment.center,
    child: Icon(Icons.image_outlined, size: 20, color: ColorConstant.placeholderColor),
  );

  Widget _buildCouponSection(Size size, CheckoutViewModel vm) {
    if (vm.hasCouponApplied) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: ColorConstant.successColor.withOpacity(.1), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: const BoxDecoration(color: ColorConstant.successColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.sell_rounded, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(text: '${vm.preview!.couponApplied} Applied', fontSize: 13, fontWeight: FontWeight.w500, color: ColorConstant.successColor),
                  TextContext(text: 'You saved ${AppUtils.formatCurrency(vm.discount)}', fontSize: 11.5, fontWeight: FontWeight.w400, color: ColorConstant.successColor),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => vm.removeCoupon(),
              child: const TextContext(text: 'Remove', fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstant.errorColor),
            ),
          ],
        ),
      );
    }

    final bool isValidating = vm.isPreviewLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextContext(text: "Have a coupon code?", fontSize: 13.5, fontWeight: FontWeight.w600),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    enabled: !isValidating,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, fontFamily: "Poppins"),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "ENTER COUPON CODE",
                      hintStyle: TextStyle(fontSize: 12.5, color: ColorConstant.placeholderColor, fontFamily: "Poppins"),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                width: 84,
                child: CustomButton(
                  text: isValidating ? "" : "Apply",
                  height: 44,
                  fontSize: 13,
                  borderRadius: BorderRadius.circular(10),
                  onTap: isValidating ? null : () => _applyCoupon(vm),
                ),
              ),
            ],
          ),
          if (vm.couponError != null && vm.couponCode != null) ...[
            const SizedBox(height: 6),
            TextContext(text: vm.couponError!, fontSize: 11.5, fontWeight: FontWeight.w500, color: ColorConstant.errorColor),
          ],
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _BillRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextContext(text: label, fontSize: 13, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
          TextContext(text: value, fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? ColorConstant.headlineTextColor),
        ],
      ),
    );
  }
}

class _BillSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
            (i) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: SizedBox(height: 13),
        ),
      ),
    );
  }
}

class _ItemsSkeleton extends StatelessWidget {
  final Size size;
  const _ItemsSkeleton({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(color: ColorConstant.whiteColor, borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: ColorConstant.primaryColor, strokeWidth: 2),
    );
  }
}