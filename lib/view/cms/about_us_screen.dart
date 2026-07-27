// lib/view/about/about_us_screen.dart
import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          text: 'About Shopzo',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Brand
            Center(
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'S',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  TextContext(
                    text: 'Shopzo',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.headlineTextColor,
                  ),
                  TextContext(
                    text: 'Redefining the art of modern commerce',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.placeholderColor,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorConstant.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: 'Our Mission',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.headlineTextColor,
                  ),
                  SizedBox(height: size.height * 0.01),
                  TextContext(
                    text: 'To empower a global community of vendors and shoppers through a seamless, transparent, and high-performance marketplace that celebrates quality above all else.',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: ColorConstant.bodyTextColor,
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.025),

            // Core Pillars
            TextContext(
              text: 'Our Core Pillars',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),

            SizedBox(height: size.height * 0.015),

            _buildPillarCard(
              icon: Icons.people_rounded,
              title: 'Community',
              description: 'We believe that community is the foundation of commerce. We are committed to building relationships with our vendors and shoppers.',
              color: ColorConstant.primaryColor,
            ),
            SizedBox(height: size.height * 0.012),
            _buildPillarCard(
              icon: Icons.visibility_rounded,
              title: 'Transparency',
              description: 'We are committed to providing our community with the most transparent marketplace possible.',
              color: ColorConstant.orangeColor,
            ),
            SizedBox(height: size.height * 0.012),
            _buildPillarCard(
              icon: Icons.lightbulb_rounded,
              title: 'Innovation',
              description: 'We are committed to constantly innovating our marketplace to meet the needs of our community.',
              color: ColorConstant.successColor,
            ),

            SizedBox(height: size.height * 0.025),

            // Journey Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstant.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline_rounded,
                          color: ColorConstant.primaryColor),
                      const SizedBox(width: 8),
                      TextContext(
                        text: 'Our Journey',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.headlineTextColor,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  TextContext(
                    text: 'Shopzo was founded with a single goal: making shopping easier and more enjoyable. Since its inception, Shopzo has grown to include over 200 vendors and 1200+ shoppers. We are committed to providing our community with the best shopping experience possible.',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: ColorConstant.bodyTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConstant.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: title,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.headlineTextColor,
                ),
                SizedBox(height: 15),
                TextContext(
                  text: description,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: ColorConstant.bodyTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}