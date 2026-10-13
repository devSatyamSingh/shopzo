import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../model/coupons/coupon_model.dart';
import '../../viewmodel/coupon/coupon_viewmodel.dart';
import '../../utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';

/// Kept for backward compatibility with any code that still imports it,
/// though this screen no longer applies coupons itself — it's a pure
/// browse-and-copy list. Applying happens on the Cart / Product coupon
/// field, using the code copied from here.
class CouponApplyResult {
  final String code;
  final double discount;
  final double? finalAmount;

  const CouponApplyResult({
    required this.code,
    required this.discount,
    this.finalAmount,
  });
}

class CouponsScreen extends StatefulWidget {
  /// Optional — only used to show an informational "eligible / add ₹X
  /// more" hint per coupon. Does NOT hide or apply anything.
  final double subtotal;

  const CouponsScreen({super.key, this.subtotal = 0});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CouponViewModel()..fetchCoupons(),
      child: _CouponsView(subtotal: widget.subtotal),
    );
  }
}

class _CouponsView extends StatelessWidget {
  final double subtotal;
  const _CouponsView({required this.subtotal});

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppUtils.success(
      context,
      'coupons.code_copied'.tr(args: [code]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<CouponViewModel>();
    context.watch<LanguageProvider>();


    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            Expanded(
              child: RefreshIndicator(
                color: ColorConstant.primaryColor,
                onRefresh: () => vm.fetchCoupons(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.016),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextContext(
                        text: 'coupons.all_coupons'.tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: size.height * 0.006),
                      TextContext(
                        text: 'coupons.copy_instruction'.tr(),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
                      SizedBox(height: size.height * 0.02),

                      _buildCouponList(context, size, vm),

                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
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
              child: Icon(Icons.arrow_back_rounded, color: ColorConstant.primaryColor, size: 22),
            ),
          ),
          Expanded(
            child: TextContext(
              text: 'coupons.title'.tr(),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 34), // balances back-button width
        ],
      ),
    );
  }

  /// ---------------- COUPON LIST SWITCH ----------------
  Widget _buildCouponList(BuildContext context, Size size, CouponViewModel vm) {
    if (vm.isLoadingList) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor)),
      );
    }

    if (vm.listError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded, color: ColorConstant.placeholderColor, size: 36),
            const SizedBox(height: 10),
            TextContext(
              text: vm.listError!,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ColorConstant.labelTextColor,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: vm.fetchCoupons,
              child: TextContext(
                text: 'coupons.retry'.tr(),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorConstant.primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    if (vm.coupons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: TextContext(
            text: 'coupons.no_coupons'.tr(),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ColorConstant.labelTextColor,
          ),
        ),
      );
    }

    // Show every coupon the admin has added — active ones first, then
    // expired ones grouped at the bottom, nothing hidden.
    final active = vm.coupons.where((c) => !c.isExpired).toList();
    final expired = vm.coupons.where((c) => c.isExpired).toList();

    return Column(
      children: [
        for (final coupon in active)
          Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.018),
            child: _buildCouponTicketCard(context, size, coupon),
          ),
        if (expired.isNotEmpty) ...[
          SizedBox(height: size.height * 0.008),
          TextContext(
            text: 'coupons.expired'.tr(),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ColorConstant.placeholderColor,
          ),
          SizedBox(height: size.height * 0.012),
          for (final coupon in expired)
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.018),
              child: _buildCouponTicketCard(context, size, coupon),
            ),
        ],
      ],
    );
  }

  /// ---------------- COUPON TICKET CARD (browse + copy only) ----------------
  Widget _buildCouponTicketCard(BuildContext context, Size size, CouponModel coupon) {
    final bool isExpired = coupon.isExpired;
    final bool isEligible = !isExpired && coupon.isEligibleFor(subtotal);

    final Color cardColor = isExpired ? ColorConstant.fieldFillColor : ColorConstant.whiteColor;
    final Color titleColor = isExpired ? ColorConstant.placeholderColor : ColorConstant.primaryColor;
    final Color textColor = isExpired ? ColorConstant.placeholderColor : ColorConstant.headlineTextColor;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: isExpired ? null : () => _copyCode(context, coupon.code),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isExpired
              ? []
              : [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.displayTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: "Poppins", color: titleColor),
                        ),
                        const SizedBox(height: 4),
                        TextContext(
                          text: coupon.displayDescription,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        if (!isExpired && !isEligible) ...[
                          const SizedBox(height: 6),
                          TextContext(
                            text: 'coupons.add_more'.tr(
                              args: [
                                (coupon.minOrderValue - subtotal)
                                    .clamp(0, double.infinity)
                                    .toStringAsFixed(0),
                              ],
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.orangeColor,
                          ),
                        ] else if (!isExpired && coupon.expiryLabel != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: ColorConstant.orangeLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, size: 12, color: ColorConstant.orangeColor),
                                const SizedBox(width: 5),
                                Text(
                                  coupon.expiryLabel!,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: "Poppins", color: ColorConstant.orangeColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: titleColor.withOpacity(0.4), width: 1.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          coupon.code,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, fontFamily: "Poppins", color: titleColor),
                        ),
                      ),
                      if (!isExpired) ...[
                        const SizedBox(height: 8),
                        Text(
                          'coupons.tap_to_copy'.tr(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                            letterSpacing: 0.3,
                            color: ColorConstant.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ---- "EXPIRED" diagonal stamp ----
            if (isExpired)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.28,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorConstant.placeholderColor.withOpacity(0.5), width: 1.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'coupons.expired'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Poppins",
                            letterSpacing: 3,
                            color: ColorConstant.placeholderColor.withOpacity(0.55),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}