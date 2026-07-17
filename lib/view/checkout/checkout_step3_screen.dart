import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import 'checkout_stepper.dart';

class SavedPaymentMethod {
  final String logo;
  final String title;
  final String status;
  final bool isReady;

  const SavedPaymentMethod({
    required this.logo,
    required this.title,
    required this.status,
    this.isReady = false,
  });
}

class PaymentOptionData {
  final IconData icon;
  final String title;

  const PaymentOptionData({required this.icon, required this.title});
}

class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  int _expandedIndex = 0; // UPI expanded by default, matching design
  final TextEditingController _upiController = TextEditingController();
  bool _verifying = false;

  static const double _amountToPay = 2384;

  static const List<SavedPaymentMethod> _quickPay = [
    SavedPaymentMethod(
      logo: 'assets/images/gpay_logo.png',
      title: 'GPay ••••',
      status: 'READY',
      isReady: true,
    ),
    SavedPaymentMethod(
      logo: 'assets/images/visa_logo.png',
      title: 'Visa •••• 4821',
      status: 'HDFC BANK',
    ),
  ];

  static const List<PaymentOptionData> _options = [
    PaymentOptionData(icon: Icons.account_balance_wallet_rounded, title: 'UPI'),
    PaymentOptionData(icon: Icons.credit_card_rounded, title: 'Credit / Debit Card'),
    PaymentOptionData(icon: Icons.account_balance_rounded, title: 'Net Banking'),
    PaymentOptionData(icon: Icons.account_balance_wallet_outlined, title: 'Wallets'),
    PaymentOptionData(icon: Icons.payments_rounded, title: 'Cash on Delivery'),
  ];

  String _fmt(double v) {
    final whole = v.toStringAsFixed(0);
    return whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  void _onViewBillDetails() {
    // 👉 show bill breakdown bottom sheet
  }

  void _onQuickPayTap(SavedPaymentMethod method) {
    // 👉 pay using this saved method
  }

  void _onVerifyAndPay() {
    if (_upiController.text.trim().isEmpty) return;
    setState(() => _verifying = true);
    // 👉 call your UPI verify/collect-request API here
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _verifying = false);
    });
  }

  void _onPayNow() {
    // 👉 process final payment for the selected method
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
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
                                  '₹${_fmt(_amountToPay)}',
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
                          GestureDetector(
                            onTap: _onViewBillDetails,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'View bill details',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.chevron_right_rounded, size: 15, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.026),

                    TextContext(
                      text: 'Quick Pay',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: size.height * 0.012),

                    // ---------------- QUICK PAY ----------------
                    SizedBox(
                      height: size.height * 0.075,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _quickPay.length,
                        separatorBuilder: (_, __) => SizedBox(width: size.width * 0.03),
                        itemBuilder: (context, index) {
                          final method = _quickPay[index];
                          return GestureDetector(
                            onTap: () => _onQuickPayTap(method),
                            child: Container(
                              width: size.width * 0.42,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: ColorConstant.whiteColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: ColorConstant.borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                      color: ColorConstant.fieldFillColor,
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      method.logo,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 16,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextContext(
                                          text: method.title,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstant.headlineTextColor,
                                        ),
                                        TextContext(
                                          text: method.status,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: method.isReady
                                              ? ColorConstant.primaryColor
                                              : ColorConstant.labelTextColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: size.height * 0.028),

                    TextContext(
                      text: 'All Payment Options',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: size.height * 0.012),

                    // ---------------- PAYMENT OPTIONS ----------------
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      final isExpanded = index == _expandedIndex;

                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.012),
                        child: _PaymentOptionTile(
                          option: option,
                          isExpanded: isExpanded,
                          onTap: () => setState(
                                  () => _expandedIndex = isExpanded ? -1 : index),
                          expandedChild: option.title == 'UPI'
                              ? _UpiExpandedContent(
                            controller: _upiController,
                            verifying: _verifying,
                            onVerify: _onVerifyAndPay,
                          )
                              : null,
                        ),
                      );
                    }),

                    SizedBox(height: size.height * 0.03),

                    // ---------------- SECURE PAYMENTS FOOTER ----------------
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 14, color: ColorConstant.labelTextColor),
                              const SizedBox(width: 6),
                              TextContext(
                                text: '100% Secure Payments',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: ColorConstant.labelTextColor,
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.012),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: ['VISA', 'MC', 'UPI', 'RuPay'].map((label) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: ColorConstant.fieldFillColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstant.placeholderColor,
                                  ),
                                ),
                              );
                            }).toList(),
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
                text: 'Pay ₹${_fmt(_amountToPay)}',
                onTap: _onPayNow,
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

/// ---------------- EXPANDABLE PAYMENT OPTION TILE ----------------
class _PaymentOptionTile extends StatelessWidget {
  final PaymentOptionData option;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget? expandedChild;

  const _PaymentOptionTile({
    required this.option,
    required this.isExpanded,
    required this.onTap,
    this.expandedChild,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? ColorConstant.primaryColor : ColorConstant.borderColor,
          width: isExpanded ? 1.6 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
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
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && expandedChild != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: expandedChild,
            ),
        ],
      ),
    );
  }
}

/// ---------------- UPI EXPANDED CONTENT ----------------
class _UpiExpandedContent extends StatelessWidget {
  final TextEditingController controller;
  final bool verifying;
  final VoidCallback onVerify;

  const _UpiExpandedContent({
    required this.controller,
    required this.verifying,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstant.fieldFillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: ColorConstant.headlineTextColor,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: InputBorder.none,
                    hintText: 'Enter UPI ID (e.g. user@bank)',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      color: ColorConstant.placeholderColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomButton(
                  height: 47,
                  text: 'Verify & Pay',
                  onTap: onVerify,
                  loading: verifying,
                  color: ColorConstant.primaryColor,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextContext(
          text: 'Payment will be processed via your UPI app.',
          fontSize: 11.5,
          fontWeight: FontWeight.w400,
          color: ColorConstant.labelTextColor,
        ),
      ],
    );
  }
}