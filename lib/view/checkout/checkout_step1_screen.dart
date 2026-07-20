import 'package:flutter/material.dart';
import 'package:shopzo/view/checkout/checkout_step2_screen.dart';
import 'package:shopzo/view/checkout/checkout_step3_screen.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import 'checkout_stepper.dart';

class AddressModel {
  final IconData icon;
  final String name;
  final String line1;
  final String line2;
  final String? phone;
  final bool isDefault;

  const AddressModel({
    required this.icon,
    required this.name,
    required this.line1,
    required this.line2,
    this.phone,
    this.isDefault = false,
  });
}

class CheckoutAddressScreen extends StatefulWidget {
  const CheckoutAddressScreen({super.key});

  @override
  State<CheckoutAddressScreen> createState() => _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState extends State<CheckoutAddressScreen> {
  int _deliveryMode = 0; // 0 = Home Delivery, 1 = Store Pickup
  int _selectedAddressIndex = 0;

  static const List<AddressModel> _addresses = [
    AddressModel(
      icon: Icons.home_rounded,
      name: 'Alex Johnston',
      line1: '482 Oakwood Avenue, Suite 12',
      line2: 'Los Angeles, CA 90024',
      phone: '+1 (555) 012-3456',
      isDefault: true,
    ),
    AddressModel(
      icon: Icons.work_rounded,
      name: 'Alex Johnston',
      line1: 'Corporate Tower B, 15th Floor',
      line2: 'San Francisco, CA 94105',
    ),
  ];

  void _onAddNewAddress() {
    // 👉 navigate to Add/Edit Address screen
  }

  void _onEditAddress(int index) {
    // 👉 navigate to Edit Address screen with _addresses[index]
  }

  void _onContinue() {
    Navigator.pushNamed(context, RouteName.checkoutSummary);
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
            const CheckoutStepper(currentStep: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- DELIVERY MODE TOGGLE ----------------
                    Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            icon: Icons.home_rounded,
                            label: 'Home Delivery',
                            selected: _deliveryMode == 0,
                            onTap: () => setState(() => _deliveryMode = 0),
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: _ModeButton(
                            icon: Icons.storefront_rounded,
                            label: 'Store Pickup',
                            selected: _deliveryMode == 1,
                            onTap: () => setState(() => _deliveryMode = 1),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    // ---------------- ESTIMATED DELIVERY BANNER ----------------
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.016,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstant.successColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: ColorConstant.successColor.withOpacity(.15),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.local_shipping_rounded,
                                size: 19, color: ColorConstant.successColor),
                          ),
                          SizedBox(width: size.width * 0.03),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextContext(
                                text: 'Estimated delivery',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: ColorConstant.successColor,
                              ),
                              TextContext(
                                text: 'Fri, 19 July',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.successColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.028),

                    TextContext(
                      text: 'Saved Addresses',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),

                    SizedBox(height: size.height * 0.015),

                    // ---------------- ADDRESS CARDS ----------------
                    ...List.generate(_addresses.length, (index) {
                      final address = _addresses[index];
                      final isSelected = index == _selectedAddressIndex;

                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.018),
                        child: _AddressCard(
                          address: address,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedAddressIndex = index),
                          onEdit: () => _onEditAddress(index),
                        ),
                      );
                    }),

                    // ---------------- ADD NEW ADDRESS ----------------
                    GestureDetector(
                      onTap: _onAddNewAddress,
                      child: DottedBorderBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorConstant.primaryColor, width: 1.6),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.add_rounded,
                                  size: 18, color: ColorConstant.primaryColor),
                            ),
                            const SizedBox(width: 10),
                            TextContext(
                              text: 'Add New Address',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),

            // ---------------- BOTTOM BUTTON ----------------
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.015,
              ),
              child: CustomButton(
                text: 'Continue to Summary',
                onTap: _onContinue,
                color: ColorConstant.primaryColor,
                icon: Icons.arrow_forward,
                iconColor: ColorConstant.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- HOME DELIVERY / STORE PICKUP TOGGLE BUTTON ----------------
class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? ColorConstant.primaryColor : ColorConstant.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : ColorConstant.primaryColor),
            const SizedBox(width: 8),
            Flexible(
              child: TextContext(
                text: label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : ColorConstant.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- SAVED ADDRESS CARD ----------------
class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: ColorConstant.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(address.icon, size: 19, color: ColorConstant.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextContext(
                          text: address.name,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.headlineTextColor,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ColorConstant.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextContext(
                    text: address.line1,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
                  TextContext(
                    text: address.line2,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
                  if (address.phone != null)
                    TextContext(
                      text: address.phone!,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.labelTextColor,
                    ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 22,
                  color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.edit_rounded, size: 14, color: ColorConstant.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- DASHED BORDER CONTAINER ----------------
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: ColorConstant.primaryColor),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dashLength = 6.0;
      const gapLength = 5.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}