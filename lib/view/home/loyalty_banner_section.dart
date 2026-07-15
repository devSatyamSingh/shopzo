import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';

class LoyaltyBannerSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const LoyaltyBannerSection({
    super.key,
    this.title = 'EXCLUSIVE LOYALTY REWARDS\nUP TO ₹500 CASHBACK',
    this.subtitle = 'On all UPI transactions above ₹1,999',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final lines = title.split('\n');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.015,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.022,
          ),
          decoration: BoxDecoration(
            gradient: ColorConstant.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.primaryColor.withOpacity(.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -10,
                top: -1,
                child: Icon(Icons.card_giftcard_rounded,
                    size: 75, color: Colors.white.withOpacity(.08)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lines.isNotEmpty)
                    Text(
                      lines[0],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  if (lines.length > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      lines[1],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}