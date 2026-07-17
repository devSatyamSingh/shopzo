import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

/// Shopzo — Order Details Screen.
/// Matches the approved Figma design: order header with status badge,
/// a vertical delivery-status timeline, a live-tracking map preview
/// (only shown while out for delivery), delivery address, order items
/// (with a per-item rating row), payment/bill summary, action buttons,
/// and a related-products strip. No bottom nav — pushed on top of the
/// Orders list screen.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  // ---- Dummy data — replace with real data from your ViewModel/repo ----
  static const String _orderId = "SHZ48291";
  static const String _placedDate = "Placed on 12 July 2026";
  static const String _statusBadge = "In Transit";

  static const List<_TimelineStep> _timeline = [
    _TimelineStep(title: "Order Placed", timestamp: "12 July, 10:30 AM", status: _StepStatus.completed),
    _TimelineStep(title: "Confirmed", timestamp: "12 July, 11:15 AM", status: _StepStatus.completed),
    _TimelineStep(title: "Packed", timestamp: "13 July, 09:00 AM", status: _StepStatus.completed),
    _TimelineStep(title: "Out for Delivery", timestamp: "14 July, 08:30 AM", status: _StepStatus.current),
    _TimelineStep(title: "Delivered", timestamp: "Expected by 14 July, 06:00 PM", status: _StepStatus.upcoming),
  ];

  static const bool _isOutForDelivery = true; // controls map-preview visibility

  static const List<_OrderProduct> _items = [
    _OrderProduct(
      image: "assets/images/pro2.jpg",
      name: "SwiftRun Pro X1",
      price: 1999,
      variant: "Size: 9 | Color: Midnight Black",
      qty: 1,
      showRating: true,
    ),
    _OrderProduct(
      image: "assets/images/pro2.jpg",
      name: "Essential Cotton Tee",
      price: 500,
      variant: "Size: L | Color: Heather Gray",
      qty: 1,
      showRating: false,
    ),
  ];

  static const List<_RelatedProduct> _related = [
    _RelatedProduct(
      image: "assets/images/pro4.jpg",
      name: "FitBand 5 Pro",
      price: 3499,
    ),
    _RelatedProduct(
      image: "assets/images/pro8.jpg",
      name: "SoundWave Buds",
      price: 1899,
    ),
  ];

  double get _itemTotal => 2499;
  double get _deliveryFee => 0;
  double get _discount => 120;
  double get _totalPaid => _itemTotal - _discount + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.016),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrderIdRow(size),
                    SizedBox(height: size.height * 0.02),
                    _buildDeliveryStatusCard(size),
                    SizedBox(height: size.height * 0.018),
                    _buildAddressCard(size),
                    SizedBox(height: size.height * 0.018),
                    _buildItemsCard(size),
                    SizedBox(height: size.height * 0.018),
                    _buildPaymentCard(size),
                    SizedBox(height: size.height * 0.02),
                    _buildActionButtons(size),
                    SizedBox(height: size.height * 0.024),
                    _buildRelatedProducts(size),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.fromLTRB(size.width * 0.03, size.height * 0.012, size.width * 0.045, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded, color: ColorConstant.headlineTextColor, size: 22),
            ),
          ),
          const Expanded(
            child: TextContext(
              text: "Order Details",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ),
          InkWell(
            onTap: () {
              // TODO: open more-actions menu (report issue, help, etc.)
            },
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.more_vert_rounded, color: ColorConstant.headlineTextColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- ORDER ID ROW ----------------
  Widget _buildOrderIdRow(Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextContext(text: "Order #$_orderId", fontSize: 15, fontWeight: FontWeight.w600),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_rounded, size: 15, color: ColorConstant.placeholderColor),
                ],
              ),
              const SizedBox(height: 3),
              const TextContext(
                text: _placedDate,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColorConstant.infoColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            _statusBadge,
            style: TextStyle(
              color: ColorConstant.infoColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
        ),
      ],
    );
  }

  /// ---------------- DELIVERY STATUS TIMELINE CARD ----------------
  Widget _buildDeliveryStatusCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextContext(text: "Delivery Status", fontSize: 15, fontWeight: FontWeight.w600),
          SizedBox(height: size.height * 0.018),
          for (int i = 0; i < _timeline.length; i++)
            _buildTimelineTile(_timeline[i], isLast: i == _timeline.length - 1),
          if (_isOutForDelivery) ...[
            SizedBox(height: size.height * 0.016),
            _buildLiveTrackingMap(size),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineTile(_TimelineStep step, {required bool isLast}) {
    final bool isCompleted = step.status == _StepStatus.completed;
    final bool isCurrent = step.status == _StepStatus.current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _buildStepCircle(step.status),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? ColorConstant.primaryColor : ColorConstant.borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: step.title,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (isCompleted || isCurrent)
                        ? ColorConstant.headlineTextColor
                        : ColorConstant.placeholderColor,
                  ),
                  const SizedBox(height: 2),
                  TextContext(
                    text: step.timestamp,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(_StepStatus status) {
    switch (status) {
      case _StepStatus.completed:
        return Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(color: ColorConstant.primaryColor, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
        );
      case _StepStatus.current:
        return Container(
          height: 24,
          width: 24,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(color: ColorConstant.primaryColor, shape: BoxShape.circle),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        );
      case _StepStatus.upcoming:
        return Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorConstant.borderColor, width: 2),
          ),
        );
    }
  }

  Widget _buildLiveTrackingMap(Size size) {
    final double mapHeight = size.height * 0.16;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: mapHeight,
        width: double.infinity,
        color: const Color(0xFFE4EAF3),
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.map_rounded, size: mapHeight * 0.55, color: ColorConstant.placeholderColor.withOpacity(0.35)),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: ColorConstant.infoColor, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 6),
                    SizedBox(width: 5),
                    Text("Live Tracking",
                        style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600, fontFamily: "Poppins")),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 15, color: ColorConstant.primaryColor),
                    SizedBox(width: 6),
                    Text("3.2 km away",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: "Poppins")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- DELIVERY ADDRESS CARD ----------------
  Widget _buildAddressCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(color: ColorConstant.primaryLight, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.location_on_rounded, color: ColorConstant.primaryColor, size: 18),
          ),
          SizedBox(width: size.width * 0.03),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: "DELIVER TO",
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: ColorConstant.placeholderColor,
                ),
                SizedBox(height: 4),
                TextContext(text: "Arjun Malhotra", fontSize: 14, fontWeight: FontWeight.w600),
                SizedBox(height: 3),
                TextContext(
                  text: "402, Skyline Residency, 12th Main Road,\nIndiranagar, Bengaluru, Karnataka - 560038",
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                  height: 1.5,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.call_rounded, size: 13, color: ColorConstant.labelTextColor),
                    SizedBox(width: 6),
                    TextContext(
                      text: "+91 98765 43210",
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- ORDER ITEMS CARD ----------------
  Widget _buildItemsCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextContext(text: "Order Items (${_items.length})", fontSize: 14, fontWeight: FontWeight.w600),
          SizedBox(height: size.height * 0.016),
          for (int i = 0; i < _items.length; i++) ...[
            buildOrderProductRow(size, _items[i]),
            if (i != _items.length - 1) ...[
              SizedBox(height: size.height * 0.014),
              const Divider(height: 1, color: ColorConstant.dividerColor),
              SizedBox(height: size.height * 0.014),
            ],
          ],
        ],
      ),
    );
  }

  Widget buildOrderProductRow(Size size, _OrderProduct item) {
    final double thumbSize = (size.width * 0.16).clamp(50.0, 70.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: thumbSize,
          width: thumbSize,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ColorConstant.fieldFillColor,
          ),
          child: Image.asset(
            item.image,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: size.width * 0.035),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextContext(
                      text: item.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextContext(
                    text: "₹${item.price.toStringAsFixed(0)}",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              TextContext(
                text: item.variant,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
              ),
              const SizedBox(height: 2),
              TextContext(
                text: "Qty: ${item.qty}",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
              ),
              if (item.showRating) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const TextContext(
                      text: "Rate this:",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                    const SizedBox(width: 6),
                    ...List.generate(
                      5,
                          (i) => const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Icon(Icons.star_border_rounded, size: 16, color: ColorConstant.ratingStarColor),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// ---------------- PAYMENT CARD ----------------
  Widget _buildPaymentCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card_rounded, size: 18, color: ColorConstant.primaryColor),
              SizedBox(width: 8),
              TextContext(text: "Paid via UPI (Google Pay)", fontSize: 14, fontWeight: FontWeight.w600),
            ],
          ),
          SizedBox(height: size.height * 0.016),
          _billRow("Item Total", "₹${_itemTotal.toStringAsFixed(0)}"),
          SizedBox(height: size.height * 0.01),
          _billRow("Delivery Fee", _deliveryFee == 0 ? "FREE" : "₹${_deliveryFee.toStringAsFixed(0)}",
              valueColor: _deliveryFee == 0 ? ColorConstant.successColor : null),
          SizedBox(height: size.height * 0.01),
          _billRow("Discount", "-₹${_discount.toStringAsFixed(0)}", valueColor: ColorConstant.successColor),
          SizedBox(height: size.height * 0.014),
          const Divider(height: 1, color: ColorConstant.dividerColor),
          SizedBox(height: size.height * 0.014),
          _billRow("Total Paid", "₹${_totalPaid.toStringAsFixed(0)}", bold: true, valueColor: ColorConstant.primaryColor),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextContext(
          text: label,
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: bold ? ColorConstant.headlineTextColor : ColorConstant.labelTextColor,
        ),
        TextContext(
          text: value,
          fontSize: bold ? 16.5 : 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          color: valueColor ?? ColorConstant.headlineTextColor,
        ),
      ],
    );
  }

  /// ---------------- ACTION BUTTONS ----------------
  Widget _buildActionButtons(Size size) {
    return Column(
      children: [
        CustomButton(
          text: "Track Order",
          width: double.infinity,
          height: 52,
          icon: Icons.map_rounded,
          iconSize: 18,
          onTap: () {
            // TODO: navigate to RouteName.orderTracking
          },
        ),
        SizedBox(height: size.height * 0.012),
        CustomButton(
          text: "Cancel Order",
          width: double.infinity,
          height: 52,
          outlined: true,
          borderColor: ColorConstant.errorColor,
          textColor: ColorConstant.errorColor,
          icon: Icons.cancel_outlined,
          iconColor: ColorConstant.errorColor,
          iconSize: 18,
          onTap: () {
            // TODO: show cancel-order confirmation
          },
        ),
        SizedBox(height: size.height * 0.016),
        InkWell(
          onTap: () {
            // TODO: download/open invoice PDF
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_rounded, size: 16, color: ColorConstant.primaryColor),
              SizedBox(width: 6),
              TextContext(
                text: "Download Invoice",
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: ColorConstant.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ---------------- RELATED PRODUCTS ----------------
  Widget _buildRelatedProducts(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextContext(text: "You may also like", fontSize: 15, fontWeight: FontWeight.w600),
            InkWell(
              onTap: () {
                // TODO: navigate to related products listing
              },
              child: const TextContext(
                text: "View All",
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorConstant.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.016),
        SizedBox(
          height: size.height * 0.24,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _related.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.035),
            itemBuilder: (context, index) => buildRelatedProductCard(size, _related[index]),
          ),
        ),
      ],
    );
  }

  Widget buildRelatedProductCard(Size size, _RelatedProduct item) {
    final double cardWidth = size.width * 0.62;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: ColorConstant.blackColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.asset(
                item.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(text: item.name, fontSize: 13.5, fontWeight: FontWeight.w500),
                const SizedBox(height: 3),
                TextContext(
                  text: "₹${item.price.toStringAsFixed(0)}",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Local models — move to lib/model/ once wired to a real API.
/// ------------------------------------------------------------
enum _StepStatus { completed, current, upcoming }

class _TimelineStep {
  final String title;
  final String timestamp;
  final _StepStatus status;

  const _TimelineStep({required this.title, required this.timestamp, required this.status});
}

class _OrderProduct {
  final String image;
  final String name;
  final double price;
  final String variant;
  final int qty;
  final bool showRating;

  const _OrderProduct({
    required this.image,
    required this.name,
    required this.price,
    required this.variant,
    required this.qty,
    required this.showRating,
  });
}

class _RelatedProduct {
  final String image;
  final String name;
  final double price;

  const _RelatedProduct({
    required this.image,
    required this.name,
    required this.price,
  });
}