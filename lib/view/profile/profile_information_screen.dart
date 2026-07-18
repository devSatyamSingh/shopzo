import 'package:flutter/material.dart';
import '../../../res/button_context.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import 'edit_profile_screen.dart';

/// Shopzo — Profile Information screen.
/// Opened from ProfileScreen's "Profile Information" tile. Shows the
/// user's saved details as a clean read-only summary (matching the
/// existing ProfileScreen's card/avatar style), with a pencil icon in
/// the header and a full-width "Edit Profile" button — both leading to
/// EditProfileScreen.
class ProfileInformationScreen extends StatelessWidget {
  const ProfileInformationScreen({super.key});

  // TODO: replace with real user data (provider / bloc / auth service)
  static const String _name = 'Satyam Singh';
  static const String _email = 'satyam@gmail.com';
  static const String _phone = '+91 98765 43210';
  static const String _dob = '15 Aug 1996';
  static const String _gender = 'Male';
  static const String _memberSince = 'January 2024';
  static const String _avatarUrl = 'assets/images/pro12.jpg';

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.053,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAvatarBlock(size),
                    SizedBox(height: size.height * 0.03),
                    const _SectionLabel(text: 'PERSONAL DETAILS'),
                    SizedBox(height: size.height * 0.012),
                    _InfoCard(
                      tiles: [
                        _InfoTileData(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: _name,
                        ),
                        _InfoTileData(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email Address',
                          value: _email,
                          verified: true,
                        ),
                        _InfoTileData(
                          icon: Icons.call_outlined,
                          label: 'Phone Number',
                          value: _phone,
                          verified: true,
                        ),
                        _InfoTileData(
                          icon: Icons.cake_outlined,
                          label: 'Date of Birth',
                          value: _dob,
                        ),
                        _InfoTileData(
                          icon: Icons.wc_rounded,
                          label: 'Gender',
                          value: _gender,
                        ),
                        _InfoTileData(
                          icon: Icons.calendar_today_outlined,
                          label: 'Member Since',
                          value: _memberSince,
                          isLast: true,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.035),
                    CustomButton(
                      text: 'Edit Profile',
                      height: 52,
                      icon: Icons.edit_rounded,
                      iconSize: 18,
                      onTap: () => _openEditProfile(context),
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.fromLTRB(size.width * 0.03, size.height * 0.012, size.width * 0.045, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded, color: ColorConstant.headlineTextColor, size: 22),
            ),
          ),
          const Expanded(
            child: TextContext(
              text: 'Profile Information',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- AVATAR BLOCK ----------------
  Widget _buildAvatarBlock(Size size) {
    final double avatarSize = size.width * 0.22;

    return Center(
      child: Column(
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
              _avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: ColorConstant.primaryLight,
                alignment: Alignment.center,
                child: Icon(Icons.person_rounded, size: avatarSize * 0.5, color: ColorConstant.primaryColor),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.014),
          const TextContext(
            text: _name,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: size.height * 0.006),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstant.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextContext(
              text: 'Member since Jan 2024',
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

/// ---------------- Section label ----------------
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

/// ---------------- Info card (read-only rows) ----------------
class _InfoTileData {
  final IconData icon;
  final String label;
  final String value;
  final bool verified;
  final bool isLast;

  const _InfoTileData({
    required this.icon,
    required this.label,
    required this.value,
    this.verified = false,
    this.isLast = false,
  });
}

class _InfoCard extends StatelessWidget {
  final List<_InfoTileData> tiles;
  const _InfoCard({required this.tiles});

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
        children: tiles.map((tile) => _InfoTile(data: tile)).toList(),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final _InfoTileData data;
  const _InfoTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.033,
        vertical: size.height * 0.015,
      ),
      decoration: BoxDecoration(
        border: data.isLast
            ? null
            : const Border(bottom: BorderSide(color: ColorConstant.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 20, color: ColorConstant.bodyTextColor),
          SizedBox(width: size.width * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextContext(
                  text: data.label,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
                const SizedBox(height: 2),
                TextContext(
                  text: data.value,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.headlineTextColor,
                ),
              ],
            ),
          ),
          if (data.verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstant.successColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, size: 12, color: ColorConstant.successColor),
                  SizedBox(width: 3),
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                      color: ColorConstant.successColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}