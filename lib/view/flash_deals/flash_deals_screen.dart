// lib/view/home/flash_deals_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopzo/view/home/product_card.dart';
import 'package:shopzo/model/product/product_model.dart';
import '../../../../res/color_constant.dart';
import '../../../../res/text_context.dart';

class FlashDealsScreen extends StatefulWidget {
  final List<ProductModel> products;
  final Duration initialDuration;

  const FlashDealsScreen({
    super.key,
    required this.products,
    this.initialDuration = const Duration(hours: 2, minutes: 45, seconds: 18),
  });

  @override
  State<FlashDealsScreen> createState() => _FlashDealsScreenState();
}

class _FlashDealsScreenState extends State<FlashDealsScreen> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;
    final cardWidth = (size.width - size.width * 0.05 * 2 - size.width * 0.04) / 2;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: ColorConstant.headlineTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextContext(
          text: 'Flash Deals',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: ColorConstant.whiteColor,
              border: Border(
                bottom: BorderSide(
                  color: ColorConstant.borderColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 20, color: ColorConstant.errorColor),
                const SizedBox(width: 8),
                TextContext(
                  text: 'Time Left:',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.bodyTextColor,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorConstant.errorColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_two(hours)}:${_two(minutes)}:${_two(seconds)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.errorColor,
                    ),
                  ),
                ),
                const Spacer(),
                TextContext(
                  text: '${widget.products.length} items',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.placeholderColor,
                ),
              ],
            ),
          ),
        ),
      ),
      body: widget.products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_off_rounded,
              size: 64,
              color: ColorConstant.placeholderColor,
            ),
            const SizedBox(height: 16),
            TextContext(
              text: 'No Flash Deals Available',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstant.bodyTextColor,
            ),
            TextContext(
              text: 'Check back later for great offers!',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorConstant.placeholderColor,
            ),
          ],
        ),
      )
          : Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: size.height * 0.02,
            crossAxisSpacing: size.width * 0.04,
            childAspectRatio: cardWidth / (size.height * 0.28),
          ),
          itemCount: widget.products.length,
          itemBuilder: (context, index) {
            final product = widget.products[index];
            return ProductCard(
              product: product,
              width: cardWidth,
              variant: ProductCardVariant.deal,
              onTap: () {
                // Navigate to product details
                // Navigator.pushNamed(context, RouteName.productDetail);
              },
            );
          },
        ),
      ),
    );
  }
}