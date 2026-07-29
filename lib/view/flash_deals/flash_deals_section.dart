// lib/view/home/flash_deals_section.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopzo/view/home/product_card.dart';
import 'package:shopzo/model/product_model.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import 'flash_deals_screen.dart';

class FlashDealsSection extends StatefulWidget {
  final List<ProductModel> products;
  final Duration initialDuration;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<ProductModel>? onProductTap;

  const FlashDealsSection({
    super.key,
    required this.products,
    this.initialDuration = const Duration(hours: 2, minutes: 45, seconds: 18),
    this.onSeeAllTap,
    this.onProductTap,
  });

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
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

  void _navigateToFlashDealsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashDealsScreen(
          products: widget.products,
          initialDuration: _remaining,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Row(
            children: [
              TextContext(
                text: 'Flash Deals',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
              const SizedBox(width: 8),

              // ---- countdown chip ----
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorConstant.errorColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 13, color: ColorConstant.errorColor),
                    const SizedBox(width: 4),
                    Text(
                      '${_two(hours)}:${_two(minutes)}:${_two(seconds)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.errorColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: widget.onSeeAllTap ?? () => _navigateToFlashDealsScreen(context),
                child: TextContext(
                  text: 'See All',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.015),

        SizedBox(
          height: size.height * 0.24,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            itemCount: widget.products.length,
            separatorBuilder: (_, __) => SizedBox(width: size.width * 0.035),
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return ProductCard(
                product: product,
                width: size.width * 0.4,
                variant: ProductCardVariant.deal,
                onTap: () => widget.onProductTap?.call(product),
              );
            },
          ),
        ),
      ],
    );
  }
}