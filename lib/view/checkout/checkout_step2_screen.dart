import 'package:flutter/material.dart';
import 'package:shopzo/view/checkout/checkout_step3_screen.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import 'checkout_stepper.dart';

class OrderItemModel {
  final String image;
  final String name;
  final String variant;
  final double price;
  final int qty;

  const OrderItemModel({
    required this.image,
    required this.name,
    required this.variant,
    required this.price,
    required this.qty,
  });
}

class SellerGroup {
  final String image;
  final String sellerName;
  final List<OrderItemModel> items;

  const SellerGroup({
    required this.image,
    required this.sellerName,
    required this.items,
  });
}

class CheckoutSummaryScreen extends StatefulWidget {
  const CheckoutSummaryScreen({super.key});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = 0;
  bool _showBreakdown = false;

  static const List<String> _dateLabels = ['Today', 'Tomorrow', 'Wed', 'Thu'];
  static const List<String> _dateNumbers = ['18', '19', '20', '21'];
  static const List<String> _slots = ['9AM - 12PM', '12PM - 4PM', '4PM - 8PM'];

  static const List<SellerGroup> _groups = [
    SellerGroup(
      image: "assets/images/pro12.jpg",
      sellerName: 'Sold by TechHub Store',
      items: [
        OrderItemModel(
          image: 'assets/images/pro1.jpg',
          name: 'Pro Sound ANC Headphones',
          variant: 'Color: Midnight Black',
          price: 12499,
          qty: 1,
        ),
      ],
    ),
    SellerGroup(
      image: "assets/images/pro10.jpg",
      sellerName: 'Sold by UrbanWear',
      items: [
        OrderItemModel(
          image: 'assets/images/pro2.jpg',
          name: 'Essential Heavy Boxy Tee',
          variant: 'Size: L • Color: Cream',
          price: 1299,
          qty: 1,
        ),
        OrderItemModel(
          image: 'assets/images/pro4.jpg',
          name: 'Classic Raw Indigo Denim',
          variant: 'Size: 32 • Fit: Slim',
          price: 2499,
          qty: 1,
        ),
      ],
    ),
  ];

  static const double _itemTotal = 16297;
  static const double _couponDiscount = 120;
  static const double _platformFee = 10;
  static const double _toPay = _itemTotal - _couponDiscount + _platformFee;

