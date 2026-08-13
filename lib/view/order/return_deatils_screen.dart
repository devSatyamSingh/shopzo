import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/order/return_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../viewmodel/orderview/return_details_viewmodel.dart';
import '../../viewmodel/orderview/return_list_viewmodel.dart';

class ReturnDetailScreen extends StatefulWidget {
  final String returnId;

  const ReturnDetailScreen({
    super.key,
    required this.returnId,
  });

  @override
  State<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends State<ReturnDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnDetailViewModel>().fetchReturn(widget.returnId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _ReturnDetailView();
  }
}

class _ReturnDetailView extends StatelessWidget {
  const _ReturnDetailView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Consumer<ReturnDetailViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildBody(context, size, vm),
                ),
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
              child: Icon(Icons.arrow_back_rounded, color: ColorConstant.headlineTextColor, size: 22),
            ),
          ),
          const Expanded(
            child: TextContext(text: "Request Details", fontSize: 18, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, Size size, ReturnDetailViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor));
    }

    if (vm.status == ReturnDetailStatus.error || vm.returnRequest == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: ColorConstant.errorColor, size: 40),
              SizedBox(height: size.height * 0.012),
              TextContext(text: vm.errorMessage ?? 'Something went wrong', fontSize: 13, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor, textAlign: TextAlign.center),
              SizedBox(height: size.height * 0.02),
              CustomButton(text: "Retry", width: 140, height: 44, onTap: () => vm.fetchReturn(vm.returnId!)),
            ],
          ),
        ),
      );
    }

    final r = vm.returnRequest!;
    final item = r.orderItem;
    final config = _statusConfig(r.status);

    return RefreshIndicator(
      color: ColorConstant.primaryColor,
      onRefresh: () => vm.fetchReturn(r.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.016),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(color: config.color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    height: 40, width: 40,
                    decoration: BoxDecoration(color: config.color.withOpacity(0.18), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Icon(config.icon, color: config.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(config.label, style: TextStyle(color: config.color, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: "Poppins")),
                        const SizedBox(height: 2),
                        TextContext(text: config.description, fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.018),

            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 64, width: 64,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: ColorConstant.fieldFillColor),
                    child: item?.displayImage != null
                        ? Image.network(item!.displayImage!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: ColorConstant.placeholderColor))
                        : const Icon(Icons.image_outlined, color: ColorConstant.placeholderColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextContext(text: item?.displayName ?? 'Product', fontSize: 14.5, fontWeight: FontWeight.w600),
                        const SizedBox(height: 4),
                        if (item?.order != null)
                          TextContext(text: "Order #${item!.order!.orderNumber}", fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(r.isExchange ? Icons.swap_horiz_rounded : Icons.keyboard_return_rounded, size: 14, color: ColorConstant.primaryColor),
                            const SizedBox(width: 4),
                            TextContext(text: r.isExchange ? "Exchange request" : "Return request", fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.018),

            if (r.isExchange && r.exchangeVariant != null) ...[
              _buildInfoCard(
                size,
                title: "Requested new variant",
                icon: Icons.swap_horiz_rounded,
                child: TextContext(text: r.exchangeVariant!.name, fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: size.height * 0.018),
            ],

            _buildInfoCard(
              size,
              title: "Reason",
              icon: Icons.info_outline_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(text: r.reason, fontSize: 13.5, fontWeight: FontWeight.w600),
                  if (r.reasonNote != null && r.reasonNote!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    TextContext(text: r.reasonNote!, fontSize: 12.5, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor, height: 1.5),
                  ],
                ],
              ),
            ),
            SizedBox(height: size.height * 0.018),

            _buildInfoCard(
              size,
              title: "Request Info",
              icon: Icons.receipt_long_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kvRow("Quantity", "${r.quantity}"),
                  const SizedBox(height: 8),
                  _kvRow("Requested on", r.createdAt != null ? _formatDate(r.createdAt!) : '—'),
                  if (r.status != ReturnStatus.requested) ...[
                    const SizedBox(height: 8),
                    _kvRow(_lastUpdateLabel(r.status), r.updatedAt != null ? _formatDate(r.updatedAt!) : '—'),
                  ],
                ],
              ),
            ),

            if (r.images.isNotEmpty) ...[
              SizedBox(height: size.height * 0.018),
              _buildInfoCard(
                size,
                title: "Photos",
                icon: Icons.photo_library_outlined,
                child: SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: r.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(r.images[i], height: 76, width: 76, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 76, width: 76,
                            color: ColorConstant.fieldFillColor,
                            child: const Icon(Icons.image_not_supported_outlined, color: ColorConstant.placeholderColor),
                          )),
                    ),
                  ),
                ),
              ),
            ],

            if (r.status == ReturnStatus.rejected) ...[
              SizedBox(height: size.height * 0.018),
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(color: ColorConstant.errorColor.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: ColorConstant.errorColor, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: TextContext(text: "Your request was reviewed and rejected by our team.", fontSize: 12.5, fontWeight: FontWeight.w500, color: ColorConstant.errorColor)),
                  ],
                ),
              ),
            ],

            SizedBox(height: size.height * 0.024),

            if (r.canCancel) ...[
              if (vm.cancelError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: size.height * 0.014),
                  decoration: BoxDecoration(color: ColorConstant.errorColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: ColorConstant.errorColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: TextContext(text: vm.cancelError!, fontSize: 12, color: ColorConstant.errorColor)),
                    ],
                  ),
                ),
              ],
              CustomButton(
                text: vm.isCancelling ? "Cancelling..." : "Cancel Request",
                width: double.infinity,
                height: 52,
                outlined: true,
                borderColor: ColorConstant.errorColor,
                textColor: ColorConstant.errorColor,
                icon: Icons.close_rounded,
                iconColor: ColorConstant.errorColor,
                onTap: vm.isCancelling ? null : () => _showCancelConfirm(context, vm),
              ),
            ],
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Size size, {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: ColorConstant.primaryColor),
              const SizedBox(width: 6),
              TextContext(text: title, fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstant.labelTextColor),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _kvRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextContext(text: label, fontSize: 12.5, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
        TextContext(text: value, fontSize: 12.5, fontWeight: FontWeight.w600),
      ],
    );
  }

  String _lastUpdateLabel(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.approved:
        return "Approved on";
      case ReturnStatus.rejected:
        return "Rejected on";
      case ReturnStatus.cancelled:
        return "Cancelled on";
      case ReturnStatus.completed:
        return "Completed on";
      default:
        return "Updated on";
    }
  }

  void _showCancelConfirm(BuildContext context, ReturnDetailViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(height: 4, width: 40, decoration: BoxDecoration(color: ColorConstant.borderColor, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              const TextContext(text: "Cancel this request?", fontSize: 16.5, fontWeight: FontWeight.w700),
              const SizedBox(height: 6),
              const TextContext(text: "Aapki return/exchange request cancel ho jaayegi. Ye action wapas nahi ho sakta.", fontSize: 12.5, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(text: "Keep It", outlined: true, height: 50, onTap: () => Navigator.of(sheetContext).pop()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: vm,
                      builder: (context, _) {
                        return CustomButton(
                          text: vm.isCancelling ? "Cancelling..." : "Yes, Cancel",
                          height: 50,
                          color: ColorConstant.errorColor,
                          onTap: vm.isCancelling
                              ? null
                              : () async {
                            final ok = await vm.cancelReturn();
                            if (!sheetContext.mounted) return;
                            Navigator.of(sheetContext).pop();
                            if (!context.mounted) return;
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Request cancelled successfully"), backgroundColor: ColorConstant.successColor),
                              );
                              try {
                                context.read<ReturnListViewModel>().refresh();
                              } catch (_) {}
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(vm.cancelError ?? 'Failed to cancel request'), backgroundColor: ColorConstant.errorColor),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _StatusConfig _statusConfig(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.requested:
        return const _StatusConfig(label: "Requested", description: "Aapka request review ke liye bheja gaya hai", color: ColorConstant.orangeColor, icon: Icons.hourglass_top_rounded);
      case ReturnStatus.approved:
        return const _StatusConfig(label: "Approved", description: "Aapki request approve ho gayi hai", color: ColorConstant.infoColor, icon: Icons.check_circle_outline_rounded);
      case ReturnStatus.rejected:
        return const _StatusConfig(label: "Rejected", description: "Aapki request reject kar di gayi hai", color: ColorConstant.errorColor, icon: Icons.cancel_outlined);
      case ReturnStatus.cancelled:
        return const _StatusConfig(label: "Cancelled", description: "Ye request cancel kar di gayi hai", color: ColorConstant.errorColor, icon: Icons.close_rounded);
      case ReturnStatus.completed:
        return const _StatusConfig(label: "Completed", description: "Aapki request complete ho gayi hai", color: ColorConstant.successColor, icon: Icons.task_alt_rounded);
      case ReturnStatus.unknown:
        return const _StatusConfig(label: "Processing", description: "Status update ho raha hai", color: ColorConstant.labelTextColor, icon: Icons.hourglass_empty_rounded);
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}

class _StatusConfig {
  final String label;
  final String description;
  final Color color;
  final IconData icon;
  const _StatusConfig({required this.label, required this.description, required this.color, required this.icon});
}