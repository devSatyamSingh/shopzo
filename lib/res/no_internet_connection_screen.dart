import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/connectivity_service.dart';

/// Shopzo — No Internet screen.
/// Shown automatically by ConnectivityWrapper whenever real internet
/// is lost (device may still show "connected to wifi" — this checks
/// actual reachability via ConnectivityService).
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _checking = false;

  Future<void> _onTryAgain() async {
    setState(() => _checking = true);

    final isOnline = await ConnectivityService.instance.checkNow();

    if (!mounted) return;
    setState(() => _checking = false);

    // If still offline, ConnectivityWrapper keeps this screen visible —
    // we just give the user feedback that the retry failed.
    if (!isOnline) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ColorConstant.errorColor,
          content: const Text('Still no internet connection'),
        ),
      );
    }
    // If online → ConnectivityService stream fires false→true,
    // ConnectivityWrapper rebuilds and this screen disappears on its own,
    // revealing whatever screen the user was already on underneath.
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.065),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.04),

              // ---------------- APP LOGO ----------------
              Container(
                height: size.width * 0.19,
                width: size.width * 0.19,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/shopzolo.png',
                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(gradient: ColorConstant.brandGradient),
                    child: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ---------------- ILLUSTRATION ----------------
              Container(
                height: size.height * 0.32,
                width: size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/no_net.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.wifi_off_rounded,
                    size: size.width * 0.28,
                    color: ColorConstant.primaryColor.withOpacity(.5),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.035),

              // ---------------- TITLE ----------------
              const TextContext(
                text: 'No Internet Connection',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
                color: ColorConstant.primaryColor,
                alignment: Alignment.center,
              ),

              SizedBox(height: size.height * 0.012),

              // ---------------- DESCRIPTION ----------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: const TextContext(
                  text:
                  "Please check your internet settings or try again when you're back online.",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.center,
                  height: 1.5,
                  color: ColorConstant.labelTextColor,
                ),
              ),

              const Spacer(flex: 3),

              // ---------------- TRY AGAIN ----------------
              CustomButton(
                text: 'Try Again',
                onTap: _onTryAgain,
                loading: _checking,
                color: ColorConstant.primaryColor,
                icon: Icons.refresh_rounded,
                iconColor: ColorConstant.whiteColor,
              ),

              SizedBox(height: size.height * 0.015),

              // ---------------- CHECK SETTINGS ----------------
              CustomButton(
                text: 'Check Settings',
                onTap: () {
                  AppSettings.openAppSettings(type: AppSettingsType.wifi);
                },
                outlined: true,
                borderColor: ColorConstant.borderColor,
                textColor: ColorConstant.headlineTextColor,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}