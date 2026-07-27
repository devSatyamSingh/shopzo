import 'package:flutter/material.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';


class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: _buildAppBar(context),
      body: _buildNotificationList(context),
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
        text: 'Notifications',
        fontSize: _responsiveSize(context, 18, 22),
        fontWeight: FontWeight.w600,
        color: ColorConstant.headlineTextColor,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.check_circle_outline,
            color: ColorConstant.primaryColor,
            size: _responsiveSize(context, 20, 24),
          ),
          onPressed: () {
            // Mark all as read
          },
        ),
      ],
    );
  }

  Widget _buildNotificationList(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_responsiveSize(context, 16, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today Section
          _buildSectionHeader(context, 'Today'),
          SizedBox(height: _responsiveSize(context, 8, 12)),

          // Order Delivered Notification
          _buildNotificationCard(
            context: context,
            icon: Icons.local_shipping,
            iconColor: ColorConstant.successColor,
            title: 'Order Delivered!',
            subtitle: 'Your order #ORD-99281 has been successfully delivered. Rate your experience!',
            actionLabel: 'Rate Product',
            actionIcon: Icons.star_outline,
            onActionTap: () {},
            isToday: true,
          ),

          SizedBox(height: _responsiveSize(context, 12, 16)),

          // Flash Sale Notification
          _buildNotificationCard(
            context: context,
            icon: Icons.flash_on,
            iconColor: ColorConstant.orangeColor,
            title: 'Flash Sale Alert!',
            subtitle: 'Up to 60% OFF on all electronics. Valid for the next 4 hours only.',
            actionLabel: 'Shop Now',
            actionIcon: Icons.shopping_bag_outlined,
            onActionTap: () {},
            isToday: true,
          ),

          SizedBox(height: _responsiveSize(context, 24, 32)),

          // Yesterday Section
          _buildSectionHeader(context, 'Yesterday'),
          SizedBox(height: _responsiveSize(context, 8, 12)),

          // Security Update Notification
          _buildNotificationCard(
            context: context,
            icon: Icons.security,
            iconColor: ColorConstant.warningColor,
            title: 'Security Update',
            subtitle: 'Your password was changed successfully. If this wasn\'t you, contact support immediately.',
            actionLabel: 'Contact Support',
            actionIcon: Icons.support_agent,
            onActionTap: () {},
            isToday: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: _responsiveSize(context, 8, 12),
        left: _responsiveSize(context, 4, 8),
      ),
      child: TextContext(
        text: title,
        fontSize: _responsiveSize(context, 14, 16),
        fontWeight: FontWeight.w600,
        color: ColorConstant.labelTextColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onActionTap,
    required bool isToday,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _responsiveSize(context, 0, 4),
        vertical: _responsiveSize(context, 4, 6),
      ),
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(_responsiveSize(context, 12, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: ColorConstant.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(_responsiveSize(context, 16, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: _responsiveSize(context, 44, 52),
                  height: _responsiveSize(context, 44, 52),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_responsiveSize(context, 12, 14)),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: _responsiveSize(context, 22, 26),
                  ),
                ),
                SizedBox(width: _responsiveSize(context, 12, 16)),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextContext(
                              text: title,
                              fontSize: _responsiveSize(context, 15, 17),
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.headlineTextColor,
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: EdgeInsets.only(left: _responsiveSize(context, 8, 12)),
                              padding: EdgeInsets.symmetric(
                                horizontal: _responsiveSize(context, 8, 10),
                                vertical: _responsiveSize(context, 3, 4),
                              ),
                              decoration: BoxDecoration(
                                color: ColorConstant.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(_responsiveSize(context, 10, 12)),
                              ),
                              child: TextContext(
                                text: 'New',
                                fontSize: _responsiveSize(context, 9, 10),
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.primaryColor,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: _responsiveSize(context, 6, 8)),
                      TextContext(
                        text: subtitle,
                        fontSize: _responsiveSize(context, 13, 14),
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.bodyTextColor,
                        height: 1.5,
                      ),
                      SizedBox(height: _responsiveSize(context, 12, 16)),

                      // Action Button
                      _buildActionButton(
                        context: context,
                        label: actionLabel,
                        icon: actionIcon,
                        onTap: onActionTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _responsiveSize(context, 14, 18),
          vertical: _responsiveSize(context, 8, 10),
        ),
        decoration: BoxDecoration(
          gradient: ColorConstant.primaryGradient,
          borderRadius: BorderRadius.circular(_responsiveSize(context, 8, 10)),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: ColorConstant.whiteColor,
              size: _responsiveSize(context, 16, 18),
            ),
            SizedBox(width: _responsiveSize(context, 6, 8)),
            TextContext(
              text: label,
              fontSize: _responsiveSize(context, 12, 14),
              fontWeight: FontWeight.w500,
              color: ColorConstant.whiteColor,
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for responsive sizing
  double _responsiveSize(BuildContext context, double small, double large) {
    final screenWidth = MediaQuery.of(context).size.width;
    // For screens <= 360px (small phones)
    if (screenWidth <= 360) {
      return small;
    }
    // For screens >= 600px (tablets/large phones)
    if (screenWidth >= 600) {
      return large;
    }
    // Interpolate for screens between 360 and 600
    final t = (screenWidth - 360) / (600 - 360);
    return small + (large - small) * t;
  }
}