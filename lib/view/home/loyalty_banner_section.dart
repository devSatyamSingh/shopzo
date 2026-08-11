import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';

class LoyaltyBannerSection extends StatelessWidget {
  final VoidCallback? onTap;

  const LoyaltyBannerSection({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final title = [
      'home.loyalty_title_line1'.tr(),
      'home.loyalty_title_line2'.tr(),
    ];

    final subtitle = 'home.loyalty_subtitle'.tr();
    final lines = title;

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