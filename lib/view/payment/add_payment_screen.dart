import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  int _tabIndex = 0; // 0 = Credit/Debit Card, 1 = UPI ID

  // ---- card form ----
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  bool _saveCard = true;
  bool _addingCard = false;

  // ---- upi form ----
  final TextEditingController _vpaController = TextEditingController();
  bool _addingUpi = false;

  static const List<String> _suggestedHandles = [
    '@okaxis',
    '@ybl',
    '@paytm',
    '@ibl',
    '@okhdfcbank',
  ];

  bool get _isCardFormValid =>
      _cardNumberController.text.trim().length >= 12 &&
          _expiryController.text.trim().length == 5 &&
          _cvvController.text.trim().length >= 3 &&
          _holderNameController.text.trim().isNotEmpty;

  bool get _isVpaValid => _vpaController.text.trim().contains('@');

  void _onAddCard() {
    if (!_isCardFormValid) return;
    setState(() => _addingCard = true);
    // 👉 tokenize card via your payment gateway SDK, then save
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _addingCard = false);
      Navigator.pop(context);
    });
  }

  void _onVerifyAndLink() {
    if (!_isVpaValid) return;
    // 👉 call your UPI verification API
  }

  void _onAddUpi() {
    if (!_isVpaValid) return;
    setState(() => _addingUpi = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _addingUpi = false);
      Navigator.pop(context);
    });
  }

  void _onHelpTap() {}

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    _vpaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('Add Payment Method'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onHelpTap,
            icon: Icon(Icons.help_outline_rounded, color: ColorConstant.primaryColor),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- TAB SWITCH ----------------
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorConstant.primaryLight,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabChip(
                        label: 'Credit / Debit Card',
                        selected: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _TabChip(
                        label: 'UPI ID',
                        selected: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.025),

              if (_tabIndex == 0)
                _CardTab(
                  cardNumberController: _cardNumberController,
                  expiryController: _expiryController,
                  cvvController: _cvvController,
                  holderNameController: _holderNameController,
                  saveCard: _saveCard,
                  onSaveCardChanged: (v) => setState(() => _saveCard = v),
                  isValid: _isCardFormValid,
                  loading: _addingCard,
                  onAddCard: _onAddCard,
                  onFieldChanged: () => setState(() {}),
                )
              else
                _UpiTab(
                  vpaController: _vpaController,
                  suggestedHandles: _suggestedHandles,
                  isValid: _isVpaValid,
                  loading: _addingUpi,
                  onVerifyAndLink: _onVerifyAndLink,
                  onAddUpi: _onAddUpi,
                  onFieldChanged: () => setState(() {}),
                  onHandleTap: (handle) {
                    final current = _vpaController.text.split('@').first;
                    _vpaController.text = '$current$handle';
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- TAB CHIP ----------------
class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? ColorConstant.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : ColorConstant.primaryColor,
          ),
        ),
      ),
    );
  }
}

/// ---------------- CARD TAB ----------------
class _CardTab extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController holderNameController;
  final bool saveCard;
  final ValueChanged<bool> onSaveCardChanged;
  final bool isValid;
  final bool loading;
  final VoidCallback onAddCard;
  final VoidCallback onFieldChanged;

  const _CardTab({
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.holderNameController,
    required this.saveCard,
    required this.onSaveCardChanged,
    required this.isValid,
    required this.loading,
    required this.onAddCard,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- PROMO CARD IMAGE ----------------
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/add_card_promo.png',
            height: size.height * 0.24,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: size.height * 0.24,
              width: double.infinity,
              decoration: BoxDecoration(gradient: ColorConstant.primaryGradient),
              alignment: Alignment.center,
              child: const Icon(Icons.credit_card_rounded, size: 42, color: Colors.white),
            ),
          ),
        ),

        SizedBox(height: size.height * 0.026),

        _FieldLabel(text: 'Card Number'),
        CustomTextField(
          controller: cardNumberController,
          hintText: '0000 0000 0000 0000',
          keyboardType: TextInputType.number,
          maxLength: 19,
          suffixIcon: Icon(Icons.credit_card_rounded, color: ColorConstant.placeholderColor),
          onChanged: (_) => onFieldChanged(),
        ),

        SizedBox(height: size.height * 0.018),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: 'Expiry Date'),
                  CustomTextField(
                    controller: expiryController,
                    hintText: 'MM/YY',
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    onChanged: (_) => onFieldChanged(),
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: 'CVV'),
                  CustomTextField(
                    controller: cvvController,
                    hintText: '•••',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 3,
                    suffixIcon: Icon(Icons.help_outline_rounded,
                        size: 18, color: ColorConstant.placeholderColor),
                    onChanged: (_) => onFieldChanged(),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: size.height * 0.018),

        _FieldLabel(text: 'Cardholder Name'),
        CustomTextField(
          controller: holderNameController,
          hintText: 'John Doe',
          onChanged: (_) => onFieldChanged(),
        ),

        SizedBox(height: size.height * 0.022),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: 'Save this card',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.headlineTextColor,
                  ),
                  TextContext(
                    text: 'For faster payments next time',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),
            ),
            Switch(
              value: saveCard,
              onChanged: onSaveCardChanged,
              activeColor: Colors.white,
              activeTrackColor: ColorConstant.primaryColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: ColorConstant.borderColor,
            ),
          ],
        ),

        SizedBox(height: size.height * 0.025),

        CustomButton(
          text: 'Add Card',
          onTap: isValid ? onAddCard : () {},
          loading: loading,
          color: isValid ? ColorConstant.primaryColor : ColorConstant.borderColor,
        ),

        SizedBox(height: size.height * 0.02),

        _SecureFooter(),
      ],
    );
  }
}

