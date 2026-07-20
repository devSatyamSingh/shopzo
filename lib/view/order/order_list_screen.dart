import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import 'order_deatils_screen.dart';

/// Shopzo — My Orders (Order List) Screen.
/// Matches the approved Figma design: header, status filter chips,
/// order cards (with status-specific dot/color, progress bar for
/// active deliveries, "+N more" thumbnail overlay for multi-item
/// orders, and status-specific action buttons), and an end-of-list
/// "Start Shopping" nudge. No bottom nav — this screen is meant to be
/// pushed on top of whatever tab the user is on.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = const ["All", "Processing", "Shipped", "Delivered"];

  // ---- Dummy data — replace with real data from your ViewModel/repo ----
  final List<_OrderItem> _orders = [
    _OrderItem(
      image: "assets/images/pro1.jpg",
      orderId: "SHZ90210",
      date: "Today",
      itemCount: 1,
      amount: 1299,
      status: _OrderStatus.outForDelivery,
      progress: 0.68,
    ),
    _OrderItem(
      image: "assets/images/pro2.jpg",
      orderId: "SHZ48291",
      date: "10 July 2026",
      itemCount: 3,
      amount: 2384,
      status: _OrderStatus.delivered,
      extraItemsCount: 2,
    ),
    _OrderItem(
      image: "assets/images/pro3.jpg",
      orderId: "SHZ77301",
      date: "11 July 2026",
      itemCount: 1,
      amount: 899,
      status: _OrderStatus.processing,
    ),
    _OrderItem(
      image: "assets/images/pro1.jpg",
      orderId: "SHZ11204",
      date: "05 July 2026",
      itemCount: 1,
      amount: 450,
      status: _OrderStatus.cancelled,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            SizedBox(height: size.height * 0.016),
            _buildFilterTabs(size),
            SizedBox(height: size.height * 0.018),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final order in _orders) ...[
                      buildOrderCard(context, size, order),
                      SizedBox(height: size.height * 0.018),
                    ],
                    SizedBox(height: size.height * 0.01),
                    _buildEndOfListFooter(size),
                    SizedBox(height: size.height * 0.03),
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
      padding: EdgeInsets.fromLTRB(
        size.width * 0.03,
        size.height * 0.012,
        size.width * 0.045,
        0,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded, color: ColorConstant.primaryDark, size: 22),
            ),
          ),
          const Expanded(
            child: TextContext(
              text: "Orders",
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ColorConstant.primaryDark,
              textAlign: TextAlign.center,
            ),
          ),
          // InkWell(
          //   onTap: () {
          //     // TODO: navigate to order search
          //   },
          //   borderRadius: BorderRadius.circular(10),
          //   child: const Padding(
          //     padding: EdgeInsets.all(6),
          //     child: Icon(Icons.search_rounded, color: ColorConstant.primaryDark, size: 22),
          //   ),
          // ),
        ],
      ),
    );
  }

  /// ---------------- FILTER TABS ----------------
  Widget _buildFilterTabs(Size size) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: size.width * 0.025),
        itemBuilder: (context, index) {
          final bool isSelected = index == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? ColorConstant.primaryColor : ColorConstant.whiteColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                ),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                  color: isSelected ? Colors.white : ColorConstant.headlineTextColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget buildOrderCard(BuildContext context, Size size, _OrderItem order) {
    final config = _statusConfig(order.status);
    final double thumbSize = (size.width * 0.19).clamp(58.0, 84.0);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(context, RouteName.orderDetail);
      },
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Status + date row ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(color: config.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      config.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                        color: config.color,
                      ),
                    ),
                  ],
                ),
                TextContext(
                  text: order.date,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ],
            ),
      
            SizedBox(height: size.height * 0.014),
      
            // ---- Thumbnail + order info ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      height: thumbSize,
                      width: thumbSize,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: ColorConstant.fieldFillColor,
                      ),
                      child: Image.asset(
                        order.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (order.extraItemsCount != null)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "+${order.extraItemsCount} more",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                  ],
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
                              text: "Order #${order.orderId}",
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: ColorConstant.placeholderColor, size: 20),
                        ],
                      ),
                      const SizedBox(height: 3),
                      TextContext(
                        text: "${order.itemCount} item${order.itemCount > 1 ? 's' : ''} • ₹${order.amount.toStringAsFixed(0)}",
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      
            // ---- Progress bar (only for out-for-delivery) ----
            if (order.progress != null) ...[
              SizedBox(height: size.height * 0.016),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: order.progress,
                  minHeight: 6,
                  backgroundColor: ColorConstant.primaryLight,
                  valueColor: const AlwaysStoppedAnimation(ColorConstant.primaryColor),
                ),
              ),
            ],
      
            SizedBox(height: size.height * 0.016),
      
            // ---- Action buttons (status-specific) ----
            _buildActionRow(order.status),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(_OrderStatus status) {
    switch (status) {
      case _OrderStatus.outForDelivery:
      case _OrderStatus.processing:
        return Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            text: "Track Order",
            outlined: true,
            width: 140,
            height: 40,
            fontSize: 13,
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              // TODO: navigate to RouteName.orderTracking
            },
          ),
        );

      case _OrderStatus.delivered:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              text: "Rate & Review",
              outlined: true,
              width: 130,
              height: 40,
              fontSize: 12.5,
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                // TODO: open rate & review sheet
              },
            ),
            const SizedBox(width: 10),
            CustomButton(
              text: "Buy Again",
              width: 110,
              height: 40,
              fontSize: 12.5,
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                // TODO: re-add items to cart
              },
            ),
          ],
        );

      case _OrderStatus.cancelled:
        return Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            text: "Buy Again",
            width: 130,
            height: 40,
            fontSize: 13,
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              // TODO: re-add items to cart
            },
          ),
        );
    }
  }

  _StatusConfig _statusConfig(_OrderStatus status) {
    switch (status) {
      case _OrderStatus.outForDelivery:
        return const _StatusConfig(label: "Out for Delivery", color: ColorConstant.primaryColor);
      case _OrderStatus.delivered:
        return const _StatusConfig(label: "Delivered", color: ColorConstant.successColor);
      case _OrderStatus.processing:
        return const _StatusConfig(label: "Processing", color: ColorConstant.orangeColor);
      case _OrderStatus.cancelled:
        return const _StatusConfig(label: "Cancelled", color: ColorConstant.errorColor);
    }
  }

  /// ---------------- END OF LIST FOOTER ----------------
  Widget _buildEndOfListFooter(Size size) {
    return Column(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: const BoxDecoration(
            color: ColorConstant.primaryLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.shopping_basket_outlined, color: ColorConstant.primaryColor, size: 28),
        ),
        SizedBox(height: size.height * 0.018),
        const TextContext(
          text: "No more orders to show",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorConstant.labelTextColor,
        ),
        SizedBox(height: size.height * 0.02),
        CustomButton(
          text: "Start Shopping",
          width: size.width * 0.55,
          height: 48,
          icon: Icons.arrow_forward_rounded,
          iconSize: 18,
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            // TODO: navigate to RouteName.home
          },
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// Local models — move to lib/model/order_model.dart once wired
/// to a real API.
/// ------------------------------------------------------------
enum _OrderStatus { outForDelivery, delivered, processing, cancelled }

class _OrderItem {
  final String image;  final String orderId;
  final String date;
  final int itemCount;
  final double amount;
  final _OrderStatus status;
  final double? progress; // 0.0 - 1.0, only set for active out-for-delivery orders
  final int? extraItemsCount; // e.g. 2 -> shows "+2 more" over the thumbnail

  const _OrderItem({
    required this.image,
    required this.orderId,
    required this.date,
    required this.itemCount,
    required this.amount,
    required this.status,
    this.progress,
    this.extraItemsCount,
  });
}

class _StatusConfig {
  final String label;
  final Color color;

  const _StatusConfig({required this.label, required this.color});
}