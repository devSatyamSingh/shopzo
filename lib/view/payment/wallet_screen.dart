import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/wallet_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/wallet_viewmodel.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WalletViewModel()..load(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<WalletViewModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static const _months = [
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

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${_months[d.month - 1]} ${d.year}, $h:$m $ap';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<WalletViewModel>();

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('My Wallet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (vm.isLoading && !vm.hasLoadedOnce) {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorConstant.primaryColor,
                ),
              );
            }

            if (vm.errorMessage != null && vm.wallet == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 44,
                        color: ColorConstant.errorColor,
                      ),
                      const SizedBox(height: 12),
                      TextContext(
                        text: vm.errorMessage!,
                        fontSize: 13.5,
                        color: ColorConstant.labelTextColor,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => vm.load(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final txs = vm.transactions;

            return RefreshIndicator(
              color: ColorConstant.primaryColor,
              onRefresh: vm.refresh,
              child: ListView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.02,
                ),
                children: [
                  // ---------------- BALANCE CARD ----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: ColorConstant.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstant.primaryColor.withOpacity(.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(.85),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppUtils.formatCurrency(vm.balance),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Refunds and cashback are credited here',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            color: Colors.white.withOpacity(.75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.028),

                  TextContext(
                    text: 'Transactions',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.headlineTextColor,
                  ),
                  SizedBox(height: size.height * 0.012),

                  // ---------------- FILTERS ----------------
                  Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: vm.filter == WalletFilter.all,
                        onTap: () => vm.setFilter(WalletFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Credit',
                        selected: vm.filter == WalletFilter.credit,
                        onTap: () => vm.setFilter(WalletFilter.credit),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Debit',
                        selected: vm.filter == WalletFilter.debit,
                        onTap: () => vm.setFilter(WalletFilter.debit),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.015),

                  // ---------------- LIST ----------------
                  if (vm.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 44,
                            color: ColorConstant.placeholderColor,
                          ),
                          const SizedBox(height: 10),
                          TextContext(
                            text: 'No transactions yet',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.labelTextColor,
                          ),
                        ],
                      ),
                    )
                  else
                    ...txs.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TransactionTile(
                          tx: t,
                          dateText: _formatDate(t.createdAt),
                        ),
                      ),
                    ),

                  if (vm.isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorConstant.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? ColorConstant.primaryColor
              : ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? ColorConstant.primaryColor
                : ColorConstant.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : ColorConstant.headlineTextColor,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransactionModel tx;
  final String dateText;

  const _TransactionTile({required this.tx, required this.dateText});

  @override
  Widget build(BuildContext context) {
    final color = tx.isCredit
        ? ColorConstant.successColor
        : ColorConstant.errorColor;
    final sign = tx.isCredit ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(14),
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
              color: color.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              tx.isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextContext(
                  text: tx.title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.headlineTextColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                TextContext(
                  text: dateText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextContext(
                text: '$sign${AppUtils.formatCurrency(tx.amount)}',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              if (tx.status != null && tx.status!.toUpperCase() != 'SUCCESS')
                TextContext(
                  text: tx.status!,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.labelTextColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
