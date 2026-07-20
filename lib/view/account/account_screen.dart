import 'package:flutter/material.dart';
import 'package:shopzo/view/account/coupons_screen.dart';
import 'package:shopzo/view/order/order_list_screen.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../address/address_list_screen.dart';
import '../payment/payment_methods_screen.dart';
import '../profile/profile_information_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'help_center_screen.dart';

/// Shopzo — Account / Profile screen.
/// All tap callbacks are wired but left empty — plug in your
/// Navigator.pushNamed(context, RouteName.xxx) calls as you build
/// each destination screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  //  replace with real user data (provider / bloc / auth service)
  static const String _name = 'Satyam Singh';
  static const String _email = 'satyam@gmail.com';
  static const String _memberSince = 'Member since Jan 2024';
  static const String _avatarUrl = 'assets/images/pro12.jpg';
  static const String _appVersion = 'Shopzo v2.4.1';

  void _onEditAvatar() {
    //  open image picker / edit profile photo
  }

  void _onOrdersTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.myOrders);
  }
  void _onWishlistTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.wishlist);
  }
  void _onCouponsTap(BuildContext context)  {
    Navigator.pushNamed(context, RouteName.coupons);

  }
  void _onHelpCenterTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.helpSupport);

  }

  void _onProfileInfoTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.profileInformation);
  }
  void _onSavedAddressesTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.addressList);

  }
  void _onPaymentMethodsTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.paymentMethods);

  }
  void _onNotificationSettingsTap() {}
  void _onPrivacySecurityTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.PrivacySecurity);
  }

  void _onAboutTap() {}
  void _onTermsTap() {}
  void _onPrivacyPolicyTap() {}
  void _onReturnPolicyTap() {}

  void _onLogoutTap(BuildContext context) {
    //  clear session/token, then:
    // Navigator.pushNamedAndRemoveUntil(context, RouteName.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.053,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- PROFILE HEADER ----------------
              _ProfileHeader(
                avatarUrl: _avatarUrl,
                name: _name,
                email: _email,
                memberSince: _memberSince,
                onEditAvatar: _onEditAvatar,
              ),

              SizedBox(height: size.height * 0.03),

              // ---------------- QUICK ACTION GRID ----------------
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Orders',
                      subtitle: 'Track your packages',
                      onTap: () => _onOrdersTap(context),
                    ),
                  ),
                  SizedBox(width: size.width * 0.035),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.favorite_rounded,
                      title: 'Wishlist',
                      subtitle: 'Your favorite items',
                      onTap: () => _onWishlistTap(context),                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.018),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.confirmation_num_rounded,
                      title: 'Coupons',
                      subtitle: 'Exclusive offers',
                      onTap: () => _onCouponsTap(context),
                    ),
                  ),
                  SizedBox(width: size.width * 0.035),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.support_agent_rounded,
                      title: 'Help Center',
                      subtitle: 'Customer support',
                      onTap: () => _onHelpCenterTap(context),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),

              // ---------------- ACCOUNT SETTINGS ----------------
              const _SectionLabel(text: 'ACCOUNT SETTINGS'),
              SizedBox(height: size.height * 0.012),
              _SettingsCard(
                tiles: [
                  _SettingsTileData(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile Information',
                    subtitle: 'Name, Email, Phone',
                    onTap: () => _onProfileInfoTap(context),
                  ),
                  _SettingsTileData(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Manage delivery locations',
                    onTap: () => _onSavedAddressesTap(context),
                  ),
                  _SettingsTileData(
                    icon: Icons.credit_card_rounded,
                    title: 'Payment Methods',
                    subtitle: 'Saved cards and UPI',
                    onTap: () => _onPaymentMethodsTap(context),

                  ),
                  // _SettingsTileData(
                  //   icon: Icons.notifications_none_rounded,
                  //   title: 'Notification Settings',
                  //   subtitle: 'Alerts and preferences',
                  //   onTap: _onNotificationSettingsTap,
                  // ),
                  // _SettingsTileData(
                  //   icon: Icons.shield_outlined,
                  //   title: 'Privacy & Security',
                  //   subtitle: 'Password and data',
                  //   onTap: () => _onPrivacySecurityTap(context),
                  //   isLast: true,
                  // ),
                ],
              ),
              SizedBox(height: size.height * 0.03),

              // ---------------- MORE ----------------
              const _SectionLabel(text: 'MORE'),
              SizedBox(height: size.height * 0.012),
              _SettingsCard(
                tiles: [
                  _SettingsTileData(
                    title: 'About Shopzo',
                    onTap: _onAboutTap,
                    isExternal: true,
                  ),
                  _SettingsTileData(
                    title: 'Terms of Service',
                    onTap: _onTermsTap,
                    isExternal: true,
                  ),
                  _SettingsTileData(
                    title: 'Privacy Policy',
                    onTap: _onPrivacyPolicyTap,
                    isExternal: true,
                  ),
                  _SettingsTileData(
                    title: 'Return Policy',
                    onTap: _onReturnPolicyTap,
                    isExternal: true,
                    isLast: true,
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),

              // ---------------- LOG OUT ----------------
              GestureDetector(
                onTap: () => _onLogoutTap(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  decoration: BoxDecoration(
                    color: ColorConstant.errorColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 16, color: ColorConstant.errorColor),
                      const SizedBox(width: 8),
                      TextContext(
                        text: 'Log Out',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.errorColor,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.014),

              // ---------------- APP VERSION ----------------
              Center(
                child: TextContext(
                  text: _appVersion,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.placeholderColor,
                ),
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String email;
  final String memberSince;
  final VoidCallback onEditAvatar;

  const _ProfileHeader({
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.memberSince,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final avatarSize = size.width * 0.2;

    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: avatarSize,
                width: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstant.blackColor.withOpacity(.1),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: ColorConstant.primaryLight,
                    alignment: Alignment.center,
                    child: Icon(Icons.person_rounded,
                        size: avatarSize * 0.5, color: ColorConstant.primaryColor),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: onEditAvatar,
                  child: Container(
                    height: avatarSize * 0.3,
                    width: avatarSize * 0.3,
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorConstant.whiteColor, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.edit_rounded,
                        size: avatarSize * 0.15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          TextContext(
            text: name,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ColorConstant.headlineTextColor,
          ),
          SizedBox(height: size.height * 0.004),
          TextContext(
            text: email,
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: ColorConstant.labelTextColor,
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstant.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextContext(
              text: memberSince,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorConstant.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: size.width * 0.1,
              width: size.width * 0.1,
              decoration: BoxDecoration(
                color: ColorConstant.primaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: size.width * 0.05, color: ColorConstant.primaryColor),
            ),
            SizedBox(height: size.height * 0.01),
            TextContext(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),
            SizedBox(height: size.height * 0.002),
            TextContext(
              text: subtitle,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              color: ColorConstant.labelTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return TextContext(
      text: text,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: ColorConstant.labelTextColor,
      letterSpacing: 0.6,
    );
  }
}

class _SettingsTileData {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isExternal;
  final bool isLast;

  const _SettingsTileData({
    this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isExternal = false,
    this.isLast = false,
  });
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsTileData> tiles;
  const _SettingsCard({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: tiles.map((tile) => _SettingsTile(data: tile)).toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final _SettingsTileData data;
  const _SettingsTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.033,
          vertical: size.height * 0.015,
        ),
        decoration: BoxDecoration(
          border: data.isLast
              ? null
              : Border(
            bottom: BorderSide(color: ColorConstant.dividerColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (data.icon != null) ...[
              Icon(data.icon, size: 20, color: ColorConstant.bodyTextColor),
              SizedBox(width: size.width * 0.035),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextContext(
                    text: data.title,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.headlineTextColor,
                  ),
                  if (data.subtitle != null) ...[
                    const SizedBox(height: 2),
                    TextContext(
                      text: data.subtitle!,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.labelTextColor,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              data.isExternal
                  ? Icons.open_in_new_rounded
                  : Icons.chevron_right_rounded,
              size: data.isExternal ? 17 : 22,
              color: ColorConstant.placeholderColor,
            ),
          ],
        ),
      ),
    );
  }
}