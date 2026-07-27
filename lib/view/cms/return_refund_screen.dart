// lib/view/returns/return_refund_screen.dart
import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class ReturnRefundScreen extends StatelessWidget {
  const ReturnRefundScreen({super.key});

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
          text: 'Return & Refund',
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
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorConstant.primaryColor,
                    ColorConstant.primaryColor.withOpacity(.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: 'Hassle-Free Returns',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  SizedBox(height: size.height * 0.008),
                  TextContext(
                    text: 'We want you to love your purchase. If you\'re not entirely satisfied, our return process is designed to be simple and transparent.',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: Colors.white.withOpacity(.9),
                  ),
                  SizedBox(height: size.height * 0.015),
                  Row(
                    children: [
                      _buildFeatureChip(
                        icon: Icons.calendar_today_rounded,
                        text: '30 Days',
                        subtitle: 'Generous return window',
                      ),
                      const SizedBox(width: 8),
                      _buildFeatureChip(
                        icon: Icons.local_shipping_rounded,
                        text: 'Easy Pickup',
                        subtitle: 'Doorstep collection',
                      ),
                      const SizedBox(width: 8),
                      _buildFeatureChip(
                        icon: Icons.payments_rounded,
                        text: 'Quick Refund',
                        subtitle: '3-5 business days',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.025),

            // Satisfaction message
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorConstant.successColor.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorConstant.successColor.withOpacity(.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded,
                      color: ColorConstant.successColor),
                  const SizedBox(width: 8),
                  TextContext(
                    text: 'Your satisfaction is our priority.',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.successColor,
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.025),

            // How to initiate a return
            TextContext(
              text: 'How to initiate a return',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),

            SizedBox(height: size.height * 0.015),

            _buildStepCard(
              step: '1',
              title: 'Select Order',
              description: 'Go to your \'Account\' and find the order containing the item you want to return.',
              icon: Icons.shopping_bag_rounded,
            ),
            SizedBox(height: size.height * 0.012),
            _buildStepCard(
              step: '2',
              title: 'Reason for Return',
              description: 'Choose a reason from the dropdown menu. This helps us improve our service and vendor quality.',
              icon: Icons.list_alt_rounded,
            ),
            SizedBox(height: size.height * 0.012),
            _buildStepCard(
              step: '3',
              title: 'Pack & Label',
              description: 'Place items in original packaging if possible. Download and print the return label provided.',
              icon: Icons.local_shipping_rounded,
            ),
            SizedBox(height: size.height * 0.012),
            _buildStepCard(
              step: '4',
              title: 'Drop off or Pickup',
              description: 'Schedule a free home pickup or drop it off at any authorized partner location.',
              icon: Icons.storefront_rounded,
            ),

            SizedBox(height: size.height * 0.025),

            // FAQs
            TextContext(
              text: 'Frequently Asked Questions',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),

            SizedBox(height: size.height * 0.012),

            _buildFAQItem(
              question: 'What items are non-returnable?',
              answer: 'Items such as perishable goods, custom products, and personal care items cannot be returned due to hygiene and safety reasons.',
            ),
            SizedBox(height: size.height * 0.008),
            _buildFAQItem(
              question: 'When will I get my refund?',
              answer: 'Refunds are processed within 3-5 business days after we receive and inspect the returned item. You\'ll receive a confirmation email once processed.',
            ),
            SizedBox(height: size.height * 0.008),
            _buildFAQItem(
              question: 'Can I exchange for a different size?',
              answer: 'Yes, we offer free size exchanges. Simply initiate a return and place a new order for the correct size. Contact support for assistance.',
            ),

            SizedBox(height: size.height * 0.025),

            // Contact Support
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstant.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextContext(
                          text: 'Still need help?',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.headlineTextColor,
                        ),
                        TextContext(
                          text: 'Our customer support team is available 24/7 to assist with your returns.',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorConstant.bodyTextColor,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to support
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorConstant.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextContext(
                        text: 'Contact Support',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String text,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            TextContext(
              text: text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            TextContext(
              text: subtitle,
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
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
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: ColorConstant.primaryColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: TextContext(
              text: step,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorConstant.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: ColorConstant.primaryColor, size: 16),
                    const SizedBox(width: 6),
                    TextContext(
                      text: title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),
                  ],
                ),
                SizedBox(height: 10),
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

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConstant.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded,
                  color: ColorConstant.primaryColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextContext(
                  text: question,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.headlineTextColor,
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: ColorConstant.placeholderColor, size: 20),
            ],
          ),
          SizedBox(height: 10),
          TextContext(
            text: answer,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: ColorConstant.bodyTextColor,
          ),
        ],
      ),
    );
  }
}