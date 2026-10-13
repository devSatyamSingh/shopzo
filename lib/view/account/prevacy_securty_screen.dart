// privacy_security_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConstant.whiteColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: ColorConstant.headlineTextColor,
          size: _responsiveSize(context, 20, 24),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: TextContext(
        text: 'Privacy & Security',
        fontSize: _responsiveSize(context, 18, 22),
        fontWeight: FontWeight.w600,
        color: ColorConstant.headlineTextColor,
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_responsiveSize(context, 16, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section - Your Trust is Our Priority
          _buildHeroSection(context),

          SizedBox(height: _responsiveSize(context, 24, 32)),

          // Account Security Section
          _buildSection(
            context: context,
            title: 'ACCOUNT SECURITY',
            items: [
              _buildListItem(
                context: context,
                icon: Icons.shield_outlined,
                title: 'Two-Step Verification',
                subtitle: 'Add an extra layer of security',
                iconColor: ColorConstant.primaryColor,
              ),
              _buildListItem(
                context: context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your security credentials',
                iconColor: ColorConstant.primaryColor,
              ),
              _buildListItem(
                context: context,
                icon: Icons.history,
                title: 'Login Activity',
                subtitle: 'Monitor where you are logged in',
                iconColor: ColorConstant.primaryColor,
              ),
            ],
          ),

          SizedBox(height: _responsiveSize(context, 24, 32)),

          // Data Privacy Section
          _buildSection(
            context: context,
            title: 'DATA PRIVACY',
            items: [
              _buildListItem(
                context: context,
                icon: Icons.person_2_outlined,
                title: 'Personalized Ads',
                subtitle: 'See products based on your interests',
                iconColor: ColorConstant.infoColor,
              ),
              _buildListItem(
                context: context,
                icon: Icons.share_outlined,
                title: 'Data Sharing with Partners',
                subtitle: 'Allow third-party data processing',
                iconColor: ColorConstant.infoColor,
              ),
              _buildListItem(
                context: context,
                icon: Icons.cloud_download_outlined,
                title: 'Download My Data',
                subtitle: 'Get a copy of your personal data archive',
                iconColor: ColorConstant.infoColor,
              ),
            ],
          ),

          SizedBox(height: _responsiveSize(context, 24, 32)),

          // Legal & Transparency Section
          _buildSection(
            context: context,
            title: 'LEGAL & TRANSPARENCY',
            items: [
              _buildLegalItem(
                context: context,
                icon: Icons.gavel,
                title: 'Privacy Policy',
                iconColor: ColorConstant.warningColor,
              ),
              _buildLegalItem(
                context: context,
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                iconColor: ColorConstant.warningColor,
              ),
              _buildLegalItem(
                context: context,
                icon: Icons.cookie_outlined,
                title: 'Cookie Policy',
                iconColor: ColorConstant.warningColor,
              ),
            ],
          ),

          SizedBox(height: _responsiveSize(context, 24, 32)),

          // Account Management Section
          _buildSection(
            context: context,
            title: 'ACCOUNT MANAGEMENT',
            items: [
              _buildListItem(
                context: context,
                icon: Icons.pause_circle_outline,
                title: 'Deactivate Account',
                subtitle: 'Temporarily disable your profile',
                iconColor: ColorConstant.warningColor,
              ),
              _buildListItem(
                context: context,
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently remove all your data',
                iconColor: ColorConstant.errorColor,
              ),
            ],
          ),

          SizedBox(height: _responsiveSize(context, 32, 40)),

          // Encrypted & Secure Footer
          _buildEncryptionBanner(context),

          SizedBox(height: _responsiveSize(context, 16, 24)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_responsiveSize(context, 20, 28)),
      decoration: BoxDecoration(
        gradient: ColorConstant.primaryGradient,
        borderRadius: BorderRadius.circular(_responsiveSize(context, 16, 20)),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstant.whiteColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: ColorConstant.whiteColor,
                  size: _responsiveSize(context, 24, 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextContext(
                  text: 'Your Trust is Our Priority',
                  fontSize: _responsiveSize(context, 18, 22),
                  fontWeight: FontWeight.w700,
                  color: ColorConstant.whiteColor,
                ),
              ),
            ],
          ),
          SizedBox(height: _responsiveSize(context, 8, 12)),
          TextContext(
            text: 'Manage your account security, personal data preferences, and legal transparency in one secure location.',
            fontSize: _responsiveSize(context, 13, 15),
            fontWeight: FontWeight.w400,
            color: ColorConstant.whiteColor.withOpacity(0.9),
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: _responsiveSize(context, 12, 16),
            left: _responsiveSize(context, 4, 8),
          ),
          child: TextContext(
            text: title,
            fontSize: _responsiveSize(context, 12, 14),
            fontWeight: FontWeight.w700,
            color: ColorConstant.labelTextColor,
            letterSpacing: 1.2,
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final padding = isSmallScreen ? 12.0 : (isLargeScreen ? 20.0 : 16.0);
    final iconSize = isSmallScreen ? 20.0 : (isLargeScreen ? 28.0 : 24.0);
    final titleSize = isSmallScreen ? 14.0 : (isLargeScreen ? 17.0 : 16.0);
    final subtitleSize = isSmallScreen ? 11.0 : (isLargeScreen ? 14.0 : 13.0);

    return Container(
      margin: EdgeInsets.only(bottom: _responsiveSize(context, 8, 12)),
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(_responsiveSize(context, 12, 14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: ColorConstant.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(_responsiveSize(context, 12, 14)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: iconSize + 12,
                height: iconSize + 12,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_responsiveSize(context, 10, 12)),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
              SizedBox(width: _responsiveSize(context, 12, 16)),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(
                      text: title,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),
                    SizedBox(height: _responsiveSize(context, 2, 4)),
                    TextContext(
                      text: subtitle,
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.bodyTextColor,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: ColorConstant.labelTextColor,
                size: _responsiveSize(context, 20, 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final padding = isSmallScreen ? 12.0 : (isLargeScreen ? 20.0 : 16.0);
    final iconSize = isSmallScreen ? 20.0 : (isLargeScreen ? 28.0 : 24.0);
    final titleSize = isSmallScreen ? 14.0 : (isLargeScreen ? 17.0 : 16.0);

    return Container(
      margin: EdgeInsets.only(bottom: _responsiveSize(context, 8, 12)),
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(_responsiveSize(context, 12, 14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: ColorConstant.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(_responsiveSize(context, 12, 14)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: iconSize + 12,
                height: iconSize + 12,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_responsiveSize(context, 10, 12)),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
              SizedBox(width: _responsiveSize(context, 12, 16)),

              // Content
              Expanded(
                child: TextContext(
                  text: title,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.headlineTextColor,
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: ColorConstant.labelTextColor,
                size: _responsiveSize(context, 20, 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncryptionBanner(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(_responsiveSize(context, 16, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstant.successColor.withOpacity(0.1),
            ColorConstant.successColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_responsiveSize(context, 14, 18)),
        border: Border.all(
          color: ColorConstant.successColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConstant.successColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.verified_outlined,
              color: ColorConstant.successColor,
              size: _responsiveSize(context, 24, 28),
            ),
          ),
          SizedBox(width: _responsiveSize(context, 12, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(
                  text: 'Encrypted & Secure',
                  fontSize: _responsiveSize(context, 14, 16),
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.successColor,
                ),
                SizedBox(height: _responsiveSize(context, 2, 4)),
                TextContext(
                  text: 'All your transactions and personal data are protected by bank-grade 256-bit encryption.',
                  fontSize: _responsiveSize(context, 12, 14),
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.bodyTextColor,
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for responsive sizing
  double _responsiveSize(BuildContext context, double small, double large) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 360) return small;
    if (screenWidth >= 600) return large;
    final t = (screenWidth - 360) / (600 - 360);
    return small + (large - small) * t;
  }
}