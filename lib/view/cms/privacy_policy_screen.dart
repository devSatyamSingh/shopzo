// lib/view/privacy/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          text: 'Privacy Policy',
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
                  Row(
                    children: [
                      Icon(Icons.security_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      TextContext(
                        text: 'SECURITY FIRST',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  TextContext(
                    text: 'At Shopzo, we value your trust above all else.',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(.9),
                  ),
                  TextContext(
                    text: 'This policy explains how we collect, use, and protect your personal information within our multi-vendor marketplace.',
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                    color: Colors.white.withOpacity(.8),
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Last updated
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConstant.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: ColorConstant.placeholderColor, size: 16),
                  const SizedBox(width: 8),
                  TextContext(
                    text: 'Last updated: October 24, 2023',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorConstant.bodyTextColor,
                  ),
                  const Spacer(),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: ColorConstant.successColor.withOpacity(.12),
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: TextContext(
                  //     text: 'GDPR & CCPA Compliant',
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.w600,
                  //     color: ColorConstant.successColor,
                  //   ),
                  // ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.025),

            // Data Collection
            _buildPolicySection(
              title: 'Data Collection',
              icon: Icons.data_usage_rounded,
              content: 'We collect information that you provide directly to us when you create an account, browse our vendor catalog, or make a purchase.',
              bullets: [
                'Personal identifiers (Name, Email, Phone Number)',
                'Transaction data (Billing address, purchase history)',
                'Device Information (IP address, browser type, cookies)',
              ],
            ),

            SizedBox(height: size.height * 0.02),

            // How We Use Your Info
            _buildPolicySection(
              title: 'How We Use Your Info',
              icon: Icons.analytics_rounded,
              content: 'Your data is used strictly to enhance your shopping experience and ensure the security of our marketplace platform.',
              bulletTitle: 'Service Delivery',
              bulletSubtitle: 'Processing payments and coordinating deliveries with our vendors.',
              bulletTitle2: 'Personalization',
              bulletSubtitle2: 'Tailoring products and recommendations and search results to your preferences.',
            ),

            SizedBox(height: size.height * 0.02),

            // Your Rights
            _buildRightsSection(),

            SizedBox(height: size.height * 0.025),

            // Contact DPO
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
                      Icon(Icons.help_outline_rounded,
                          color: ColorConstant.primaryColor),
                      const SizedBox(width: 8),
                      TextContext(
                        text: 'Have questions about your data?',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.headlineTextColor,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  TextContext(
                    text: 'Our Data Protection Office is here to help you understand your privacy.',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.bodyTextColor,
                  ),
                  SizedBox(height: size.height * 0.012),
                  GestureDetector(
                    onTap: () {
                      // Navigate to contact DPO
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: ColorConstant.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: TextContext(
                          text: 'Contact DPO',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  Widget _buildPolicySection({
    required String title,
    required IconData icon,
    required String content,
    List<String>? bullets,
    String? bulletTitle,
    String? bulletSubtitle,
    String? bulletTitle2,
    String? bulletSubtitle2,
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
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: ColorConstant.primaryColor, size: 20),
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
            height: 1.5,
            color: ColorConstant.bodyTextColor,
          ),
          if (bullets != null) ...[
            SizedBox(height: 10),
            ...bullets.map((bullet) => Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 5, color: ColorConstant.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextContext(
                      text: bullet,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.bodyTextColor,
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (bulletTitle != null) ...[
            SizedBox(height: 10),
            _buildBulletItem(icon: Icons.check_circle_rounded, title: bulletTitle, subtitle: bulletSubtitle!),
          ],
          if (bulletTitle2 != null) ...[
            SizedBox(height: 10),
            _buildBulletItem(icon: Icons.check_circle_rounded, title: bulletTitle2, subtitle: bulletSubtitle2!),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ColorConstant.primaryColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextContext(
                text: title,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
              TextContext(
                text: subtitle,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: ColorConstant.bodyTextColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightsSection() {
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
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: ColorConstant.successColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.verified_user_rounded,
                    color: ColorConstant.successColor, size: 20),
              ),
              const SizedBox(width: 10),
              TextContext(
                text: 'Your Rights',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
              ),
            ],
          ),
          SizedBox(height: 10),
          TextContext(
            text: 'You have complete control over your data. Under global privacy laws, you are entitled to several rights regarding your personal information.',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: ColorConstant.bodyTextColor,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildRightChip('Right to Access', ColorConstant.primaryColor)),
              const SizedBox(width: 8),
              Expanded(child: _buildRightChip('Right to Erasure', ColorConstant.errorColor)),
              const SizedBox(width: 8),
              Expanded(child: _buildRightChip('Right to Rectification', ColorConstant.successColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: TextContext(
        text: text,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}