  String _fmt(double v) {
    final whole = v.toStringAsFixed(0);
    return whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  void _onChangeAddress() {
    // 👉 pop back to Address step, or open address picker
  }

  void _onRemoveCoupon() {
    // 👉 remove applied coupon
  }

  void _onContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CheckoutPaymentScreen(),
      ),
    );  }

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
            const CheckoutStepper(currentStep: 2),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- DELIVER TO ----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorConstant.whiteColor,
                        borderRadius: BorderRadius.circular(14),
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
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: ColorConstant.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.location_on_rounded,
                                size: 18, color: ColorConstant.primaryColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextContext(
                                  text: 'DELIVER TO:',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.placeholderColor,
                                  letterSpacing: 0.5,
                                ),
                                TextContext(
                                  text: 'Arjun Malhotra',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstant.headlineTextColor,
                                ),
                                TextContext(
                                  text: 'Sector 62, Noida - 201301',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstant.labelTextColor,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _onChangeAddress,
                            child: TextContext(
                              text: 'Change',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.025),

                    TextContext(
                      text: 'Choose Delivery Slot',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: size.height * 0.012),

                    // ---------------- DATE CHIPS ----------------
                    Row(
                      children: List.generate(_dateLabels.length, (index) {
                        final selected = index == _selectedDateIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDateIndex = index),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index != _dateLabels.length - 1 ? size.width * 0.02 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? ColorConstant.primaryColor : ColorConstant.whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: selected
                                    ? null
                                    : Border.all(color: ColorConstant.borderColor),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _dateLabels[index],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: selected ? Colors.white : ColorConstant.labelTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dateNumbers[index],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: selected ? Colors.white : ColorConstant.headlineTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: size.height * 0.012),

                    // ---------------- TIME SLOT CHIPS ----------------
                    Wrap(
                      spacing: size.width * 0.025,
                      runSpacing: size.height * 0.012,
                      children: List.generate(_slots.length, (index) {
                        final selected = index == _selectedSlotIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSlotIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: ColorConstant.whiteColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                                width: selected ? 1.6 : 1,
                              ),
                            ),
                            child: Text(
                              _slots[index],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? ColorConstant.primaryColor
                                    : ColorConstant.bodyTextColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: size.height * 0.028),

                    TextContext(
                      text: 'Order Items (3)',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: size.height * 0.014),

                    // ---------------- SELLER GROUPS ----------------
                    ..._groups.map((group) => Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.02),
                      child: _SellerCard(group: group),
                    )),

                    // ---------------- COUPON APPLIED ----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: ColorConstant.successColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: ColorConstant.successColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.sell_rounded, size: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    TextContext(
                                      text: 'SAVE50 Applied',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstant.successColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ColorConstant.successColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '50% OFF',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextContext(
                                  text: 'You saved ₹120 with this coupon',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstant.successColor,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _onRemoveCoupon,
                            child: TextContext(
                              text: 'Remove',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // ---------------- BILL DETAILS ----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextContext(
                            text: 'Bill Details',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.headlineTextColor,
                          ),
                          SizedBox(height: size.height * 0.014),
                          _BillRow(label: 'Item Total', value: '₹${_fmt(_itemTotal)}'),
                          _BillRow(label: 'Delivery Fee', value: 'FREE', valueColor: ColorConstant.successColor),
                          _BillRow(label: 'Coupon Discount', value: '-₹${_fmt(_couponDiscount)}', valueColor: ColorConstant.successColor),
                          _BillRow(label: 'Platform Fee', value: '₹${_fmt(_platformFee)}'),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
                            child: Divider(color: ColorConstant.dividerColor, height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextContext(
                                text: 'To Pay',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.headlineTextColor,
                              ),
                              TextContext(
                                text: '₹${_fmt(_toPay)}',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),

            // ---------------- BOTTOM BAR ----------------
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.015,
              ),
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: ColorConstant.blackColor.withOpacity(.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showBreakdown = !_showBreakdown),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextContext(
                          text: '₹${_fmt(_toPay)}',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.primaryColor,
                        ),
                        Row(
                          children: [
                            TextContext(
                              text: 'View breakdown',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: ColorConstant.labelTextColor,
                            ),
                            Icon(
                              _showBreakdown
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_up_rounded,
                              size: 16,
                              color: ColorConstant.labelTextColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SizedBox(
                      width: size.width * 0.44,
                      child: CustomButton(
                        text: 'Continue To Payment',
                        onTap: _onContinue,
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
}

/// ---------------- SELLER CARD (group of items) ----------------
class _SellerCard extends StatelessWidget {
  final SellerGroup group;
  const _SellerCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                group.image,
                height: 24,
                width: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 6),
            TextContext(
              text: group.sellerName,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ColorConstant.labelTextColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blackColor.withOpacity(.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: List.generate(group.items.length, (index) {
              final item = group.items[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item.image,
                            height: 56,
                            width: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 56,
                              width: 56,
                              color: ColorConstant.fieldFillColor,
                              alignment: Alignment.center,
                              child: Icon(Icons.image_outlined,
                                  size: 20, color: ColorConstant.placeholderColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextContext(
                                text: item.name,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.headlineTextColor,
                              ),
                              TextContext(
                                text: item.variant,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: ColorConstant.labelTextColor,
                              ),
                              const SizedBox(height: 8),
                              TextContext(
                                text: '₹${item.price.toStringAsFixed(0)}',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.headlineTextColor,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorConstant.fieldFillColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Qty: ${item.qty}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: ColorConstant.bodyTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != group.items.length - 1)
                    Divider(color: ColorConstant.dividerColor, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// ---------------- BILL ROW ----------------
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
          TextContext(
            text: label,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorConstant.labelTextColor,
          ),
          TextContext(
            text: value,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? ColorConstant.headlineTextColor,
          ),
        ],
      ),
    );
  }
}