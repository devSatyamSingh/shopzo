import 'package:flutter/material.dart';
import '../../model/top_product_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

/// Top Picks ke liye dedicated, minimal card — sirf IMAGE + NAME + PRICE.
/// Ab TopProductModel use karta hai (TopPicksViewModel se aata hai),
/// taaki home section aur "See All" screen dono EK HI data type/source
/// consume karein — koi mismatch nahi.
class TopPickCard extends StatelessWidget {
  final TopProductModel product;
  final double width;
  final VoidCallback? onTap;

  const TopPickCard({
    super.key,
    required this.product,
    required this.width,
    this.onTap,
  });

  bool get _isNetworkImage => (product.image ?? '').startsWith('http');

  Widget _buildImage(double imageHeight, double radius) {
    Widget fallback() => Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorConstant.fieldFillColor, ColorConstant.primaryLight.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: ColorConstant.placeholderColor, size: imageHeight * 0.24),
    );

    final img = product.image;
    if (img == null || img.isEmpty) return fallback();

    if (_isNetworkImage) {
      return Image.network(
        img,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: imageHeight,
            width: double.infinity,
            color: ColorConstant.fieldFillColor,
            alignment: Alignment.center,
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor),
            ),
          );
        },
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    return Image.asset(
      img,
      height: imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardRadius = width * 0.06;
    final double imageRadius = width * 0.05;
    final double imageHeight = width * 0.9;
    final double textPad = width * 0.05;
    final double nameFontSize = size.width * 0.029;
    final double priceFontSize = size.width * 0.025;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(.06),
              blurRadius: 16,
              offset: Offset(0, size.height * 0.006),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- IMAGE ----------------
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(imageRadius),
                topRight: Radius.circular(imageRadius),
              ),
              child: _buildImage(imageHeight, imageRadius),
            ),

            SizedBox(height: size.height * 0.008),

            // ---------------- NAME ----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: textPad),
              child: TextContext(
                text: product.name,
                fontSize: nameFontSize,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: ColorConstant.headlineTextColor,
              ),
            ),

            SizedBox(height: size.height * 0.005),

            // ---------------- PRICE ----------------
            Padding(
              padding: EdgeInsets.only(left: textPad, right: textPad, bottom: size.height * 0.012),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.height * 0.004,
                ),
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor,
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Text(
                  '₹${product.displayPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: priceFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Poppins',
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