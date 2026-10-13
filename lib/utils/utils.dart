import 'package:flutter/material.dart';
import '../res/color_constant.dart';
import '../res/text_context.dart';

enum SnackType { success, error, warning, info }


class AppUtils {
  AppUtils._();


  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showSnackBar(
      BuildContext? context, {
        required String message,
        SnackType type = SnackType.info,
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    final messenger = context != null
        ? ScaffoldMessenger.of(context)
        : messengerKey.currentState;

    if (messenger == null) return;

    final config = _configFor(type);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: config.color, width: 4)),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blackColor.withOpacity(.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: config.color.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(config.icon, color: config.color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextContext(
                      text: title ?? config.defaultTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),
                    const SizedBox(height: 2),
                    TextContext(
                      text: message,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.labelTextColor,
                      height: 1.3,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => messenger.hideCurrentSnackBar(),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: ColorConstant.placeholderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- shorthand helpers ----
  static void success(BuildContext? context, String message, {String? title}) =>
      showSnackBar(context, message: message, type: SnackType.success, title: title);

  static void error(BuildContext? context, String message, {String? title}) =>
      showSnackBar(context, message: message, type: SnackType.error, title: title);

  static void warning(BuildContext? context, String message, {String? title}) =>
      showSnackBar(context, message: message, type: SnackType.warning, title: title);

  static void info(BuildContext? context, String message, {String? title}) =>
      showSnackBar(context, message: message, type: SnackType.info, title: title);

  static _SnackConfig _configFor(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackConfig(
          color: ColorConstant.successColor,
          icon: Icons.check_circle_rounded,
          defaultTitle: 'Success',
        );
      case SnackType.error:
        return _SnackConfig(
          color: ColorConstant.errorColor,
          icon: Icons.cancel_rounded,
          defaultTitle: 'Error',
        );
      case SnackType.warning:
        return _SnackConfig(
          color: ColorConstant.warningColor,
          icon: Icons.warning_rounded,
          defaultTitle: 'Warning',
        );
      case SnackType.info:
        return _SnackConfig(
          color: ColorConstant.infoColor,
          icon: Icons.info_rounded,
          defaultTitle: 'Info',
        );
    }
  }


  static void showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          height: 70,
          width: 70,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CircularProgressIndicator(
            color: ColorConstant.primaryColor,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  static void hideLoader(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }


  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Yes',
        String cancelText = 'Cancel',
        bool isDestructive = false,
        IconData? icon,
      }) async {
    final Color accentColor = isDestructive ? ColorConstant.errorColor : ColorConstant.primaryColor;
    final IconData resolvedIcon = icon ?? (isDestructive ? Icons.delete_outline_rounded : Icons.help_outline_rounded);

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blackColor.withOpacity(.16),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- Icon badge ----
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(resolvedIcon, color: accentColor, size: 28),
              ),
              const SizedBox(height: 16),

              // ---- Title ----
              TextContext(
                text: title,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ColorConstant.headlineTextColor,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ---- Message ----
              TextContext(
                text: message,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
                height: 1.45,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),

              // ---- Actions ----
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(dialogContext, false),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorConstant.fieldFillColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextContext(
                          text: cancelText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.headlineTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(dialogContext, true),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextContext(
                          text: confirmText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }


  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? validatePhone(String? value, {int minLength = 7}) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < minLength) return 'En ter a valid mobile number';
    return null;
  }


  static String formatCurrency(num amount, {String symbol = '₹'}) {
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
    return '$symbol$whole.${parts[1]}';
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// ------------------------------------------------------------
  /// MISC
  /// ------------------------------------------------------------
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static bool isValidEmail(String value) => validateEmail(value) == null;
}

class _SnackConfig {
  final Color color;
  final IconData icon;
  final String defaultTitle;

  _SnackConfig({
    required this.color,
    required this.icon,
    required this.defaultTitle,
  });
}