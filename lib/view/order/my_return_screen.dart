import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../model/order/return_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/button_context.dart';
import '../../routes/route_name.dart';
import '../../viewmodel/orderview/return_list_viewmodel.dart';

class MyReturnsScreen extends StatefulWidget {
  const MyReturnsScreen({super.key});

  @override
  State<MyReturnsScreen> createState() => _MyReturnsScreenState();
}

class _MyReturnsScreenState extends State<MyReturnsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnListViewModel>().fetchReturns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _MyReturnsView();
  }
}

class _MyReturnsView extends StatelessWidget {
  const _MyReturnsView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();


    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: size.height * 0.014),
            Expanded(
              child: Consumer<ReturnListViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading && !vm.hasLoadedOnce) {
                    return const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor));
                  }

                  if (vm.errorMessage != null && vm.returns.isEmpty) {
                    return _buildErrorState(context, size, vm.errorMessage!, () => vm.fetchReturns());
                  }

                  if (vm.returns.isEmpty) {
                    return _buildEmptyState(size);
                  }

                  return RefreshIndicator(
                    color: ColorConstant.primaryColor,
                    onRefresh: () => vm.fetchReturns(showLoader: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final r in vm.returns) ...[
                            _buildReturnCard(context, size, r),
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
            child: TextContext(text: "My Returns & Exchanges", fontSize: 17, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildReturnCard(BuildContext context, Size size, ReturnModel r) {
    final config = _statusConfig(r.status);
    final item = r.orderItem;
    final double thumbSize = (size.width * 0.17).clamp(54.0, 76.0);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pushNamed(context, RouteName.returnDetail, arguments: r.id),
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
                    Icon(r.isExchange ? Icons.swap_horiz_rounded : Icons.keyboard_return_rounded, size: 15, color: ColorConstant.primaryColor),
                    const SizedBox(width: 5),
                    TextContext(text: r.isExchange ? "Exchange" : "Return", fontSize: 12.5, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: config.color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(config.label, style: TextStyle(color: config.color, fontSize: 11.5, fontWeight: FontWeight.w600, fontFamily: "Poppins")),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.014),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: thumbSize, width: thumbSize,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: ColorConstant.fieldFillColor),
                  child: item?.displayImage != null
                      ? Image.network(item!.displayImage!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: ColorConstant.placeholderColor))
                      : const Icon(Icons.image_outlined, color: ColorConstant.placeholderColor),
                ),
                SizedBox(width: size.width * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextContext(text: item?.displayName ?? 'Product', fontSize: 14, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      TextContext(text: "Reason: ${r.reason}", fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      TextContext(
                        text: r.createdAt != null ? "Requested on ${_formatDate(r.createdAt!)}" : '',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.placeholderColor,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: ColorConstant.placeholderColor, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.requested:
        return const _StatusConfig(label: "Requested", color: ColorConstant.orangeColor);
      case ReturnStatus.approved:
        return const _StatusConfig(label: "Approved", color: ColorConstant.infoColor);
      case ReturnStatus.rejected:
        return const _StatusConfig(label: "Rejected", color: ColorConstant.errorColor);
      case ReturnStatus.cancelled:
        return const _StatusConfig(label: "Cancelled", color: ColorConstant.errorColor);
      case ReturnStatus.completed:
        return const _StatusConfig(label: "Completed", color: ColorConstant.successColor);
      case ReturnStatus.unknown:
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
            child: const Icon(Icons.assignment_return_outlined, color: ColorConstant.primaryColor, size: 28),
          ),
          SizedBox(height: size.height * 0.018),
          const TextContext(text: "No return or exchange requests yet", fontSize: 13.5, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Size size, String message, VoidCallback onRetry) {
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