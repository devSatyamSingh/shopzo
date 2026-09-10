import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shopzo/view/home/search_screen.dart';
import '../../../res/color_constant.dart';
import '../../routes/route_name.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onCameraTap;

  const HomeSearchBar({super.key, this.onTap, this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, RouteName.search);
        },
        child: Container(
          height: size.height * 0.058,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: ColorConstant.fieldFillColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: ColorConstant.primaryColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'home.search_placeholder'.tr(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    color: ColorConstant.placeholderColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // GestureDetector(
              //   onTap: onCameraTap,
              //   child: Icon(Icons.camera_alt_outlined,
              //       color: ColorConstant.primaryColor, size: 21),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}