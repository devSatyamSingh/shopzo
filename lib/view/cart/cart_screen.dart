import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ---- Dummy data — replace with real data from your ViewModel/repo ----
  final List<_CartItem> _items = [
    _CartItem(
      image: "assets/images/pro1.jpg",
      name: "Elite Wireless Headphones",
      variant: "Color: Midnight Blue",
      price: 1299,
      mrp: 2499,
      quantity: 1,
      status: _CartItemStatus.normal,
    ),
    _CartItem(
      image: "assets/images/pro2.jpg",
      name: "Smart Horizon Watch",
      variant: "Size: 44mm",
      price: 899,
      quantity: 1,
      status: _CartItemStatus.lowStock,
      stockMessage: "Only 1 left in stock — order soon",
    ),
    _CartItem(
      image: "assets/images/pro4.jpg",
      name: "Urban Comfort Sneakers",
      variant: "Size: 9",
      price: 0,
      quantity: 1,
      status: _CartItemStatus.outOfStock,
    ),
  ];

  final List<_SuggestedItem> _suggestions = const [
    _SuggestedItem( image: "assets/images/pro10.jpg", name: "Hard Shell Case", price: 299),
    _SuggestedItem( image: "assets/images/pro9.jpg", name: "Silver Link Strap", price: 449),
    _SuggestedItem( image: "assets/images/pro12.jpg", name: "Fast Charger", price: 699),
  ];

  final String _couponCode = "SAVE50";
  final double _couponSavings = 120;

  double get _itemTotal => 2499;
  double get _deliveryFee => 0;
  double get _platformFee => 5;
  double get _totalPayable =>
      _itemTotal - _couponSavings + _platformFee + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, size),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.045,
                  vertical: size.height * 0.018,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAddressStrip(size),
                    SizedBox(height: size.height * 0.02),
                    for (final item in _items) ...[
                      _buildCartItemCard(size, item),
                      if (item.status == _CartItemStatus.lowStock)
                        _buildLowStockBanner(size, item.stockMessage!),
                      SizedBox(height: size.height * 0.018),
                    ],
                    SizedBox(height: size.height * 0.006),
                    _buildSuggestionsStrip(size),
                    SizedBox(height: size.height * 0.02),
                    _buildCouponCard(size),
                    SizedBox(height: size.height * 0.02),
                    _buildBillDetailsCard(size),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
            _buildCheckoutBar(context, size),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.03,
        size.height * 0.012,
        size.width * 0.045,
        size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.scaffoldBgColor,
        border: const Border(
          bottom: BorderSide(color: ColorConstant.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 15,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextContext(
                  text: "My Cart",
                  fontSize: 19,
                  color: ColorConstant.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 2),
                TextContext(
                  text: "${_items.length} items",
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- DELIVERY ADDRESS STRIP ----------------
  Widget _buildAddressStrip(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstant.borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: ColorConstant.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.location_on_rounded,
                color: ColorConstant.primaryColor, size: 18),
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
                SizedBox(height: 2),
                TextContext(
                  text: "Home - 201301",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // TODO: open address list / picker
            },
            child: const TextContext(
              text: "Change",
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: ColorConstant.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- CART ITEM CARD ----------------
  Widget _buildCartItemCard(Size size, _CartItem item) {
    final bool isOutOfStock = item.status == _CartItemStatus.outOfStock;
    final double thumbSize = (size.width * 0.2).clamp(64.0, 90.0);

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Thumbnail ----
              Container(
                height: thumbSize,
                width: thumbSize,
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? ColorConstant.borderColor.withOpacity(0.5)
                      : ColorConstant.fieldFillColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Center(
                  child: Container(
                    width: thumbSize * .78,
                    height: thumbSize * .78,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Image.asset(
                          item.image,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.035),

              // ---- Name / variant / price ----
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(
                      text: item.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      color: isOutOfStock
                          ? ColorConstant.placeholderColor
                          : ColorConstant.headlineTextColor,
                    ),
                    const SizedBox(height: 4),
                    TextContext(
                      text: item.variant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.labelTextColor,
                    ),
                    const SizedBox(height: 8),
                    if (isOutOfStock)
                      const TextContext(
                        text: "Currently unavailable",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.errorColor,
                      )
                    else
                      Row(
                        children: [
                          TextContext(
                            text: "₹${item.price.toStringAsFixed(0)}",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.primaryColor,
                          ),
                          if (item.mrp != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              "₹${item.mrp!.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: "Poppins",
                                color: ColorConstant.placeholderColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.014),
          const Divider(height: 1, color: ColorConstant.dividerColor),
          SizedBox(height: size.height * 0.012),

          // ---- Remove + Quantity stepper ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => setState(() => _items.remove(item)),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.delete_outline_rounded,
                        size: 17, color: ColorConstant.errorColor),
                    SizedBox(width: 4),
                    TextContext(
                      text: "Remove",
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.errorColor,
                    ),
                  ],
                ),
              ),
              if (!isOutOfStock)
                _QuantityStepper(
                  quantity: item.quantity,
                  onIncrement: () => setState(() => item.quantity++),
                  onDecrement: () => setState(() {
                    if (item.quantity > 1) item.quantity--;
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- LOW STOCK BANNER (attached under a specific card) ----------------
  Widget _buildLowStockBanner(Size size, String message) {
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.008),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.034,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.orangeLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: ColorConstant.orangeColor, size: 18),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: TextContext(
              text: message,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ColorConstant.orangeDark,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- FREQUENTLY BOUGHT TOGETHER STRIP ----------------
  Widget _buildSuggestionsStrip(Size size) {
    final double cardWidth = size.width * 0.32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextContext(
          text: "Add these too?",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: size.height * 0.014),
        SizedBox(
          height: cardWidth * 1.2,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.026),
            itemBuilder: (context, index) {
              final item = _suggestions[index];
              return Container(
                width: cardWidth,
                decoration: BoxDecoration(
                  color: ColorConstant.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstant.blackColor.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: cardWidth * 0.73,
                          width: double.infinity,
                          color: ColorConstant.fieldFillColor,
                          alignment: Alignment.center,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.asset(
                                  item.image,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: InkWell(
                            onTap: () {
                              // TODO: add suggested item to cart
                            },
                            child: Container(
                              height: 26,
                              width: 26,
                              decoration: const BoxDecoration(
                                color: ColorConstant.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextContext(
                            text: item.name,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          TextContext(
                            text: "₹${item.price.toStringAsFixed(0)}",
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ColorConstant.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ---------------- APPLIED COUPON CARD ----------------
  Widget _buildCouponCard(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.013,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.successColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: const BoxDecoration(
              color: ColorConstant.successColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: "$_couponCode Applied",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.successColor,
                ),
                const SizedBox(height: 2),
                TextContext(
                  text: "You saved ₹${_couponSavings.toStringAsFixed(0)}",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.successColor,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // TODO: remove coupon
            },
            child: const TextContext(
              text: "Remove",
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- BILL DETAILS CARD ----------------
  Widget _buildBillDetailsCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
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
          const TextContext(
            text: "Bill Details",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: size.height * 0.016),
          _billRow("Item Total", "₹${_itemTotal.toStringAsFixed(0)}"),
          SizedBox(height: size.height * 0.012),
          _billRow(
            "Delivery Fee",
            _deliveryFee == 0 ? "FREE" : "₹${_deliveryFee.toStringAsFixed(0)}",
            valueColor: _deliveryFee == 0 ? ColorConstant.successColor : null,
          ),
          SizedBox(height: size.height * 0.012),
          _billRow(
            "Coupon Discount",
            "-₹${_couponSavings.toStringAsFixed(0)}",
            valueColor: ColorConstant.successColor,
          ),
          SizedBox(height: size.height * 0.012),
          _billRow("Platform Fee", "₹${_platformFee.toStringAsFixed(0)}"),
          SizedBox(height: size.height * 0.016),
          const Divider(height: 1, color: ColorConstant.dividerColor),
          SizedBox(height: size.height * 0.016),
          _billRow(
            "To Pay",
            "₹${_totalPayable.toStringAsFixed(0)}",
            bold: true,
            valueColor: ColorConstant.primaryColor,
          ),
          SizedBox(height: size.height * 0.02),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: ColorConstant.fieldFillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, color: ColorConstant.successColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextContext(
                    text: "Your order is eligible for eco-friendly packaging",
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: ColorConstant.labelTextColor,
                  ),
                ),
              ],
            ),
          ),
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
          fontSize: bold ? 15.5 : 13.5,
          fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
          color: bold ? ColorConstant.headlineTextColor : ColorConstant.labelTextColor,
        ),
        TextContext(
          text: value,
          fontSize: bold ? 17 : 13.5,
          fontWeight: bold ? FontWeight.w500 : FontWeight.w600,
          color: valueColor ?? ColorConstant.headlineTextColor,
        ),
      ],
    );
  }

  /// ---------------- STICKY BOTTOM CHECKOUT BAR ----------------
  Widget _buildCheckoutBar(BuildContext context, Size size) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: size.height * 0.016,
        ),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextContext(
                    text: "₹${_totalPayable.toStringAsFixed(0)}",
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      TextContext(
                        text: "View price details",
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.primaryColor,
                      ),
                      Icon(Icons.keyboard_arrow_up_rounded,
                          color: ColorConstant.primaryColor, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              flex: 6,
              child: CustomButton(
                text: "Proceed to Checkout",
                height: 49,
                fontSize: 14,
                icon: Icons.arrow_forward_rounded,
                iconSize: 18,
                onTap: () {
                  // TODO: navigate to RouteName.checkout
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Quantity Stepper (- 1 +) ----------------
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstant.primaryLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(Icons.remove_rounded, onDecrement),
          SizedBox(
            width: 26,
            child: Text(
              "$quantity",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontFamily: "Poppins",
                color: ColorConstant.headlineTextColor,
              ),
            ),
          ),
          _stepButton(Icons.add_rounded, onIncrement),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 26,
        width: 26,
        alignment: Alignment.center,
        child: Icon(icon, size: 15, color: ColorConstant.primaryColor),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Local models — move to lib/model/cart_item_model.dart once
/// wired to a real API.
/// ------------------------------------------------------------
enum _CartItemStatus { normal, lowStock, outOfStock }

class _CartItem {
  final String image; // placeholder — swap for `image` (network/asset) later
  final String name;
  final String variant;
  final double price;
  final double? mrp;
  int quantity;
  final _CartItemStatus status;
  final String? stockMessage;

  _CartItem({
    required this.image,
    required this.name,
    required this.variant,
    required this.price,
    this.mrp,
    required this.quantity,
    required this.status,
    this.stockMessage,
  });
}

class _SuggestedItem {
  final String image;
  final String name;
  final double price;

  const _SuggestedItem({
    required this.image,
    required this.name,
    required this.price,
  });
}