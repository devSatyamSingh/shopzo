import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/order_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../viewmodel/orderlist_viewmodel.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = const ["All", "Processing", "Shipped", "Delivered"];

  OrderStatus? _statusForTab(int index) {
    switch (index) {
      case 1:
        return OrderStatus.processing;
      case 2:
        return OrderStatus.pending;
      case 3:
        return OrderStatus.completed;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchOrders();
    });
  }

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
              child: Consumer<OrderViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading && !vm.hasLoadedOnce) {
                    return const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor));
                  }

                  if (vm.errorMessage != null && vm.orders.isEmpty) {
                    return _buildErrorState(size, vm.errorMessage!, () => vm.fetchOrders());
                  }

                  final orders = vm.ordersByStatus(_statusForTab(_selectedFilter));

                  if (orders.isEmpty) {
                    return _buildEmptyState(size);
                  }

                  return RefreshIndicator(
                    color: ColorConstant.primaryColor,
                    onRefresh: () => vm.fetchOrders(showLoader: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final order in orders) ...[
                            buildOrderCard(context, size, order),
                            SizedBox(height: size.height * 0.018),
                          ],
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          const SizedBox(width: 34), // symmetry ke liye (back-icon jitna space)
        ],
      ),
    );
  }

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
                border: Border.all(color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor),
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

  Widget buildOrderCard(BuildContext context, Size size, OrderModel order) {
    final config = _statusConfig(order.status);
    final double thumbSize = (size.width * 0.19).clamp(58.0, 84.0);
    final extraCount = order.itemCount > 1 ? order.itemCount - 1 : null;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pushNamed(context, RouteName.orderDetail, arguments: order.id),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(height: 8, width: 8, decoration: BoxDecoration(color: config.color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(config.label,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, fontFamily: "Poppins", color: config.color)),
                  ],
                ),
                TextContext(
                  text: order.createdAt != null ? _formatDate(order.createdAt!) : '',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.014),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      height: thumbSize,
                      width: thumbSize,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: ColorConstant.fieldFillColor),
                      child: order.firstItemImage != null
                          ? Image.network(
                        order.firstItemImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported_outlined, color: ColorConstant.placeholderColor),
                        loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                      )
                          : const Icon(Icons.image_outlined, color: ColorConstant.placeholderColor),
                    ),
                    if (extraCount != null)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(14)),
                          alignment: Alignment.center,
                          child: Text("+$extraCount more",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600, fontFamily: "Poppins")),
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
                            child: TextContext(text: "Order #${order.orderNumber}", fontSize: 15, fontWeight: FontWeight.w500, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: ColorConstant.placeholderColor, size: 20),
                        ],
                      ),
                      const SizedBox(height: 3),
                      TextContext(
                        text: "${order.itemCount} item${order.itemCount > 1 ? 's' : ''} • ₹${order.total.toStringAsFixed(0)}",
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.016),
            Align(alignment: Alignment.centerRight, child: _buildActionButton(context, order)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, OrderModel order) {
    if (order.status == OrderStatus.completed) {
      return CustomButton(
        text: "View Details",
        outlined: true,
        width: 140,
        height: 40,
        fontSize: 13,
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.pushNamed(context, RouteName.orderDetail, arguments: order.id),
      );
    }
    if (order.canCancel) {
      return CustomButton(
        text: "Track / Cancel",
        outlined: true,
        width: 150,
        height: 40,
        fontSize: 12.5,
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.pushNamed(context, RouteName.orderDetail, arguments: order.id),
      );
    }
    return CustomButton(
      text: "View Details",
      width: 140,
      height: 40,
      fontSize: 13,
      borderRadius: BorderRadius.circular(30),
      onTap: () => Navigator.pushNamed(context, RouteName.orderDetail, arguments: order.id),
    );
  }

  _StatusConfig _statusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const _StatusConfig(label: "Pending", color: ColorConstant.orangeColor);
      case OrderStatus.processing:
        return const _StatusConfig(label: "Processing", color: ColorConstant.infoColor);
      case OrderStatus.completed:
        return const _StatusConfig(label: "Delivered", color: ColorConstant.successColor);
      case OrderStatus.cancelled:
        return const _StatusConfig(label: "Cancelled", color: ColorConstant.errorColor);
      case OrderStatus.refunded:
        return const _StatusConfig(label: "Refunded", color: ColorConstant.errorColor);
      case OrderStatus.unknown:
        return const _StatusConfig(label: "Processing", color: ColorConstant.labelTextColor);
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 64, width: 64,
            decoration: const BoxDecoration(color: ColorConstant.primaryLight, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.shopping_basket_outlined, color: ColorConstant.primaryColor, size: 28),
          ),
          SizedBox(height: size.height * 0.018),
          const TextContext(text: "No orders yet", fontSize: 14, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor),
          SizedBox(height: size.height * 0.02),
          CustomButton(
            text: "Start Shopping",
            width: size.width * 0.55,
            height: 48,
            icon: Icons.arrow_forward_rounded,
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Size size, String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: ColorConstant.errorColor, size: 40),
            SizedBox(height: size.height * 0.012),
            TextContext(text: message, fontSize: 13, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor, textAlign: TextAlign.center),
            SizedBox(height: size.height * 0.02),
            CustomButton(text: "Retry", width: 140, height: 44, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  const _StatusConfig({required this.label, required this.color});
}