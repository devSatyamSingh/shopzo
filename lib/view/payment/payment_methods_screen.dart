import 'package:flutter/material.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import 'add_payment_screen.dart';

class UpiIdModel {
  final IconData icon;
  final String value;
  final String? label;
  final bool isVerified;
  final bool isDefault;

  const UpiIdModel({
    required this.icon,
    required this.value,
    this.label,
    this.isVerified = false,
    this.isDefault = false,
  });
}

class SavedCardModel {
  final String bankName;
  final String cardTier;
  final String last4;
  final String holderName;
  final String expiry;
  final List<Color> gradient;

  const SavedCardModel({
    required this.bankName,
    required this.cardTier,
    required this.last4,
    required this.holderName,
    required this.expiry,
    required this.gradient,
  });
}

class OtherMethodData {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const OtherMethodData({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  static const List<UpiIdModel> _upiIds = [
    UpiIdModel(
      icon: Icons.account_balance_wallet_rounded,
      value: 'alex.johnson@okaxis',
      isVerified: true,
      isDefault: true,
    ),
    UpiIdModel(
      icon: Icons.payments_rounded,
      value: '9876543210@ybl',
      label: 'PhonePe UPI',
    ),
  ];

  static const List<SavedCardModel> _cards = [
    SavedCardModel(
      bankName: 'HDFC Bank',
      cardTier: 'PREMIUM CREDIT',
      last4: '4821',
      holderName: 'ALEX JOHNSON',
      expiry: '12/28',
      gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    ),
    SavedCardModel(
      bankName: 'SBI Bank',
      cardTier: 'PRIVILEGE DEBIT',
      last4: '2109',
      holderName: 'ALEX JOHNSON',
      expiry: '09/27',
      gradient: [Color(0xFF1F2937), Color(0xFF374151)],
    ),
  ];

  static const List<OtherMethodData> _otherMethods = [
    OtherMethodData(
      icon: Icons.account_balance_rounded,
      iconColor: Color(0xFFEA580C),
      iconBgColor: Color(0xFFFFF1E6),
      title: 'Net Banking',
      subtitle: 'HDFC, ICICI, SBI & more',
    ),
    OtherMethodData(
      icon: Icons.account_balance_wallet_outlined,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFE8EEFF),
      title: 'Wallets',
      subtitle: 'Amazon Pay, Paytm, MobiKwik',
    ),
    OtherMethodData(
      icon: Icons.currency_rupee_rounded,
      iconColor: Color(0xFF16A34A),
      iconBgColor: Color(0xFFE7F7EC),
      title: 'Cash on Delivery',
      subtitle: 'Manage COD preferences',
    ),
  ];

  void _onAddNew(BuildContext context) {
    Navigator.pushNamed(context, RouteName.addPaymentMethod);
  }

  void _onUpiOptionsTap(UpiIdModel upi) {
    // 👉 show bottom sheet: set default / remove
  }

  void _onManageOtherTap(OtherMethodData method) {
    // 👉 navigate to the relevant settings screen
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('Payment Methods'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _onAddNew(context),
            icon: Icon(Icons.add_rounded, color: ColorConstant.primaryColor),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- UPI IDs ----------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextContext(
                          text: 'UPI IDs',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: ColorConstant.headlineTextColor,
                        ),
                        GestureDetector(
                          onTap: () => _onAddNew(context),
                          child: TextContext(
                            text: 'Add New',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: ColorConstant.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.015),
                    ..._upiIds.map((upi) => Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.015),
                      child: _UpiCard(
                        upi: upi,
                        onOptionsTap: () => _onUpiOptionsTap(upi),
                      ),
                    )),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.01),

              // ---------------- SAVED CARDS ----------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextContext(
                      text: 'Saved Cards',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.headlineTextColor,
                    ),
                    TextContext(
                      text: '${_cards.length} Cards',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.015),

              SizedBox(
                height: size.height * 0.21,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  itemCount: _cards.length,
                  separatorBuilder: (_, __) => SizedBox(width: size.width * 0.035),
                  itemBuilder: (context, index) => _SavedCardTile(
                    card: _cards[index],
                    width: size.width * 0.74,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.028),

              // ---------------- MANAGE OTHER METHODS ----------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(
                      text: 'Manage Other Methods',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: size.height * 0.015),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorConstant.whiteColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ColorConstant.blackColor.withOpacity(.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: List.generate(_otherMethods.length, (index) {
                          final method = _otherMethods[index];
                          final isLast = index == _otherMethods.length - 1;
                          return InkWell(
                            onTap: () => _onManageOtherTap(method),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : Border(
                                  bottom: BorderSide(
                                      color: ColorConstant.dividerColor, width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(
                                      color: method.iconBgColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(method.icon, size: 18, color: method.iconColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextContext(
                                          text: method.title,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstant.headlineTextColor,
                                        ),
                                        TextContext(
                                          text: method.subtitle,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: ColorConstant.labelTextColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded,
                                      size: 20, color: ColorConstant.placeholderColor),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // ---------------- SECURITY NOTE ----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorConstant.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_rounded, size: 18, color: ColorConstant.primaryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextContext(
                              text:
                              'Shopzo uses industry-standard encryption to protect your payment details. We do not store your full card details or CVV.',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: ColorConstant.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- UPI ID CARD ----------------
class _UpiCard extends StatelessWidget {
  final UpiIdModel upi;
  final VoidCallback onOptionsTap;

  const _UpiCard({required this.upi, required this.onOptionsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: ColorConstant.fieldFillColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(upi.icon, size: 18, color: ColorConstant.headlineTextColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextContext(
                  text: upi.value,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: ColorConstant.headlineTextColor,
                ),
                const SizedBox(height: 5),
                if (upi.isVerified || upi.isDefault)
                  Row(
                    children: [
                      if (upi.isVerified) _Pill(text: 'VERIFIED', color: ColorConstant.successColor),
                      if (upi.isVerified && upi.isDefault) const SizedBox(width: 6),
                      if (upi.isDefault) _Pill(text: 'DEFAULT', color: ColorConstant.primaryColor),
                    ],
                  )
                else if (upi.label != null)
                  TextContext(
                    text: upi.label!,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
              ],
            ),
          ),
          if (upi.isDefault)
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ColorConstant.headlineTextColor, width: 1.4),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.check_rounded, size: 15, color: ColorConstant.headlineTextColor),
            )
          else
            GestureDetector(
              onTap: onOptionsTap,
              child: Icon(Icons.more_vert_rounded, color: ColorConstant.labelTextColor),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

/// ---------------- SAVED CARD TILE ----------------
class _SavedCardTile extends StatelessWidget {
  final SavedCardModel card;
  final double width;

  const _SavedCardTile({required this.card, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: card.gradient.first.withOpacity(.3),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardTier,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(.75),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.bankName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.credit_card_rounded, color: Colors.white, size: 22),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '••••  ••••  ••••  ',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  letterSpacing: 2,
                  color: Colors.white.withOpacity(.85),
                ),
              ),
              Text(
                card.last4,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.5,
                      color: Colors.white.withOpacity(.65),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    card.holderName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.5,
                      color: Colors.white.withOpacity(.65),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    card.expiry,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}