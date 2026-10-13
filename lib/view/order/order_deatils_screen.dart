import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/view/order/return_form_bottomsheet.dart';
import 'package:shopzo/view/order/review_rating_screen.dart';
import '../../localization/language_provider.dart';
import '../../model/order/order_model.dart';
import '../../model/order/return_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../viewmodel/orderview/order_details_viewmodel.dart';
import '../../viewmodel/orderview/orderlist_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderDetailViewModel>().fetchOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    return const _OrderDetailView();
  }
}

class _OrderDetailView extends StatefulWidget {
  const _OrderDetailView();

  @override
  State<_OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<_OrderDetailView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Consumer<OrderDetailViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody(context, size, vm)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 16, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.arrow_back_rounded,
                color: ColorConstant.headlineTextColor,
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: TextContext(
              text: 'orders.order_details'.tr(),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, Size size, OrderDetailViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorConstant.primaryColor),
      );
    }

    if (vm.status == OrderDetailStatus.error || vm.order == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: ColorConstant.errorColor,
                size: 40,
              ),
              SizedBox(height: size.height * 0.012),
              TextContext(
                text: vm.errorMessage ?? 'Something went wrong',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ColorConstant.labelTextColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.02),
              CustomButton(
                text: "Retry",
                width: 140,
                height: 44,
                onTap: () => vm.fetchOrder(vm.orderId!),
              ),
            ],
          ),
        ),
      );
    }

    final order = vm.order!;

    return RefreshIndicator(
      color: ColorConstant.primaryColor,
      onRefresh: () => vm.fetchOrder(order.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: size.height * 0.016,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrderIdRow(size, order),
            SizedBox(height: size.height * 0.02),
            _buildStatusCard(size, order),
            SizedBox(height: size.height * 0.018),
            if (order.address != null) ...[
              _buildAddressCard(size, order),
              SizedBox(height: size.height * 0.018),
            ],
            _buildItemsCard(context, size, order, vm),
            SizedBox(height: size.height * 0.018),
            _buildPaymentCard(size, order),
            SizedBox(height: size.height * 0.02),
            _buildActionButtons(context, size, order),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderIdRow(Size size, OrderModel order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextContext(
                text: '${'orders.order'.tr()} #${order.orderNumber}',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 3),
              TextContext(
                text: order.createdAt != null
                    ? "Placed on ${_formatDate(order.createdAt!)}"
                    : '',
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
            color: _statusColor(order.status).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusLabel(order),
            style: TextStyle(
              color: _statusColor(order.status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(Size size, OrderModel order) {
    final steps = _buildTimelineSteps(order.status);
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextContext(
            text: 'orders.order_status'.tr(),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: size.height * 0.018),
          for (int i = 0; i < steps.length; i++)
            _buildTimelineTile(steps[i], isLast: i == steps.length - 1),
        ],
      ),
    );
  }

  List<_Step> _buildTimelineSteps(OrderStatus status) {
    if (status == OrderStatus.cancelled) {
      return [
        _Step('orders.timeline.order_placed'.tr(), _StepState.done),
        _Step('orders.timeline.cancelled'.tr(), _StepState.current),
      ];
    }
    if (status == OrderStatus.refunded) {
      return [
        _Step('orders.timeline.order_placed'.tr(), _StepState.done),
        _Step('orders.timeline.refund_initiated'.tr(), _StepState.done),
        _Step('orders.timeline.refunded'.tr(), _StepState.current),
      ];
    }
    final order = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.completed,
    ];
    final idx = order.indexOf(status);
    return [
      _Step(
        'orders.timeline.order_placed'.tr(),
        idx >= 0 ? _StepState.done : _StepState.upcoming,
      ),
      _Step(
        'orders.timeline.processing'.tr(),
        idx >= 1
            ? _StepState.done
            : (idx == 0 ? _StepState.current : _StepState.upcoming),
      ),
      _Step(
        'orders.timeline.delivered'.tr(),
        idx >= 2
            ? _StepState.done
            : (idx == 1 ? _StepState.current : _StepState.upcoming),
      ),
    ];
  }

  Widget _buildTimelineTile(_Step step, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _buildStepCircle(step.state),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.state == _StepState.done
                        ? ColorConstant.primaryColor
                        : ColorConstant.borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: TextContext(
                text: step.title,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: step.state == _StepState.upcoming
                    ? ColorConstant.placeholderColor
                    : ColorConstant.headlineTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(_StepState state) {
    switch (state) {
      case _StepState.done:
        return Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: ColorConstant.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
        );
      case _StepState.current:
        return Container(
          height: 24,
          width: 24,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: ColorConstant.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      case _StepState.upcoming:
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

  Widget _buildAddressCard(Size size, OrderModel order) {
    final address = order.address!;
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: ColorConstant.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_rounded,
              color: ColorConstant.primaryColor,
              size: 18,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: 'orders.deliver_to'.tr(),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: ColorConstant.placeholderColor,
                ),
                const SizedBox(height: 4),
                TextContext(
                  text:
                  "${address.line1}${(address.line2 != null && address.line2!.isNotEmpty) ? ', ${address.line2}' : ''}\n${address.city}, ${address.state} - ${address.postalCode}",
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                  height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(
      BuildContext context,
      Size size,
      OrderModel order,
      OrderDetailViewModel vm,
      ) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextContext(
            text: '${'orders.order_items'.tr()} (${order.itemCount})',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: size.height * 0.016),
          for (int i = 0; i < order.orderItems.length; i++) ...[
            _buildItemRow(
              context,
              size,
              order.orderItems[i],
              order.canReview,
              vm.returnsByOrderItem[order.orderItems[i].id],
              vm,
            ),
            if (i != order.orderItems.length - 1) ...[
              SizedBox(height: size.height * 0.014),
              const Divider(height: 1, color: ColorConstant.dividerColor),
              SizedBox(height: size.height * 0.014),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(
      BuildContext context,
      Size size,
      OrderItemModel item,
      bool canReview,
      ReturnModel? existingReturn,
      OrderDetailViewModel detailVm,
      ) {
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
          child: item.displayImage != null
              ? Image.network(
            item.displayImage!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              color: ColorConstant.placeholderColor,
            ),
          )
              : const Icon(
            Icons.image_outlined,
            color: ColorConstant.placeholderColor,
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
                      text: item.displayName,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextContext(
                    text: "₹${item.subtotal.toStringAsFixed(0)}",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              TextContext(
                text: 'orders.quantity'.tr(
                  args: [item.quantity.toString()],
                ),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
              ),
              if (canReview) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    InkWell(
                      onTap: () => showReviewBottomSheet(
                        context,
                        productId: item.productId,
                        productName: item.displayName,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_border_rounded,
                            size: 16,
                            color: ColorConstant.ratingStarColor,
                          ),
                          const SizedBox(width: 4),
                          TextContext(
                            text: 'orders.review.rate_review'.tr(),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.primaryColor,
                          ),
                        ],
                      ),
                    ),

                    // ---- Return/Exchange: already requested -> Track, else -> new form ----
                    if (existingReturn == null)
                      InkWell(
                        onTap: () => showReturnFormBottomSheet(
                          context,
                          item: item,
                          onSuccess: () {
                            if (detailVm.orderId != null) {
                              detailVm.fetchOrder(detailVm.orderId!);
                            }
                          },
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard_return_rounded,
                              size: 16,
                              color: ColorConstant.orangeColor,
                            ),
                            const SizedBox(width: 4),
                            TextContext(
                              text: 'orders.review.return_exchange'.tr(),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.orangeColor,
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouteName.returnDetail,
                          arguments: existingReturn.id,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              existingReturn.isExchange
                                  ? Icons.swap_horiz_rounded
                                  : Icons.track_changes_rounded,
                              size: 16,
                              color: ColorConstant.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            TextContext(
                              text:
                              "${existingReturn.isExchange ? 'Exchange' : 'Return'} · ${existingReturn.statusRaw}",
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.primaryColor,
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
      ],
    );
  }

  Widget _buildPaymentCard(Size size, OrderModel order) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.credit_card_rounded,
                size: 18,
                color: ColorConstant.primaryColor,
              ),
              const SizedBox(width: 8),
              TextContext(
                text: 'orders.payment.paid_via'.tr(
                  args: [order.payment?.method ?? '—'],
                ),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          SizedBox(height: size.height * 0.016),
          _billRow(
            'orders.payment.subtotal'.tr(),
            "₹${order.subtotal.toStringAsFixed(0)}",
          ),

          _billRow(
            'orders.payment.tax'.tr(),
            "₹${order.tax.toStringAsFixed(0)}",
          ),

          _billRow(
            'orders.payment.discount'.tr(),
            "-₹${order.discount.toStringAsFixed(0)}",
            valueColor: ColorConstant.successColor,
          ),

          _billRow(
            'orders.payment.total_paid'.tr(),
            "₹${order.total.toStringAsFixed(0)}",
            bold: true,
            valueColor: ColorConstant.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _billRow(
      String label,
      String value, {
        bool bold = false,
        Color? valueColor,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextContext(
          text: label,
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: bold
              ? ColorConstant.headlineTextColor
              : ColorConstant.labelTextColor,
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

  Widget _buildActionButtons(
      BuildContext context,
      Size size,
      OrderModel order,
      ) {
    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorConstant.errorColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: ColorConstant.errorColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextContext(
                text: 'orders.messages.order_cancelled'.tr(),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: ColorConstant.errorColor,
              ),
            ),
          ],
        ),
      );
    }

    if (!order.canCancel) return const SizedBox.shrink();

    return CustomButton(
      text: 'orders.actions.cancel_order'.tr(),
      width: double.infinity,
      height: 50,
      outlined: true,
      borderColor: ColorConstant.errorColor,
      textColor: ColorConstant.errorColor,
      icon: Icons.cancel_outlined,
      iconColor: ColorConstant.errorColor,
      onTap: () => _showCancelBottomSheet(context, order),
    );
  }

  void _showCancelBottomSheet(BuildContext context, OrderModel order) {
    final commentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final detailVm = context.read<OrderDetailViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: ColorConstant.whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: ColorConstant.borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextContext(
                    text: 'orders.actions.cancel_order'.tr(),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 6),
                  TextContext(
                    text: "Order #${order.orderNumber}",
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                  ),
                  const SizedBox(height: 16),
                  TextContext(
                    text: 'orders.messages.cancel_reason'.tr(),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConstant.fieldFillColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ColorConstant.borderColor),
                    ),
                    child: TextFormField(
                      controller: commentController,
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'orders.messages.cancel_reason_required'.tr()
                          : null,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'orders.messages.cancel_reason_hint'.tr(),
                        hintStyle: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          color: ColorConstant.placeholderColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder: (context, setSheetState) {
                      return Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'orders.actions.keep_order'.tr(),
                              outlined: true,
                              height: 50,
                              onTap: () => Navigator.of(sheetContext).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: detailVm,
                              builder: (context, _) {
                                return CustomButton(
                                  text: detailVm.isCancelling
                                      ? 'orders.actions.cancelling'.tr()
                                      : 'orders.actions.confirm_cancel'.tr(),
                                  height: 50,
                                  color: ColorConstant.errorColor,
                                  onTap: detailVm.isCancelling
                                      ? null
                                      : () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final ok = await detailVm.cancelOrder(
                                      commentController.text.trim(),
                                    );
                                    if (!sheetContext.mounted) return;
                                    Navigator.of(sheetContext).pop();
                                    if (!context.mounted) return;
                                    if (ok) {
                                      AppUtils.success(
                                        context,
                                        'orders.messages.cancel_success'.tr(),
                                      );
                                      context
                                          .read<OrderViewModel>()
                                          .refresh();
                                    } else {
                                      AppUtils.error(
                                        context,
                                        detailVm.cancelError ??
                                            'orders.messages.cancel_failed'.tr(),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return ColorConstant.orangeColor;
      case OrderStatus.processing:
        return ColorConstant.infoColor;
      case OrderStatus.completed:
        return ColorConstant.successColor;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return ColorConstant.errorColor;
      case OrderStatus.unknown:
        return ColorConstant.labelTextColor;
    }
  }

  String _statusLabel(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.processing:
        return "Processing";
      case OrderStatus.completed:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
      case OrderStatus.refunded:
        return "Refunded";
      case OrderStatus.unknown:
        return order.statusRaw;
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}

enum _StepState { done, current, upcoming }

class _Step {
  final String title;
  final _StepState state;
  const _Step(this.title, this.state);
}