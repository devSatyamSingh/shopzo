import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../checkout/checkout_step1_screen.dart';


class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _imageController = PageController();
  final TextEditingController _pincodeController = TextEditingController();

  int _currentImageIndex = 0;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 2; // "8" selected, matching the design
  int _quantity = 1;
  bool _isWishlisted = false;

  // ---- Dummy data — replace with real data from your ViewModel/repo ----
  final List<Color> _colors = const [
    Color(0xFF1E293B), // Midnight Blue
    Color(0xFF111827), // Black
    Color(0xFFE5E7EB), // Silver
  ];
  final List<String> _colorNames = const ["Midnight Blue", "Black", "Silver"];

  final List<String> _sizes = const ["6", "7", "8", "9", "10"];
  final List<bool> _sizeAvailable = const [true, true, true, true, false];

  final List<bool> _accordionExpanded = [true, false, false, false];
  final List<String> _accordionTitles = const [
    "Product Details",
    "Features",
    "Delivery & Returns",
    "Warranty Info",
  ];

  final List<_ReviewItem> _reviews = const [
    _ReviewItem(
      initial: "S",
      avatarColor: ColorConstant.primaryColor,
      name: "Sarah Jenkins",
      daysAgo: "2 days ago",
      rating: 5,
      text: "Absolutely amazing quality! The indigo color is even better in person. Battery life is stellar.",
      hasPhoto: false,
    ),
    _ReviewItem(
      initial: "M",
      avatarColor: ColorConstant.orangeColor,
      name: "Michael Chen",
      daysAgo: "1 week ago",
      rating: 5,
      text: "Premium feel and great performance. Worth every penny.",
      hasPhoto: true,
    ),
  ];

  final List<_RelatedProduct> _related = const [
    _RelatedProduct(
      image: "assets/images/pro1.jpg",
      name: "Premium Charging Pad",
      price: 49.99,
    ),
    _RelatedProduct(
      image: "assets/images/pro8.jpg",
      name: "Titanium Strap",
      price: 89.00,
    ),
    _RelatedProduct(
      image: "assets/images/pro12.jpg",
      name: "Wireless Earbuds",
      price: 129.00,
    ),
  ];

  final Map<int, double> _ratingDistribution = const {
    5: 0.75,
    4: 0.15,
    3: 0.06,
    2: 0.02,
    1: 0.02,
  };

  @override
  void dispose() {
    _imageController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageGallery(context, size),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.018),
                        _buildTitleBlock(size),
                        SizedBox(height: size.height * 0.014),
                        _buildPriceBlock(size),
                        SizedBox(height: size.height * 0.012),
                        _buildLowestPriceTag(size),
                        SizedBox(height: size.height * 0.022),
                        _buildColorSelector(size),
                        SizedBox(height: size.height * 0.02),
                        _buildSizeSelector(size),
                        SizedBox(height: size.height * 0.022),
                        _buildDeliveryCard(size),
                        SizedBox(height: size.height * 0.02),
                        _buildQuantityUrgencyRow(size),
                        SizedBox(height: size.height * 0.022),
                        _buildAccordions(size),
                        SizedBox(height: size.height * 0.02),
                        _buildSellerCard(size),
                        SizedBox(height: size.height * 0.024),
                        _buildReviewsSection(size),
                        SizedBox(height: size.height * 0.026),
                        _buildRelatedProducts(size),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActionBar(context, size),
        ],
      ),
    );
  }

  /// ---------------- IMAGE GALLERY ----------------
  Widget _buildImageGallery(BuildContext context, Size size) {
    final double galleryHeight = (size.height * 0.36).clamp(260.0, 360.0);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: galleryHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDCE6F0), Color(0xFFEFF1F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: PageView.builder(
                  controller: _imageController,
                  itemCount: 5,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (context, index) {
                    return Center(
                      child: Image.asset(
                        "assets/images/pro7.jpg",
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),

              // Discount ribbon
              Positioned(
                left: 0,
                bottom: 22,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: ColorConstant.orangeColor,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                  ),
                  child: const Text(
                    "-20% OFF",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),

              // Back button
              Positioned(
                top: 10,
                left: size.width * 0.04,
                child: _circleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),

              // Share + wishlist buttons
              Positioned(
                top: 10,
                right: size.width * 0.04,
                child: Row(
                  children: [
                    _circleIconButton(
                      icon: Icons.share_rounded,
                      onTap: () {
                        // TODO: share product link
                      },
                    ),
                    const SizedBox(width: 10),
                    _circleIconButton(
                      icon: _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      iconColor: _isWishlisted ? ColorConstant.wishlistColor : ColorConstant.headlineTextColor,
                      onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                    ),
                  ],
                ),
              ),

              // Dot indicator
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final bool active = index == _currentImageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: active ? 16 : 6,
                      decoration: BoxDecoration(
                        color: active ? ColorConstant.primaryColor : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          // Thumbnails
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.045,
              vertical: size.height * 0.014,
            ),
            child: SizedBox(
              height: size.width * 0.15,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(width: size.width * 0.025),
                itemBuilder: (context, index) {
                  final bool isSelected = index == _currentImageIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentImageIndex = index);
                      _imageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: size.width * 0.15,
                      decoration: BoxDecoration(
                        color: ColorConstant.fieldFillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? ColorConstant.primaryColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          "assets/images/pro7.jpg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = ColorConstant.headlineTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  /// ---------------- TITLE + RATING ----------------
  Widget _buildTitleBlock(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextContext(
          text: "SHOPZO ESSENTIALS",
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: ColorConstant.labelTextColor,
        ),
        const SizedBox(height: 6),
        const TextContext(
          text: "Nexus Gen-3 Smart Pro Wearable with Adaptive OLED Display",
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstant.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 3),
                  Text(
                    "4.8",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const TextContext(
              text: "(2,145 ratings)",
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: ColorConstant.labelTextColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(height: 12, width: 1, color: ColorConstant.borderColor),
            ),
            const TextContext(
              text: "1.2k sold",
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: ColorConstant.labelTextColor,
            ),
          ],
        ),
      ],
    );
  }

  /// ---------------- PRICE ----------------
  Widget _buildPriceBlock(Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const TextContext(
          text: "\$249.99",
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        const SizedBox(width: 8),
        const Padding(
          padding: EdgeInsets.only(bottom: 3),
          child: Text(
            "\$312.50",
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Poppins",
              color: ColorConstant.placeholderColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: TextContext(
            text: "-20%",
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: ColorConstant.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLowestPriceTag(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorConstant.orangeLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.sell_rounded, size: 14, color: ColorConstant.orangeColor),
          SizedBox(width: 6),
          TextContext(
            text: "LOWEST PRICE IN 30 DAYS",
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: ColorConstant.orangeDark,
          ),
        ],
      ),
    );
  }

  /// ---------------- COLOR SELECTOR ----------------
  Widget _buildColorSelector(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextContext(
          text: "Color: ${_colorNames[_selectedColorIndex]}",
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: size.height * 0.012),
        Row(
          children: List.generate(_colors.length, (index) {
            final bool isSelected = index == _selectedColorIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? ColorConstant.primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorConstant.borderColor),
                    ),
                    alignment: Alignment.center,
                    child: isSelected
                        ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: _colors[index].computeLuminance() > 0.5
                          ? ColorConstant.headlineTextColor
                          : Colors.white,
                    )
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// ---------------- SIZE SELECTOR ----------------
  Widget _buildSizeSelector(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextContext(
              text: "Select Size",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            InkWell(
              onTap: () {
                // TODO: open size guide sheet
              },
              child: Row(
                children: const [
                  Icon(Icons.straighten_rounded, size: 14, color: ColorConstant.primaryColor),
                  SizedBox(width: 4),
                  TextContext(
                    text: "Size Guide",
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.012),
        Row(
          children: List.generate(_sizes.length, (index) {
            final bool isAvailable = _sizeAvailable[index];
            final bool isSelected = index == _selectedSizeIndex && isAvailable;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: isAvailable ? () => setState(() => _selectedSizeIndex = index) : null,
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? ColorConstant.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                    ),
                  ),
                  child: Text(
                    _sizes[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                      decoration: isAvailable ? null : TextDecoration.lineThrough,
                      color: isSelected
                          ? Colors.white
                          : isAvailable
                          ? ColorConstant.headlineTextColor
                          : ColorConstant.placeholderColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// ---------------- DELIVERY CHECK CARD ----------------
  Widget _buildDeliveryCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextContext(
            text: "DELIVERY DETAILS",
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: ColorConstant.labelTextColor,
          ),
          SizedBox(height: size.height * 0.012),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13.5, fontFamily: "Poppins"),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Enter Pincode",
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: ColorConstant.placeholderColor,
                      fontFamily: "Poppins",
                    ),
                    filled: true,
                    fillColor: ColorConstant.whiteColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ColorConstant.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ColorConstant.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ColorConstant.primaryColor, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CustomButton(
                text: "Check",
                width: 80,
                height: 44,
                fontSize: 13,
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // TODO: call pincode-serviceability API
                },
              ),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Row(
            children: const [
              Icon(Icons.check_circle_rounded, size: 16, color: ColorConstant.successColor),
              SizedBox(width: 6),
              TextContext(
                text: "Delivery by Fri, 19 July",
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ColorConstant.successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- QUANTITY + URGENCY ----------------
  Widget _buildQuantityUrgencyRow(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: ColorConstant.fieldFillColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(Icons.remove_rounded, () {
                if (_quantity > 1) setState(() => _quantity--);
              }),
              SizedBox(
                width: 28,
                child: Text(
                  "$_quantity",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              _qtyButton(Icons.add_rounded, () => setState(() => _quantity++)),
            ],
          ),
        ),
        Row(
          children: const [
            _PulsingDot(),
            SizedBox(width: 6),
            TextContext(
              text: "Only 4 left!",
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.orangeColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 28,
        width: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: ColorConstant.primaryColor),
      ),
    );
  }

  /// ---------------- ACCORDIONS ----------------
  Widget _buildAccordions(Size size) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstant.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_accordionTitles.length, (index) {
          final bool isExpanded = _accordionExpanded[index];
          final bool isLast = index == _accordionTitles.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _accordionExpanded[index] = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextContext(
                            text: _accordionTitles[index],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: ColorConstant.labelTextColor,
                          ),
                        ],
                      ),
                      if (index == 2 && !isExpanded) ...[
                        const SizedBox(height: 4),
                        const TextContext(
                          text: "7-day easy returns",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.successColor,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextContext(
                    text: _accordionBody(index),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.labelTextColor,
                    height: 1.6,
                  ),
                ),
              if (!isLast) const Divider(height: 1, color: ColorConstant.dividerColor),
            ],
          );
        }),
      ),
    );
  }

  String _accordionBody(int index) {
    switch (index) {
      case 0:
        return "Experience the next generation of smart tech with the Nexus Gen-3. Featuring a sapphire crystal OLED display, titanium enclosure, and industry-leading health monitoring sensors. Water resistant up to 50m.";
      case 1:
        return "Heart-rate & SpO2 monitoring, GPS, 7-day battery life, always-on display, 100+ workout modes.";
      case 2:
        return "Free delivery on orders above \$50. 7-day easy return and replacement policy from the date of delivery.";
      default:
        return "1-year manufacturer warranty covering manufacturing defects. Extended warranty available at checkout.";
    }
  }

  /// ---------------- SELLER CARD ----------------
  Widget _buildSellerCard(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.014),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: const BoxDecoration(
              color: ColorConstant.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.storefront_rounded, color: ColorConstant.primaryColor, size: 20),
          ),
          SizedBox(width: size.width * 0.03),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: "TechHub Official Store",
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: ColorConstant.ratingStarColor),
                    SizedBox(width: 3),
                    TextContext(
                      text: "4.9 Positive Rating",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.labelTextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomButton(
            text: "Visit Store",
            outlined: true,
            height: 38,
            width: 100,
            fontSize: 12.5,
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              // TODO: navigate to seller storefront
            },
          ),
        ],
      ),
    );
  }

  /// ---------------- REVIEWS SECTION ----------------
  Widget _buildReviewsSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextContext(
              text: "Customer Reviews",
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            InkWell(
              onTap: () {
                // TODO: navigate to full reviews list
              },
              child: const TextContext(
                text: "View All",
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorConstant.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.016),

        // ---- Rating summary + distribution bars ----
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: const [
                TextContext(text: "4.8", fontSize: 32, fontWeight: FontWeight.w800),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: ColorConstant.ratingStarColor),
                    Icon(Icons.star_rounded, size: 16, color: ColorConstant.ratingStarColor),
                    Icon(Icons.star_rounded, size: 16, color: ColorConstant.ratingStarColor),
                    Icon(Icons.star_rounded, size: 16, color: ColorConstant.ratingStarColor),
                    Icon(Icons.star_half_rounded, size: 16, color: ColorConstant.ratingStarColor),
                  ],
                ),
              ],
            ),
            SizedBox(width: size.width * 0.05),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final double fraction = _ratingDistribution[star] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                          child: Text(
                            "$star",
                            style: const TextStyle(fontSize: 10.5, fontFamily: "Poppins", color: ColorConstant.labelTextColor),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 6,
                              backgroundColor: ColorConstant.borderColor,
                              valueColor: const AlwaysStoppedAnimation(ColorConstant.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        SizedBox(height: size.height * 0.02),
        for (final review in _reviews) ...[
          buildReviewCard(size, review),
          SizedBox(height: size.height * 0.014),
        ],
      ],
    );
  }

  Widget buildReviewCard(Size size, _ReviewItem review) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(color: review.avatarColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  review.initial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(text: review.name, fontSize: 13, fontWeight: FontWeight.w500),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: i < review.rating
                              ? ColorConstant.ratingStarColor
                              : ColorConstant.borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextContext(
                text: review.daysAgo,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: ColorConstant.placeholderColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextContext(
            text: review.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: ColorConstant.bodyTextColor,
            height: 1.5,
          ),
          if (review.hasPhoto) ...[
            const SizedBox(height: 10),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: ColorConstant.borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/pro7.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),            ),
          ],
        ],
      ),
    );
  }

  /// ---------------- RELATED PRODUCTS ----------------
  Widget _buildRelatedProducts(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextContext(
          text: "You May Also Like",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: size.height * 0.016),
        SizedBox(
          height: size.width * 0.46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _related.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.03),
            itemBuilder: (context, index) => buildRelatedProductCard(size, _related[index]),
          ),
        ),
      ],
    );
  }

  Widget buildRelatedProductCard(Size size, _RelatedProduct item) {
    final double cardWidth = size.width * 0.34;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: ColorConstant.blackColor.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: cardWidth * 0.85,
            width: double.infinity,
            color: ColorConstant.fieldFillColor,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                item.image,
                fit: BoxFit.contain,
              ),
            ),          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
                const SizedBox(height: 4),
                TextContext(
                  text: "\$${item.price.toStringAsFixed(2)}",
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- STICKY BOTTOM ACTION BAR ----------------
  Widget _buildBottomActionBar(BuildContext context, Size size) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.014),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          boxShadow: [
            BoxShadow(color: ColorConstant.blackColor.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Add to Cart",
                outlined: true,
                height: 52,
                icon: Icons.shopping_cart_outlined,
                iconSize: 18,
                onTap: () {
                  // TODO: call add-to-cart API with selected color/size/qty
                },
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: CustomButton(
                text: "Buy Now",
                height: 52,
                onTap: () {
                  Navigator.pushNamed(context, RouteName.checkoutAddress);
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pulsing dot used next to the "Only 4 left!" urgency text.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
      child: Container(
        height: 8,
        width: 8,
        decoration: const BoxDecoration(color: ColorConstant.orangeColor, shape: BoxShape.circle),
      ),
    );
  }
}

/// Local models — move to lib/model/ once wired to a real API.
class _ReviewItem {
  final String initial;
  final Color avatarColor;
  final String name;
  final String daysAgo;
  final int rating;
  final String text;
  final bool hasPhoto;

  const _ReviewItem({
    required this.initial,
    required this.avatarColor,
    required this.name,
    required this.daysAgo,
    required this.rating,
    required this.text,
    required this.hasPhoto,
  });
}

class _RelatedProduct {
  final String image;
  final String name;
  final double price;

  const _RelatedProduct({
    required this.image,
    required this.name,
    required this.price,
  });
}