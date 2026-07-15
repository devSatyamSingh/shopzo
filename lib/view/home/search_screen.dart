import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';

// ==============================================================
// Search Screen
// ==============================================================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<String> recentSearches = [
    "Wireless Earbuds",
    "Running Shoes",
    "OLED TV",
  ];

  final List<String> discoverList = [
    "Smartphones",
    "4K TVs",
    "Formal Shoes",
    "Summer Wear",
    "Skincare",
    "Laptops",
    "Gaming Consoles",
  ];

  final List<Map<String, dynamic>> products = [
    {
      "name": "Pro Audio Max",
      "category": "Electronics",
      "price": "\$299.00",
      "image":
      "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=700",
      "fav": true,
    },
    {
      "name": "AeroRun 5.0",
      "category": "Footwear",
      "price": "\$145.50",
      "image":
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700",
      "fav": false,
    },
  ];

  void _clearRecentSearches() {
    setState(() => recentSearches.clear());
  }

  void _removeRecentSearch(int index) {
    setState(() => recentSearches.removeAt(index));
  }

  void _onDiscoverTap(String item) {
    searchController.text = item;
  }

  void _toggleFavorite(int index) {
    setState(() {
      products[index]['fav'] = !products[index]['fav'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ============ APP BAR ============
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * .045,
                vertical: size.height * .009,
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 42,
                      width: 42,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: ColorConstant.headlineTextColor,
                        size: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: TextContext(
                        text: "Search",
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),

            // ============ SEARCH BAR ============
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * .055),
              child: CustomTextField(
                controller: searchController,
                filled: true,
                showBorder: false,
                fillColor: const Color(0xffF4F6FB),
                borderRadius: 18,
                contentPadding: 14,
                hintText: "Search for products...",
                hintStyle: GoogleFonts.poppins(
                  color: ColorConstant.placeholderColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ColorConstant.placeholderColor,
                  size: 24,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: ColorConstant.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 14, left: 8),
                        child: Icon(
                          Icons.mic_none_rounded,
                          color: ColorConstant.primaryColor,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * .018),

            // ============ BODY ============
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * .057),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== RECENT SEARCHES ==========
                    if (recentSearches.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextContext(
                            text: "Recent Searches",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          InkWell(
                            onTap: _clearRecentSearches,
                            child: TextContext(
                              text: "Clear All",
                              fontSize: 13,
                              color: ColorConstant.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * .018),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentSearches.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Icon(
                                Icons.history,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextContext(
                                  text: recentSearches[index],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              InkWell(
                                onTap: () => _removeRecentSearch(index),
                                child: Icon(
                                  Icons.close,
                                  size: 17,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: size.height * .024),
                    ],
                    // ========== DISCOVER MORE ==========
                    TextContext(
                      text: "Discover More",
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: size.height * .02),
                    Wrap(
                      spacing: size.width * .02,
                      runSpacing: size.height * .01,
                      children: discoverList.map((item) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => _onDiscoverTap(item),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * .045,
                              vertical: size.height * .01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TextContext(
                              text: item,
                              fontSize: size.width * .028,
                              fontWeight: FontWeight.w500,
                              color: ColorConstant.headlineTextColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: size.height * .02),
                    // ========== RECOMMENDED ==========
                    TextContext(
                      text: "Recommended for You",
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: size.height * .02),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: size.height * .018,
                        crossAxisSpacing: size.width * .034,
                        childAspectRatio: .75,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(size, product, index);
                      },
                    ),
                    SizedBox(height: size.height * .032),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ PRODUCT CARD ============
  Widget _buildProductCard(Size size, Map<String, dynamic> product, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 8,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: Image.network(
                    product["image"],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: size.height * .01,
                  right: size.width * .02,
                  child: InkWell(
                    onTap: () => _toggleFavorite(index),
                    child: Container(
                      height: size.width * .09,
                      width: size.width * .09,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product["fav"]
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: product["fav"] ? Colors.red : Colors.grey,
                        size: size.width * .045,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product Details
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * .028,
                vertical: size.height * .01,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: product["name"],
                    fontSize: size.width * .040,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: size.height * .003),
                  TextContext(
                    text: product["category"],
                    fontSize: size.width * .029,
                    color: Colors.grey,
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      TextContext(
                        text: product["price"],
                        fontSize: size.width * .038,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.primaryColor,
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          // Add to cart action
                        },
                        child: Container(
                          height: size.width * .080,
                          width: size.width * .080,
                          decoration: BoxDecoration(
                            color: ColorConstant.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: size.width * .05,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}