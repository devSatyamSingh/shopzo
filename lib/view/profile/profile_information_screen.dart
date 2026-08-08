import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../res/button_context.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import '../../model/profile_model.dart';
import '../../routes/route_name.dart';
import '../../viewmodel/profile_viewmodel.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() => _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  void _openEditProfile(BuildContext context) {
    Navigator.pushNamed(context, RouteName.editProfile);
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
              child: Consumer<ProfileViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading && vm.profile == null) {
                    return const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor));
                  }

                  if (vm.hasError && vm.profile == null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 42, color: ColorConstant.placeholderColor),
                            const SizedBox(height: 10),
                            TextContext(text: vm.errorMessage ?? 'Failed to load profile', fontSize: 13.5, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor, textAlign: TextAlign.center),
                            const SizedBox(height: 14),
                            CustomButton(text: 'Retry', width: 140, height: 44, onTap: () => vm.fetchProfile()),
                          ],
                        ),
                      ),
                    );
                  }

                  final profile = vm.profile!;

                  return RefreshIndicator(
                    color: ColorConstant.primaryColor,
                    onRefresh: () => vm.fetchProfile(showLoader: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.053, vertical: size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAvatarBlock(size, profile),
                          SizedBox(height: size.height * 0.03),
                          const _SectionLabel(text: 'PERSONAL DETAILS'),
                          SizedBox(height: size.height * 0.012),
                          _InfoCard(
                            tiles: [
                              _InfoTileData(icon: Icons.person_outline_rounded, label: 'Full Name', value: profile.name.isNotEmpty ? profile.name : '—'),
                              _InfoTileData(icon: Icons.mail_outline_rounded, label: 'Email Address', value: profile.email.isNotEmpty ? profile.email : '—'),
                              _InfoTileData(icon: Icons.call_outlined, label: 'Phone Number', value: profile.phone.isNotEmpty ? profile.phone : '—'),
                              _InfoTileData(icon: Icons.cake_outlined, label: 'Date of Birth', value: profile.dob != null ? _formatDate(profile.dob!) : 'Not set'),
                              _InfoTileData(icon: Icons.wc_rounded, label: 'Gender', value: profile.genderLabel ?? 'Not set'),
                              _InfoTileData(
                                icon: Icons.calendar_today_outlined,
                                label: 'Member Since',
                                value: profile.createdAt != null ? _formatMonthYear(profile.createdAt!) : '—',
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            child: TextContext(text: 'Profile Information', fontSize: 18, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildAvatarBlock(Size size, ProfileModel profile) {
    final double avatarSize = size.width * 0.22;
    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?';

    return Center(
      child: Column(
        children: [
          Container(
            height: avatarSize,
            width: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstant.primaryLight,
              boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(.1), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(fontSize: avatarSize * 0.4, fontWeight: FontWeight.w700, color: ColorConstant.primaryColor, fontFamily: "Poppins"),
            ),
          ),
          SizedBox(height: size.height * 0.014),
          TextContext(text: profile.name.isNotEmpty ? profile.name : 'Your Profile', fontSize: 17, fontWeight: FontWeight.w600),
          SizedBox(height: size.height * 0.006),
          if (profile.createdAt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: ColorConstant.primaryLight, borderRadius: BorderRadius.circular(20)),
              child: TextContext(text: 'Member since ${_formatMonthYear(profile.createdAt!)}', fontSize: 12, fontWeight: FontWeight.w500, color: ColorConstant.primaryColor),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  String _formatMonthYear(DateTime d) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return "${months[d.month - 1]} ${d.year}";
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return TextContext(text: text, fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstant.labelTextColor, letterSpacing: 0.6);
  }
}

class _InfoTileData {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTileData({required this.icon, required this.label, required this.value, this.isLast = false});
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
        boxShadow: [BoxShadow(color: ColorConstant.blackColor.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(children: tiles.map((tile) => _InfoTile(data: tile)).toList()),
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
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.033, vertical: size.height * 0.015),
      decoration: BoxDecoration(
        border: data.isLast ? null : const Border(bottom: BorderSide(color: ColorConstant.dividerColor, width: 1)),
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
                TextContext(text: data.label, fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                const SizedBox(height: 2),
                TextContext(text: data.value, fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstant.headlineTextColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}