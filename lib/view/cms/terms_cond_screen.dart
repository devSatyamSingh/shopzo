// lib/view/terms/terms_conditions_screen.dart
import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          text: 'Terms & Conditions',
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
                color: ColorConstant.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: 'Shopzo Terms of Service',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  SizedBox(height: size.height * 0.008),
                  TextContext(
                    text: 'Last Updated: October 24, 2023',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(.8),
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.025),

            // 1. User Agreement
            _buildSection(
              number: '1',
              title: 'User Agreement',
              content: 'By accessing or using the Shopzo marketplace, you agree to be bound by these Terms and Conditions and our Privacy Policy. These terms constitute a legally binding agreement between you and Shopzo regarding your use of our platform, services, and applications. If you do not agree to all the terms and conditions of this agreement, then you may not access the website or use any services. We reserve the right to update, change or replace any part of these Terms by posting updates to our website.',
            ),

            SizedBox(height: size.height * 0.02),

            // 2. Account Responsibilities
            _buildSection(
              number: '2',
              title: 'Account Responsibilities',
              content: 'To access certain features of the platform, you must register for an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete.',
              highlight: 'Key Responsibility:',
              highlightContent: 'You are responsible for safeguarding your password and for any activities or actions under your account. Shopzo cannot and will not be liable for any loss or damage arising from your failure to comply with the above. We reserve the right to suspend or terminate your account if any information provided proves to be inaccurate, fraudulent, or in violation of our community standards.',
            ),

            SizedBox(height: size.height * 0.02),

            // 3. Intellectual Property
            _buildSection(
              number: '3',
              title: 'Intellectual Property',
              content: 'The service and its original content (excluding content provided by users), features, and functionality are and will remain the exclusive property of Shopzo and its licensors. Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of Shopzo. Users retain ownership of the content they post, but grant Shopzo a worldwide, non-exclusive, royalty-free license to use, copy, reproduce, process, adapt, modify, publish, and transmit such content across all media channels.',
            ),

            SizedBox(height: size.height * 0.02),

            // 4. Payments and Fees
            _buildSection(
              number: '4',
              title: 'Payments and Fees',
              content: 'Shopzo uses third-party payment processors to handle financial transactions. By purchasing through the platform, you agree to provide valid payment information and authorize us to charge the specified amount.',
            ),

            SizedBox(height: size.height * 0.02),

            // 5. Limitation of Liability
            _buildSection(
              number: '5',
              title: 'Limitation of Liability',
              content: 'In no event shall Shopzo, nor its directors, employees, partners, or agents, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
            ),

            SizedBox(height: size.height * 0.03),

            // Contact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstant.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: 'Have questions?',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.headlineTextColor,
                  ),
                  SizedBox(height: size.height * 0.005),
                  TextContext(
                    text: 'If you have any questions about these Terms, please contact our legal team.',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.bodyTextColor,
                  ),
                  SizedBox(height: size.height * 0.01),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        TextContext(
                          text: 'legal@shopzo.com',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
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

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    String? highlight,
    String? highlightContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.primaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextContext(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
            ],
          ),
          SizedBox(height: 10),
          TextContext(
            text: content,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: ColorConstant.bodyTextColor,
          ),
          if (highlight != null) ...[
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorConstant.orangeLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContext(
                    text: highlight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.orangeColor,
                  ),
                  TextContext(
                    text: highlightContent!,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: ColorConstant.bodyTextColor,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}