import 'package:flutter/material.dart';
import 'package:shopzo/view/home/search_screen.dart';
import '../../../res/color_constant.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SearchScreen(),
            ),
          );
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
                  color: ColorConstant.placeholderColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search for products, brands and more',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    color: ColorConstant.placeholderColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onCameraTap,
                child: Icon(Icons.camera_alt_outlined,
                    color: ColorConstant.primaryColor, size: 21),
              ),
            ],
          ),
        ),
      ),
    );
  }
}