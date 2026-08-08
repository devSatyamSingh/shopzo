import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shopzo/res/button_context.dart';
import 'package:shopzo/utils/utils.dart';
import '../res/color_constant.dart';
import '../res/text_context.dart';

class TestPaymentScreen extends StatefulWidget {
  const TestPaymentScreen({super.key});

  @override
  State<TestPaymentScreen> createState() => _TestPaymentScreenState();
}

class _TestPaymentScreenState extends State<TestPaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  static const int _amountInPaise = 500; // ₹5

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // removes listeners, avoids memory leaks
    super.dispose();
  }

  void _openCheckout() {
    setState(() => _isProcessing = true);

    var options = {
      // Replace with your own Test Key ID from Razorpay Dashboard
      'key': 'rzp_test_TMrR6ooJaZ04CA',
      'amount': _amountInPaise,
      'name': 'Shopzo',
      'description': 'Test Payment',
      'prefill': {
        'contact': '9161440593',
        'email': 'satyam@gmail.com',
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      },
      'theme': {
        'color': '#4F46E5',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      AppUtils.error(context, 'Something went wrong while opening checkout.');
      debugPrint('Razorpay open error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    AppUtils.success(
      context,
      'Payment ID: ${response.paymentId}',
      title: 'Payment Successful',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    AppUtils.error(
      context,
      response.message ?? 'Payment could not be completed.',
      title: 'Payment Failed',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    AppUtils.info(
      context,
      'Selected wallet: ${response.walletName}',
      title: 'External Wallet',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.fieldFillColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        elevation: 0,
        centerTitle: true,
        title: TextContext(
          text: 'Test Payment',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstant.blackColor.withOpacity(.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryColor.withOpacity(.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.currency_rupee_rounded,
                      color: ColorConstant.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextContext(
                    text: 'Amount to Pay',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
                  const SizedBox(height: 6),
                  TextContext(
                    text: AppUtils.formatCurrency(_amountInPaise / 100),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.headlineTextColor,
                  ),
                  const SizedBox(height: 10),
                  TextContext(
                    text: 'This is a sandbox transaction. No real money\nwill be deducted in Test Mode.',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                    height: 1.4,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _PaymentMethodChip(icon: Icons.qr_code_rounded, label: 'UPI'),
                const SizedBox(width: 10),
                _PaymentMethodChip(icon: Icons.credit_card_rounded, label: 'Card'),
                const SizedBox(width: 10),
                _PaymentMethodChip(icon: Icons.account_balance_rounded, label: 'Netbanking'),
              ],
            ),
            const Spacer(),
            CustomButton(
              text: _isProcessing ? 'Processing...' : 'Pay ₹5 Now',
              icon: _isProcessing ? null : Icons.lock_outline_rounded,
              loading: _isProcessing,
              onTap: _isProcessing ? null : _openCheckout,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_rounded, size: 14, color: ColorConstant.labelTextColor),
                const SizedBox(width: 6),
                TextContext(
                  text: 'Secured by Razorpay',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PaymentMethodChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorConstant.fieldFillColor, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: ColorConstant.primaryColor),
            const SizedBox(height: 6),
            TextContext(
              text: label,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ColorConstant.labelTextColor,
            ),
          ],
        ),
      ),
    );
  }
}