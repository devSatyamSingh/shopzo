import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/utils.dart';

/// Shopzo — My Coupons Screen.
/// Matches the approved Figma design: manual code-entry bar, a
/// gradient "Best For You" personalized highlight card, category
/// filter tabs, ticket-stub styled coupon cards (dashed divider with
/// punch-hole notches, tap-to-copy code, urgency tags, and a grayed
/// "used" state), and a "How coupons work?" footer row.
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  int _selectedFilter = 0;

  final List<String> _filters = const ["All", "New User", "Bank Offers"];

  // ---- Dummy data — replace with real data from your ViewModel/repo ----
  final List<_Coupon> _coupons = const [
    _Coupon(
      discountTitle: "FLAT ₹150 OFF",
      description: "On orders above ₹999",
      code: "WELCOME150",
      urgencyTag: "Expiring in 2 days",
      state: _CouponState.active,
    ),
    _Coupon(
      discountTitle: "20% OFF",
      description: "Applicable on footwear",
      code: "SHOP20",
      plainTag: "LIMITED TIME",
      state: _CouponState.active,
    ),
    _Coupon(
      discountTitle: "FLAT 50% OFF",
      description: "Mega Diwali Sale",
      code: "DIWALI50",
      usedDate: "Coupon used on 24 Oct",
      state: _CouponState.expired,
    ),
  ];

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _applyManualCode() {
    if (_codeController.text.trim().isEmpty) return;
    // TODO: call your coupon-validation API with _codeController.text
    AppUtils.success(context, "Coupon '${_codeController.text.trim()}' applied!");
    _codeController.clear();
    AppUtils.hideKeyboard(context);
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppUtils.success(context, "Code '$code' copied to clipboard");
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.016),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildManualCodeBar(size),
                    SizedBox(height: size.height * 0.02),
                    _buildBestOfferCard(size),
                    SizedBox(height: size.height * 0.022),
                    _buildFilterTabs(size),
                    SizedBox(height: size.height * 0.02),
                    for (final coupon in _coupons) ...[
                      buildCouponTicketCard(size, coupon),
                      SizedBox(height: size.height * 0.018),
                    ],
                    SizedBox(height: size.height * 0.008),
                    _buildHowItWorksRow(size),
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
              child: Icon(Icons.arrow_back_rounded, color: ColorConstant.primaryColor, size: 22),
            ),
          ),
          const Expanded(
            child: TextContext(
              text: "My Coupons",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- MANUAL CODE ENTRY BAR ----------------
  Widget _buildManualCodeBar(Size size) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorConstant.primaryLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                  color: ColorConstant.headlineTextColor,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: "ENTER COUPON CODE",
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                    color: ColorConstant.placeholderColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
          CustomButton(
            text: "Apply",
            width: 88,
            height: 44,
            fontSize: 13.5,
            borderRadius: BorderRadius.circular(26),
            onTap: _applyManualCode,
          ),
        ],
      ),
    );
  }

  /// ---------------- BEST OFFER GRADIENT CARD ----------------
  Widget _buildBestOfferCard(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.02),
      decoration: BoxDecoration(
        gradient: ColorConstant.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -10,
            child: Icon(Icons.star_rounded, size: size.width * 0.3, color: Colors.white.withOpacity(0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "BEST FOR YOU",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Poppins",
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.016),
              Text(
                "Save ₹250 instantly",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (size.width * 0.06).clamp(20.0, 26.0),
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: size.height * 0.01),
              const Text(
                "Auto-applied on your next order over ₹1,999",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                  height: 1.4,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              const Row(
                children: [
                  Icon(Icons.star_border_rounded, color: Colors.white, size: 15),
                  SizedBox(width: 6),
                  Text(
                    "Valid for 15 days",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- FILTER TABS ----------------
  Widget _buildFilterTabs(Size size) {
    return Row(
      children: List.generate(_filters.length, (index) {
        final bool isSelected = index == _selectedFilter;
        return Padding(
          padding: EdgeInsets.only(right: size.width * 0.025),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: isSelected ? ColorConstant.primaryColor : ColorConstant.fieldFillColor,
                borderRadius: BorderRadius.circular(30),
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
          ),
        );
      }),
    );
  }

  /// ---------------- COUPON TICKET CARD ----------------
  Widget buildCouponTicketCard(Size size, _Coupon coupon) {
    final bool isExpired = coupon.state == _CouponState.expired;
    final Color cardColor = isExpired ? ColorConstant.fieldFillColor : ColorConstant.whiteColor;
    final Color titleColor = isExpired ? ColorConstant.placeholderColor : ColorConstant.primaryColor;
    final Color textColor = isExpired ? ColorConstant.placeholderColor : ColorConstant.headlineTextColor;

    return Container(
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
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- Left section ----
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.discountTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Poppins",
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextContext(
                          text: coupon.description,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        const SizedBox(height: 14),
                        if (coupon.urgencyTag != null)
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
                                  coupon.urgencyTag!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poppins",
                                    color: ColorConstant.orangeColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (coupon.plainTag != null)
                          Text(
                            coupon.plainTag!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              letterSpacing: 0.5,
                              color: ColorConstant.placeholderColor,
                            ),
                          )
                        else if (coupon.usedDate != null)
                            Text(
                              coupon.usedDate!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                                color: ColorConstant.placeholderColor,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),

                // ---- Dashed divider ----
                const _DashedDivider(),

                // ---- Right section ----
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CODE",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            letterSpacing: 0.6,
                            color: ColorConstant.placeholderColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isExpired ? ColorConstant.borderColor : ColorConstant.primaryColor.withOpacity(0.4),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            coupon.code,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              fontFamily: "Poppins",
                              letterSpacing: 0.5,
                              color: titleColor,
                            ),
                          ),
                        ),
                        if (!isExpired) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _copyCode(coupon.code),
                            child: const Text(
                              "TAP TO COPY",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Poppins",
                                letterSpacing: 0.3,
                                color: ColorConstant.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- "USED" diagonal stamp ----
          if (isExpired)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
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
                        "USED",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: "Poppins",
                          letterSpacing: 4,
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
    );
  }

  /// ---------------- HOW COUPONS WORK ----------------
  Widget _buildHowItWorksRow(Size size) {
    return InkWell(
      onTap: () {
        // TODO: expand FAQ / open help sheet
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.016),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColorConstant.dividerColor, width: 1)),
        ),
        child: Row(
          children: const [
            Icon(Icons.help_outline_rounded, color: ColorConstant.labelTextColor, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: TextContext(
                text: "How do coupons work?",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: ColorConstant.placeholderColor, size: 20),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Dashed vertical divider with punch-hole notches ----------------
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedLinePainter(),
            ),
          ),

          const Positioned(
            top: -7,
            child: _Notch(),
          ),

          const Positioned(
            bottom: -7,
            child: _Notch(),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorConstant.borderColor
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const double dashHeight = 5;
    const double gap = 4;

    double y = 0;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        paint,
      );

      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      width: 14,
      decoration: const BoxDecoration(
        color: ColorConstant.scaffoldBgColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Local models — move to lib/model/coupon_model.dart once wired
/// to a real API.
/// ------------------------------------------------------------
enum _CouponState { active, expired }

class _Coupon {
  final String discountTitle;
  final String description;
  final String code;
  final String? urgencyTag;
  final String? plainTag;
  final String? usedDate;
  final _CouponState state;

  const _Coupon({
    required this.discountTitle,
    required this.description,
    required this.code,
    this.urgencyTag,
    this.plainTag,
    this.usedDate,
    required this.state,
  });
}