/// ---------------- UPI TAB ----------------
class _UpiTab extends StatelessWidget {
  final TextEditingController vpaController;
  final List<String> suggestedHandles;
  final bool isValid;
  final bool loading;
  final VoidCallback onVerifyAndLink;
  final VoidCallback onAddUpi;
  final VoidCallback onFieldChanged;
  final ValueChanged<String> onHandleTap;

  const _UpiTab({
    required this.vpaController,
    required this.suggestedHandles,
    required this.isValid,
    required this.loading,
    required this.onVerifyAndLink,
    required this.onAddUpi,
    required this.onFieldChanged,
    required this.onHandleTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blackColor.withOpacity(.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(text: 'Virtual Payment Address (VPA)'),
              CustomTextField(
                controller: vpaController,
                hintText: 'example@upi',
                fillColor: ColorConstant.primaryLight,
                showBorder: false,
                onChanged: (_) => onFieldChanged(),
              ),

              SizedBox(height: size.height * 0.018),

              TextContext(
                text: 'Suggested Handles',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ColorConstant.labelTextColor,
              ),
              SizedBox(height: size.height * 0.01),
              Wrap(
                spacing: size.width * 0.02,
                runSpacing: size.height * 0.01,
                children: suggestedHandles.map((handle) {
                  return GestureDetector(
                    onTap: () => onHandleTap(handle),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorConstant.borderColor),
                      ),
                      child: Text(
                        handle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.bodyTextColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: size.height * 0.022),

              CustomButton(
                text: 'Verify & Link',
                onTap: isValid ? onVerifyAndLink : () {},
                outlined: true,
                borderColor: isValid ? ColorConstant.primaryColor : ColorConstant.borderColor,
                textColor: isValid ? ColorConstant.primaryColor : ColorConstant.placeholderColor,
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.022),

        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 13, color: ColorConstant.labelTextColor),
              const SizedBox(width: 6),
              Text(
                'SECURE 256-BIT SSL ENCRYPTION',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: ColorConstant.labelTextColor,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.022),

        // ---------------- FAST & DIRECT INFO ----------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorConstant.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(
                      text: 'Fast & Direct',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.primaryColor,
                    ),
                    SizedBox(height: size.height * 0.006),
                    TextContext(
                      text:
                      'Money will be debited directly from your bank account via UPI. Secure and instantaneous payments.',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: ColorConstant.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.account_balance_rounded,
                  size: 40, color: ColorConstant.primaryColor.withOpacity(.5)),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.03),

        CustomButton(
          text: 'Add UPI ID',
          onTap: isValid ? onAddUpi : () {},
          loading: loading,
          color: isValid ? ColorConstant.primaryColor : ColorConstant.placeholderColor,
        ),

        SizedBox(height: size.height * 0.02),
      ],
    );
  }
}

/// ---------------- SECURE FOOTER (card tab) ----------------
class _SecureFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 13, color: ColorConstant.labelTextColor),
              const SizedBox(width: 6),
              Text(
                'Secure 256-bit SSL Encrypted Payment',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.labelTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 18, color: ColorConstant.placeholderColor),
              const SizedBox(width: 14),
              Icon(Icons.verified_rounded, size: 18, color: ColorConstant.placeholderColor),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- FIELD LABEL ----------------
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextContext(
        text: text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ColorConstant.bodyTextColor,
      ),
    );
  }
}