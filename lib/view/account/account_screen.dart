import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import '../../localization/language_provider.dart';
import '../../res/delete_popup.dart';
import '../../routes/route_name.dart';
import '../../utils/app_storage.dart';
import '../../utils/utils.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../../viewmodel/profile_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'language_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String _avatarUrl = 'assets/images/pro12.jpg';
  static const String _appVersion = 'Shopzo v2.4.1';

  static String _formatMemberSince(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return 'Member since —';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'Member since —';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Member since ${months[date.month - 1]} ${date.year}';
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _onEditAvatar() {
    //  open image picker / edit profile photo
  }

  void _onOrdersTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.myOrders);
  }

  void _onWishlistTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.wishlist);
  }

  void _onCouponsTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.coupons);
  }

  void _onLanguageTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
    );
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

  void _onAboutTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.aboutUs);
  }

  void _onTermsTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.termsConditions);
  }

  void _onPrivacyPolicyTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.privacyPolicy);
  }

  void _onReturnPolicyTap(BuildContext context) {
    Navigator.pushNamed(context, RouteName.returnRefund);
  }

  Future<void> _onLogoutTap(BuildContext context) async {
    final confirmed = await DeletePopup.show(
      context,
      icon: Icons.logout_rounded,
      iconColor: ColorConstant.errorColor,
      title: 'profile.log_out'.tr(),
      message: 'profile.logout_message'.tr(),
      confirmText: 'profile.log_out'.tr(),
      cancelText: 'profile.cancel'.tr(),
    );

    if (confirmed != true) return;

    AppUtils.showLoader(context);
    await AuthViewModel().logout();

    if (!context.mounted) return;
    AppUtils.hideLoader(context);

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteName.onboarding,
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();

    return Consumer<ProfileViewModel>(
      builder: (context, profileVm, _) {
        final apiProfile = profileVm.profile;
        final cachedCustomer =
            AppStorage.getCustomer(); // fallback jab tak API load ho rahi ho

        final memberSince = ProfileScreen._formatMemberSince(
          apiProfile?.createdAt?.toIso8601String() ?? cachedCustomer?['createdAt']?.toString(),
        );

        final name = (apiProfile?.name.isNotEmpty ?? false)
            ? apiProfile!.name
            : (cachedCustomer?['name']?.toString().isNotEmpty == true
                  ? cachedCustomer!['name'].toString()
            : 'profile.guest_user'.tr());

        final email = (apiProfile?.email.isNotEmpty ?? false)
            ? apiProfile!.email
            : (cachedCustomer?['email']?.toString().isNotEmpty == true
                  ? cachedCustomer!['email'].toString()
                  : (apiProfile?.phone ??
                        cachedCustomer?['phone']?.toString() ??
                        ''));

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
                    avatarUrl: ProfileScreen._avatarUrl,
                    name: name,
                    email: email,
                    memberSince: memberSince,
                    onEditAvatar: _onEditAvatar,
                  ),

                  SizedBox(height: size.height * 0.03),

                  // ---------------- QUICK ACTION GRID ----------------
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'profile.orders'.tr(),
                          subtitle: 'profile.orders_subtitle'.tr(),
                          onTap: () => _onOrdersTap(context),
                        ),
                      ),
                      SizedBox(width: size.width * 0.035),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.favorite_rounded,
                          title: 'profile.wishlist'.tr(),
                          subtitle: 'profile.wishlist_subtitle'.tr(),
                          onTap: () => _onWishlistTap(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.018),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.confirmation_num_rounded,
                          title: 'profile.coupons'.tr(),
                          subtitle: 'profile.coupons_subtitle'.tr(),
                          onTap: () => _onCouponsTap(context),
                        ),
                      ),
                      SizedBox(width: size.width * 0.035),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.support_agent_rounded,
                          title: 'profile.help_center'.tr(),
                          subtitle: 'profile.help_center_subtitle'.tr(),
                          onTap: () => _onHelpCenterTap(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),

                  // ---------------- ACCOUNT SETTINGS ----------------
                  _SectionLabel(
                    text: 'profile.account_settings'.tr(),
                  ),
                  SizedBox(height: size.height * 0.012),
                  _SettingsCard(
                    tiles: [
                      _SettingsTileData(
                        icon: Icons.person_outline_rounded,
                        title: 'profile.profile_information'.tr(),
                        subtitle: 'profile.profile_information_subtitle'.tr(),
                        onTap: () => _onProfileInfoTap(context),
                      ),
                      _SettingsTileData(
                        icon: Icons.location_on_outlined,
                        title: 'profile.saved_addresses'.tr(),
                        subtitle: 'profile.saved_addresses_subtitle'.tr(),
                        onTap: () => _onSavedAddressesTap(context),
                      ),
                      _SettingsTileData(
                        icon: Icons.credit_card_rounded,
                        title: 'profile.payment_methods'.tr(),
                        subtitle: 'profile.payment_methods_subtitle'.tr(),
                        onTap: () => _onPaymentMethodsTap(context),
                      ),

                      _SettingsTileData(
                        icon: Icons.language_rounded,
                        title: 'settings.language'.tr(),
                        subtitle: 'settings.language_subtitle'.tr(),
                        onTap: () => _onLanguageTap(context),
                        isLast: true,
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
                  _SectionLabel(
                    text: 'profile.more'.tr(),
                  ),
                  SizedBox(height: size.height * 0.012),
                  _SettingsCard(
                    tiles: [
                      _SettingsTileData(
                        title: 'profile.about_shopzo'.tr(),
                        onTap: () => _onAboutTap(context),
                        isExternal: true,
                      ),

                      _SettingsTileData(
                        title: 'profile.terms_of_service'.tr(),
                        onTap: () => _onTermsTap(context),
                        isExternal: true,
                      ),

                      _SettingsTileData(
                        title: 'profile.privacy_policy'.tr(),
                        onTap: () => _onPrivacyPolicyTap(context),
                        isExternal: true,
                      ),

                      _SettingsTileData(
                        title: 'profile.return_policy'.tr(),
                        onTap: () => _onReturnPolicyTap(context),
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
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstant.errorColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 16,
                            color: ColorConstant.errorColor,
                          ),
                          const SizedBox(width: 8),
                          TextContext(
                            text: 'profile.log_out'.tr(),
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
                      text: ProfileScreen._appVersion,
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
      },
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
                    child: Icon(
                      Icons.person_rounded,
                      size: avatarSize * 0.5,
                      color: ColorConstant.primaryColor,
                    ),
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
                      border: Border.all(
                        color: ColorConstant.whiteColor,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.edit_rounded,
                      size: avatarSize * 0.15,
                      color: Colors.white,
                    ),
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
              child: Icon(
                icon,
                size: size.width * 0.05,
                color: ColorConstant.primaryColor,
              ),
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
                  bottom: BorderSide(
                    color: ColorConstant.dividerColor,
                    width: 1,
                  ),
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
