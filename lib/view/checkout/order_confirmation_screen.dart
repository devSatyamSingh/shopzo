import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../model/order/order_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;
  const OrderConfirmationScreen({super.key, required this.order});

  String get _estimatedDelivery {
    final base = order.createdAt ?? DateTime.now();
    final delivery = base.add(const Duration(days: 5));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${days[delivery.weekday - 1]}, ${months[delivery.month - 1]} ${delivery.day}";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final address = order.address;
    context.watch<LanguageProvider>();


    return PopScope(
      canPop: false, // order place hone ke baad back se checkout pe wapas na jaaye
      child: Scaffold(
        backgroundColor: ColorConstant.whiteColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.02),
                      _buildSuccessIcon(size),
                      SizedBox(height: size.height * 0.03),
                      TextContext(
                        text: "Order Confirmed!",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ColorConstant.headlineTextColor,
                      ),
                      SizedBox(height: size.height * 0.008),
                      TextContext(
                        text: "Thank you! Your order has been placed\nand is being prepared.",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                        textAlign: TextAlign.center,
                        height: 1.5,
                      ),
                      SizedBox(height: size.height * 0.02),

                      // ---------------- ORDER ID CHIP ----------------
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: ColorConstant.primaryLight,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TextContext(text: "ORDER ID: ", fontSize: 11.5, fontWeight: FontWeight.w600, color: ColorConstant.labelTextColor),
                            TextContext(text: order.orderNumber, fontSize: 12.5, fontWeight: FontWeight.w700, color: ColorConstant.primaryColor),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // ---------------- DELIVERY CARD ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstant.scaffoldBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 42, width: 42,
                              decoration: const BoxDecoration(color: ColorConstant.whiteColor, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Icon(Icons.local_shipping_rounded, color: ColorConstant.primaryColor, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextContext(text: "Estimated Delivery", fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                                const SizedBox(height: 2),
                                TextContext(text: _estimatedDelivery, fontSize: 15, fontWeight: FontWeight.w700, color: ColorConstant.headlineTextColor),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // ---------------- ORDER SUMMARY CARD ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstant.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColorConstant.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextContext(text: "Order Summary", fontSize: 13.5, fontWeight: FontWeight.w600, color: ColorConstant.headlineTextColor),
                            SizedBox(height: size.height * 0.014),
                            Row(
                              children: [
                                _buildThumbnailStack(order),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextContext(
                                    text: "${order.itemCount} item${order.itemCount > 1 ? 's' : ''}",
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstant.labelTextColor,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextContext(text: AppUtils.formatCurrency(order.total), fontSize: 16, fontWeight: FontWeight.w700, color: ColorConstant.headlineTextColor),
                                    TextContext(text: "${order.itemCount} Item${order.itemCount > 1 ? 's' : ''} Total", fontSize: 10.5, fontWeight: FontWeight.w400, color: ColorConstant.placeholderColor),
                                  ],
                                ),
                              ],
                            ),
                            if (address != null) ...[
                              SizedBox(height: size.height * 0.016),
                              const Divider(color: ColorConstant.dividerColor, height: 1),
                              SizedBox(height: size.height * 0.016),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 17, color: ColorConstant.placeholderColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const TextContext(text: "Shipping to", fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                                        const SizedBox(height: 2),
                                        TextContext(
                                          text: "${address.line1}${(address.line2 != null && address.line2!.isNotEmpty) ? ', ${address.line2}' : ''}, ${address.city}, ${address.state} ${address.postalCode}",
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstant.headlineTextColor,
                                          height: 1.4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),

              // ---------------- BOTTOM ACTIONS ----------------
              Padding(
                padding: EdgeInsets.fromLTRB(size.width * 0.06, 0, size.width * 0.06, size.height * 0.02),
                child: Column(
                  children: [
                    CustomButton(
                      text: "View Orders",
                      width: double.infinity,
                      height: 54,
                      icon: Icons.arrow_forward_rounded,
                      iconColor: ColorConstant.whiteColor,
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, RouteName.mainWrapper, (r) => false);
                        Navigator.pushNamed(context, RouteName.orderDetail, arguments: order.id);
                      },
                    ),
                    SizedBox(height: size.height * 0.016),
                    InkWell(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, RouteName.mainWrapper, (r) => false),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: TextContext(
                          text: "Continue Shopping",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: "Shop", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.w800, color: ColorConstant.primaryColor)),
                TextSpan(text: "zo", style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.w800, color: ColorConstant.orangeColor)),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, RouteName.mainWrapper, (r) => false),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.close_rounded, color: ColorConstant.labelTextColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon(Size size) {
    final double dia = size.width * 0.34;
    return SizedBox(
      height: dia,
      width: dia,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: dia,
            width: dia,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [ColorConstant.primaryColor.withOpacity(0.14), ColorConstant.primaryColor.withOpacity(0.03)],
              ),
            ),
          ),
          Container(
            height: dia * 0.66,
            width: dia * 0.66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ColorConstant.primaryGradient,
              boxShadow: [
                BoxShadow(color: ColorConstant.primaryColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check_rounded, color: Colors.white, size: dia * 0.34),
          ),
          Positioned(top: dia * 0.02, right: dia * 0.05, child: Icon(Icons.star_rounded, color: ColorConstant.orangeColor.withOpacity(0.7), size: dia * 0.1)),
          Positioned(bottom: dia * 0.08, left: 0, child: Icon(Icons.circle, color: ColorConstant.primaryColor.withOpacity(0.25), size: dia * 0.07)),
        ],
      ),
    );
  }

  Widget _buildThumbnailStack(OrderModel order) {
    final images = order.orderItems.map((e) => e.displayImage).where((e) => e != null).take(3).toList();
    if (images.isEmpty) {
      return Container(
        height: 44, width: 44,
        decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: const Icon(Icons.shopping_bag_outlined, color: ColorConstant.placeholderColor, size: 18),
      );
    }
    return SizedBox(
      width: 44 + ((images.length - 1) * 16.0),
      height: 44,
      child: Stack(
        children: [
          for (int i = 0; i < images.length; i++)
            Positioned(
              left: i * 16.0,
              child: Container(
                height: 44, width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorConstant.whiteColor, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  images[i]!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: ColorConstant.fieldFillColor, child: const Icon(Icons.image_outlined, size: 16, color: ColorConstant.placeholderColor)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}