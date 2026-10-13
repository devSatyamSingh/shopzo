import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/payout_method_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../viewmodel/payout_method_viewmodel.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PayoutMethodViewModel()..fetch(),
      child: const _PaymentMethodsView(),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView();

  Future<void> _openAdd(BuildContext context) async {
    final added = await Navigator.pushNamed(context, RouteName.addPaymentMethod);
    if (added == true && context.mounted) {
      context.read<PayoutMethodViewModel>().fetch(showLoader: false);
    }
  }

  Future<void> _confirmDelete(BuildContext context, PayoutMethodModel m) async {
    final vm = context.read<PayoutMethodViewModel>();
    final ok = await AppUtils.showConfirmDialog(
      context,
      title: 'Remove UPI?',
      message: '${m.title} will be removed from your saved list.',
      confirmText: 'Remove',
      isDestructive: true,
    );
    if (!ok) return;
    final done = await vm.delete(m.id);
    if (!context.mounted) return;
    if (done) {
      AppUtils.success(context, vm.actionMessage ?? 'Payout method deleted');
    } else {
      AppUtils.error(context, vm.actionMessage ?? 'Could not delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<PayoutMethodViewModel>();

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('Payment Methods'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Builder(builder: (_) {
          if (vm.isLoading && !vm.hasLoadedOnce) {
            return Center(
              child: CircularProgressIndicator(color: ColorConstant.primaryColor),
            );
          }

          if (vm.errorMessage != null && !vm.hasLoadedOnce) {
            return _ErrorState(
              message: vm.errorMessage!,
              onRetry: () => vm.fetch(),
            );
          }

          return RefreshIndicator(
            color: ColorConstant.primaryColor,
            onRefresh: vm.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.02,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextContext(
                      text: 'UPI IDs',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.headlineTextColor,
                    ),
                    GestureDetector(
                      onTap: () => _openAdd(context),
                      child: TextContext(
                        text: 'Add New',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: ColorConstant.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),

                if (vm.isEmpty)
                  _EmptyState(onAdd: () => _openAdd(context))
                else
                  ...vm.methods.map(
                        (m) => Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.015),
                      child: _UpiCard(
                        method: m,
                        isDeleting: vm.deletingId == m.id,
                        onDelete: () => _confirmDelete(context, m),
                      ),
                    ),
                  ),

                SizedBox(height: size.height * 0.01),

                // ---------------- INFO NOTE ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_rounded,
                          size: 18, color: ColorConstant.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextContext(
                          text:
                          'For returns or exchanges, you can receive your refund in your Wallet or through a UPI ID saved here. Your full UPI ID is never displayed on the screen.',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// ---------------- UPI CARD ----------------
class _UpiCard extends StatelessWidget {
  final PayoutMethodModel method;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _UpiCard({
    required this.method,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = (method.label ?? '').trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: ColorConstant.fieldFillColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 18, color: ColorConstant.headlineTextColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextContext(
                  text: method.title,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: ColorConstant.headlineTextColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Pill(text: method.type, color: ColorConstant.primaryColor),
                    if (hasLabel && (method.upiMasked ?? '').isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextContext(
                          text: method.upiMasked!,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ColorConstant.labelTextColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isDeleting)
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorConstant.errorColor,
              ),
            )
          else
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete_outline_rounded,
                  color: ColorConstant.errorColor, size: 22),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 44, color: ColorConstant.placeholderColor),
          const SizedBox(height: 12),
          TextContext(
            text: 'No UPI ID saved',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ColorConstant.headlineTextColor,
          ),
          const SizedBox(height: 6),
          TextContext(
            text: 'Please add your UPI ID to receive your refund.',
            fontSize: 12.5,
            color: ColorConstant.labelTextColor,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onAdd, child: const Text('Add UPI ID')),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 44, color: ColorConstant.errorColor),
            const SizedBox(height: 12),
            TextContext(
              text: message,
              fontSize: 13.5,
              color: ColorConstant.labelTextColor,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}