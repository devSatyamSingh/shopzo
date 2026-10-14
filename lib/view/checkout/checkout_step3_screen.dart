import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../viewmodel/cart/cart_viewmodel.dart';
import '../../viewmodel/order_checkout/order_checkout_viewmodel.dart';
import 'checkout_stepper.dart';
import 'order_confirmation_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentOptionData {
  final IconData icon;
  final String title;
  final String method; // backend ko jane wali value
  final bool isLive;

  const PaymentOptionData({
    required this.icon,
    required this.title,
    required this.method,
    this.isLive = false,
  });
}

class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  // Wallet ka card alag se upar banta hai (_WalletCard), baaki yahan se
  static const List<PaymentOptionData> _options = [
    PaymentOptionData(
      icon: Icons.payments_rounded,
      title: 'Cash on Delivery',
      method: 'COD',
      isLive: true,
    ),
    PaymentOptionData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'UPI',
      method: 'UPI',
    ),
    PaymentOptionData(
      icon: Icons.credit_card_rounded,
      title: 'Credit / Debit Card',
      method: 'CARD',
    ),
    PaymentOptionData(
      icon: Icons.account_balance_rounded,
      title: 'Net Banking',
      method: 'NETBANKING',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Latest wallet balance lane ke liye preview dobara fetch karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CheckoutViewModel>();
      if (vm.items.isNotEmpty && !vm.isPreviewLoading) vm.fetchPreview();
    });
  }

  String _getPaymentTitle(String title) {
    switch (title) {
      case 'Cash on Delivery':
        return 'checkout.payment.cash_on_delivery'.tr();
      case 'UPI':
        return 'checkout.payment.upi'.tr();
      case 'Credit / Debit Card':
        return 'checkout.payment.credit_debit_card'.tr();
      case 'Net Banking':
        return 'checkout.payment.net_banking'.tr();
      default:
        return title;
    }
  }

  void _onOptionTap(CheckoutViewModel vm, PaymentOptionData option) {
    if (!option.isLive) {
      AppUtils.warning(
        context,
        'checkout.payment.payment_coming_soon'.tr(
          args: [_getPaymentTitle(option.title)],
        ),
      );
      return;
    }
    vm.setPaymentMethod(option.method);
  }

  void _onWalletTap(CheckoutViewModel vm) {
    if (!vm.walletSufficient) {
      final shortfall = (vm.total - vm.walletBalance).clamp(0, double.infinity);
      AppUtils.warning(
        context,
        'checkout.payment.wallet_insufficient'.tr(
          namedArgs: {'amount': AppUtils.formatCurrency(shortfall)},
        ),
      );
      return;
    }
    vm.setPaymentMethod('WALLET');
  }

  Future<void> _onPayNow(CheckoutViewModel checkoutVm) async {
    // COD ya WALLET — jo vm me selected hai wahi backend ko jayega
    final success = await checkoutVm.placeOrder();
    if (!mounted) return;

    if (success) {
      await context.read<CartViewModel>().fetchCart(showLoader: false);
      if (!mounted) return;

      final placedOrder = checkoutVm.lastPlacedOrder!;
      checkoutVm.reset();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: placedOrder)),
            (route) => route.settings.name == RouteName.mainWrapper || route.isFirst,
      );
    } else {
      AppUtils.error(context, checkoutVm.placeOrderError ?? 'Failed to place order');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final checkoutVm = context.watch<CheckoutViewModel>();
    context.watch<LanguageProvider>();

    if (checkoutVm.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('checkout.checkout'.tr()), centerTitle: true),
        body: Center(
          child: TextContext(
            text: 'checkout.order.no_items'.tr(),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final double amountToPay = checkoutVm.total;
    final String selectedMethod = checkoutVm.paymentMethod;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: Text('checkout.checkout'.tr()),
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
                            'checkout.payment.amount_to_pay'.tr(),
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
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.028),

                    TextContext(
                      text: 'checkout.payment.payment_method'.tr(),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: size.height * 0.012),

                    // ---------------- WALLET CARD ----------------
                    Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.012),
                      child: _WalletCard(
                        isSelected: selectedMethod == 'WALLET',
                        isLoading: checkoutVm.isPreviewLoading && !checkoutVm.hasPreviewLoadedOnce,
                        sufficient: checkoutVm.walletSufficient,
                        balance: checkoutVm.walletBalance,
                        total: amountToPay,
                        remaining: checkoutVm.walletRemaining,
                        onTap: () => _onWalletTap(checkoutVm),
                      ),
                    ),

                    // ---------------- OTHER PAYMENT OPTIONS ----------------
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      final isSelected = option.isLive && selectedMethod == option.method;
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.012),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _onOptionTap(checkoutVm, option),
                          child: Opacity(
                            opacity: option.isLive ? 1 : 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorConstant.whiteColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? ColorConstant.primaryColor
                                      : ColorConstant.borderColor,
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
                                      text: _getPaymentTitle(option.title),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstant.headlineTextColor,
                                    ),
                                  ),
                                  if (!option.isLive)
                                    TextContext(
                                      text: 'checkout.payment.coming_soon'.tr(),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstant.placeholderColor,
                                    )
                                  else
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      size: 20,
                                      color: isSelected
                                          ? ColorConstant.primaryColor
                                          : ColorConstant.borderColor,
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
                            text: 'checkout.payment.secure_payments'.tr(),
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
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.015,
              ),
              child: CustomButton(
                text: checkoutVm.isPlacingOrder
                    ? 'checkout.payment.placing_order'.tr()
                    : 'checkout.payment.pay'.tr(
                  args: [AppUtils.formatCurrency(amountToPay)],
                ),
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

/// ---------------- WALLET PAYMENT CARD ----------------
class _WalletCard extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;
  final bool sufficient;
  final double balance;
  final double total;
  final double remaining;
  final VoidCallback onTap;

  const _WalletCard({
    required this.isSelected,
    required this.isLoading,
    required this.sufficient,
    required this.balance,
    required this.total,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shortfall = (total - balance).clamp(0, double.infinity).toDouble();
    final Color accent = sufficient ? ColorConstant.primaryColor : ColorConstant.placeholderColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: sufficient || isLoading ? 1 : 0.65,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.account_balance_wallet_rounded, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextContext(
                          text: 'checkout.payment.wallet'.tr(),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.headlineTextColor,
                        ),
                        const SizedBox(height: 2),
                        if (isLoading)
                          const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.6,
                              color: ColorConstant.primaryColor,
                            ),
                          )
                        else
                          TextContext(
                            text: 'checkout.payment.wallet_balance'.tr(
                              namedArgs: {'amount': AppUtils.formatCurrency(balance)},
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.labelTextColor,
                          ),
                      ],
                    ),
                  ),
                  if (!isLoading && !sufficient)
                    TextContext(
                      text: 'checkout.payment.wallet_low'.tr(),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.errorColor,
                    )
                  else
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 20,
                      color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                    ),
                ],
              ),

              // ---- Kam balance: kitna chahiye ----
              if (!isLoading && !sufficient) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorConstant.errorColor.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextContext(
                    text: 'checkout.payment.wallet_insufficient'.tr(
                      namedArgs: {'amount': AppUtils.formatCurrency(shortfall)},
                    ),
                    fontSize: 11.5,
                    height: 1.4,
                    color: ColorConstant.errorColor,
                  ),
                ),
              ],

              // ---- Selected: breakdown ----
              if (isSelected && sufficient) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _row('checkout.bill.to_pay'.tr(), '-${AppUtils.formatCurrency(total)}',
                          ColorConstant.errorColor),
                      const SizedBox(height: 6),
                      _row(
                        'checkout.payment.wallet_after_label'.tr(),
                        AppUtils.formatCurrency(remaining),
                        ColorConstant.successColor,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextContext(
                          text: 'checkout.payment.wallet_full_note'.tr(),
                          fontSize: 11,
                          height: 1.4,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextContext(
          text: label,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: ColorConstant.labelTextColor,
        ),
        TextContext(
          text: value,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: valueColor,
        ),
      ],
    );
  }
}