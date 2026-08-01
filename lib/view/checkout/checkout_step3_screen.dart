import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../viewmodel/cart_viewmodel.dart';
import '../../viewmodel/order_checkout_viewmodel.dart';
import 'checkout_stepper.dart';

class PaymentOptionData {
  final IconData icon;
  final String title;
  final bool isLive; // COD abhi live hai, baaki "coming soon"

  const PaymentOptionData({required this.icon, required this.title, this.isLive = false});
}

class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  static const List<PaymentOptionData> _options = [
    PaymentOptionData(icon: Icons.payments_rounded, title: 'Cash on Delivery', isLive: true),
    PaymentOptionData(icon: Icons.account_balance_wallet_rounded, title: 'UPI'),
    PaymentOptionData(icon: Icons.credit_card_rounded, title: 'Credit / Debit Card'),
    PaymentOptionData(icon: Icons.account_balance_rounded, title: 'Net Banking'),
  ];

  int _selectedIndex = 0; // COD default selected

  Future<void> _onPayNow(CheckoutViewModel checkoutVm) async {
    final selected = _options[_selectedIndex];
    if (!selected.isLive) {
      AppUtils.warning(context, "${selected.title} coming soon — please use Cash on Delivery for now");
      return;
    }

    checkoutVm.setPaymentMethod('COD');
    final success = await checkoutVm.placeOrder();
    if (!mounted) return;

    if (success) {
      // Order request me hi cartItemIds bheja gaya tha — backend un lines
      // ko already clear kar chuka hai. Cart ko sirf resync karo, dobara
      // remove API call karne ki zaroorat nahi.
      await context.read<CartViewModel>().fetchCart(showLoader: false);
      if (!mounted) return;

      final orderNumber = checkoutVm.lastPlacedOrder?.orderNumber;
      checkoutVm.reset();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: ColorConstant.successColor, size: 26),
              const SizedBox(width: 10),
              const TextContext(text: 'Order Placed!', fontSize: 16, fontWeight: FontWeight.w600),
            ],
          ),
          content: TextContext(
            text: orderNumber != null
                ? 'Your order $orderNumber has been placed successfully.'
                : 'Your order has been placed successfully.',
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: ColorConstant.labelTextColor,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.pushNamedAndRemoveUntil(context, RouteName.mainWrapper, (r) => false);
              },
              child: const TextContext(text: 'Done', fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor),
            ),
          ],
        ),
      );
    } else {
      AppUtils.error(context, checkoutVm.placeOrderError ?? 'Failed to place order');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final checkoutVm = context.watch<CheckoutViewModel>();

    if (checkoutVm.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
        body: const Center(
          child: TextContext(text: "No items to checkout", fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );
    }

    final double amountToPay = checkoutVm.total;

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
            const CheckoutStepper(currentStep: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.02),

                    // ---------------- AMOUNT TO PAY BANNER ----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: ColorConstant.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: ColorConstant.primaryColor.withOpacity(.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AMOUNT TO PAY',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(.85),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppUtils.formatCurrency(amountToPay),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.028),

                    TextContext(
                      text: 'Payment Method',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: size.height * 0.012),

                    // ---------------- PAYMENT OPTIONS ----------------
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      final isSelected = index == _selectedIndex;
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.012),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: option.isLive ? () => setState(() => _selectedIndex = index) : null,
                          child: Opacity(
                            opacity: option.isLive ? 1 : 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorConstant.whiteColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                                  width: isSelected ? 1.6 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(option.icon, size: 19, color: ColorConstant.headlineTextColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextContext(
                                      text: option.title,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstant.headlineTextColor,
                                    ),
                                  ),
                                  if (!option.isLive)
                                    const TextContext(
                                      text: 'Coming soon',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstant.placeholderColor,
                                    )
                                  else
                                    Icon(
                                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                      size: 20,
                                      color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: size.height * 0.03),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, size: 14, color: ColorConstant.labelTextColor),
                          const SizedBox(width: 6),
                          TextContext(
                            text: '100% Secure Payments',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.labelTextColor,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),

            // ---------------- BOTTOM PAY BUTTON ----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.015),
              child: CustomButton(
                text: checkoutVm.isPlacingOrder ? 'Placing order...' : 'Pay ${AppUtils.formatCurrency(amountToPay)}',
                onTap: checkoutVm.isPlacingOrder ? null : () => _onPayNow(checkoutVm),
                loading: checkoutVm.isPlacingOrder,
                color: ColorConstant.primaryColor,
                icon: Icons.lock_rounded,
                iconColor: ColorConstant.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}