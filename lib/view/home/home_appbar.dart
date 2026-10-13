// lib/view/home/home_appbar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../localization/language_provider.dart';

class HomeAppBar extends StatelessWidget {
  final String location;
  final bool hasNotification;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;

  const HomeAppBar({
    super.key,
    this.location = 'Mumbai 400001',
    this.hasNotification = true,
    this.onLocationTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();


    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.012,
      ),
      child: Row(
        children: [
          // ---------------- LOCATION ----------------
          Expanded(
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 18, color: ColorConstant.primaryColor),
                  const SizedBox(width: 5),
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: ColorConstant.labelTextColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${'home.deliver_to'.tr()}  ',
                          ),
                          TextSpan(
                            text: location,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.headlineTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: ColorConstant.headlineTextColor),
                ],
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          // // ---------------- NOTIFICATION BELL ----------------
          // GestureDetector(
          //   onTap: onNotificationTap,
          //   child: Stack(
          //     clipBehavior: Clip.none,
          //     children: [
          //       Container(
          //         height: 42,
          //         width: 42,
          //         decoration: BoxDecoration(
          //           color: ColorConstant.primaryLight,
          //           shape: BoxShape.circle,
          //         ),
          //         alignment: Alignment.center,
          //         child: Icon(
          //           Icons.notifications_none_rounded,
          //           color: ColorConstant.headlineTextColor,
          //           size: 22,
          //         ),
          //       ),
          //       if (hasNotification)
          //         Positioned(
          //           top: 2,
          //           right: 3,
          //           child: Container(
          //             height: 9,
          //             width: 9,
          //             decoration: BoxDecoration(
          //               color: ColorConstant.orangeColor,
          //               shape: BoxShape.circle,
          //               border: Border.all(
          //                 color: ColorConstant.whiteColor,
          //                 width: 1.6,
          //               ),
          //             ),
          //           ),
          //         ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}