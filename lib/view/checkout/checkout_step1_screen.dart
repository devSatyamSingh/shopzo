import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/view/address/add_address_screen.dart';
import '../../model/address_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/skelton_box.dart';
import '../../viewmodel/address/address_viewmodel.dart';
import 'checkout_stepper.dart';


class CheckoutAddressScreen extends StatefulWidget {
  const CheckoutAddressScreen({super.key});

  @override
  State<CheckoutAddressScreen> createState() => _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState extends State<CheckoutAddressScreen> {
  int _deliveryMode = 0;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().fetchAddresses();
    });
  }

  void _onAddNewAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    // AddressViewModel updates its own list on success, nothing else to do.
  }

  void _onEditAddress(AddressModel address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddAddressScreen(editAddress: address)),
    );
  }

  void _onContinue(List<AddressModel> addresses) {
    if (addresses.isEmpty) return;

    final selected = addresses.firstWhere(
          (a) => a.id == _selectedAddressId,
      orElse: () => addresses.first,
    );

    Navigator.pushNamed(
      context,
      RouteName.checkoutSummary,
      arguments: selected,
    );
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
              child: Consumer<AddressViewModel>(
                builder: (context, viewModel, _) {
                  // ---------------- LOADING ----------------
                  if (viewModel.isLoading && viewModel.addresses.isEmpty) {
                    return _AddressListSkeleton(size: size);
                  }

                  // ---------------- ERROR ----------------
                  if (viewModel.status == AddressLoadStatus.error &&
                      viewModel.addresses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                size: 46, color: ColorConstant.placeholderColor),
                            SizedBox(height: size.height * 0.015),
                            TextContext(
                              text: viewModel.errorMessage ?? 'Something went wrong',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textAlign: TextAlign.center,
                              color: ColorConstant.labelTextColor,
                            ),
                            SizedBox(height: size.height * 0.02),
                            TextButton(
                              onPressed: () => viewModel.fetchAddresses(forceRefresh: true),
                              child: TextContext(
                                text: 'Retry',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final addresses = viewModel.addresses;

                  // default selection: viewmodel's default address, else first
                  if (_selectedAddressId == null && addresses.isNotEmpty) {
                    _selectedAddressId = (viewModel.defaultAddress ?? addresses.first).id;
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 0.02),

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
                                          text: 'Within 3-5 business days',
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

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextContext(
                                    text: 'Saved Addresses',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstant.headlineTextColor,
                                  ),
                                  TextContext(
                                    text: '${addresses.length} addresses',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: ColorConstant.labelTextColor,
                                  ),
                                ],
                              ),

                              SizedBox(height: size.height * 0.015),

                              // ---------------- EMPTY ----------------
                              if (addresses.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
                                  child: Center(
                                    child: TextContext(
                                      text: 'No saved addresses yet. Add one to continue.',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      textAlign: TextAlign.center,
                                      color: ColorConstant.labelTextColor,
                                    ),
                                  ),
                                ),

                              // ---------------- ADDRESS CARDS ----------------
                              ...addresses.map((address) {
                                final isSelected = address.id == _selectedAddressId;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: size.height * 0.018),
                                  child: _AddressCard(
                                    address: address,
                                    isSelected: isSelected,
                                    onTap: () => setState(() => _selectedAddressId = address.id),
                                    onEdit: () => _onEditAddress(address),
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
                                          border: Border.all(
                                              color: ColorConstant.primaryColor, width: 1.6),
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
                          onTap: addresses.isEmpty ? null : () => _onContinue(addresses),
                          color: ColorConstant.primaryColor,
                          icon: Icons.arrow_forward,
                          iconColor: ColorConstant.whiteColor,
                        ),
                      ),
                    ],
                  );
                },
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

/// ---------------- SAVED ADDRESS CARD (real AddressModel) ----------------
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

  IconData get _typeIcon =>
      address.type == 'BILLING' ? Icons.receipt_long_rounded : Icons.local_shipping_rounded;

  String get _typeLabel => address.type == 'BILLING' ? 'Billing Address' : 'Shipping Address';

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
              child: Icon(_typeIcon, size: 19, color: ColorConstant.primaryColor),
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
                          text: _typeLabel,
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
                    text: address.fullAddress,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
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

/// ---------------- SKELETON (matches SelectAddressScreen style) ----------------
class _AddressListSkeleton extends StatelessWidget {
  final Size size;
  const _AddressListSkeleton({required this.size});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(14)),
          SizedBox(height: size.height * 0.02),
          SkeletonBox(width: double.infinity, height: 72, borderRadius: BorderRadius.circular(16)),
          SizedBox(height: size.height * 0.03),
          SkeletonBox(width: 130, height: 16, borderRadius: BorderRadius.circular(4)),
          SizedBox(height: size.height * 0.015),
          for (int i = 0; i < 2; i++) ...[
            SkeletonBox(width: double.infinity, height: 110, borderRadius: BorderRadius.circular(16)),
            SizedBox(height: size.height * 0.018),
          ],
        ],
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