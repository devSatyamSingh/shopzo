import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import 'otpscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _fullPhoneNumber = '';
  String _rawNumber = '';
  bool _isValid = false;
  bool _loading = false;

  void _onContinue() {
    if (!_isValid || _rawNumber.isEmpty) {
      AppUtils.error(context, 'Please enter a valid mobile number');
      return;
    }

    setState(() => _loading = true);

    // 👉 call your send-OTP API here, then navigate
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushNamed(
        context,
        RouteName.otpVerify,
        arguments: _fullPhoneNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.065),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.04),

              // ---------------- APP LOGO ----------------
              Center(
                child: Container(
                  height: size.width * 0.23,
                  width: size.width * 0.23,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/shopzolo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // ---------------- HEADLINE ----------------
              TextContext(
                text: 'Welcome to Shopzo',
                fontSize: 25,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                color: ColorConstant.headlineTextColor,
                alignment: Alignment.center,
              ),

              SizedBox(height: size.height * 0.01),

              TextContext(
                text: 'Discover premium products from verified global vendors.',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: ColorConstant.labelTextColor,
                height: 1.4,
                alignment: Alignment.center,
              ),

              SizedBox(height: size.height * 0.04),

              // ---------------- MOBILE LABEL ----------------
              TextContext(
                text: 'Mobile Number',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorConstant.bodyTextColor,
              ),

              SizedBox(height: size.height * 0.01),

              // ---------------- PHONE FIELD (country code + flag) ----------------
              IntlPhoneField(
                initialCountryCode: 'IN',
                disableLengthCheck: false,
                showDropdownIcon: true,
                dropdownIconPosition: IconPosition.trailing,
                flagsButtonPadding: const EdgeInsets.only(left: 12),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.headlineTextColor,
                ),
                dropdownTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.headlineTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your mobile number',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: ColorConstant.placeholderColor,
                  ),
                  filled: true,
                  fillColor: ColorConstant.primaryLight,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: ColorConstant.primaryColor,
                      width: 1.4,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: ColorConstant.errorColor),
                  ),
                ),
                onChanged: (phone) {
                  _fullPhoneNumber = phone.completeNumber;
                  _rawNumber = phone.number;
                },
                onCountryChanged: (country) {},
                validator: (phone) {
                  _isValid = phone != null && phone.number.isNotEmpty;
                  return null;
                },
              ),

              SizedBox(height: size.height * 0.03),

              // ---------------- CONTINUE BUTTON ----------------
              CustomButton(
                text: 'Continue',
                onTap: _onContinue,
                loading: _loading,
                color: ColorConstant.primaryColor,
                icon: Icons.arrow_forward,
                iconColor: ColorConstant.whiteColor,
              ),

              SizedBox(height: size.height * 0.03),

              // ---------------- OR DIVIDER ----------------
              Row(
                children: [
                  Expanded(
                    child: Divider(color: ColorConstant.dividerColor, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextContext(
                      text: 'OR',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                  ),
                  Expanded(
                    child: Divider(color: ColorConstant.dividerColor, thickness: 1),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.025),

              // ---------------- CONTINUE WITH EMAIL ----------------
              CustomButton(
                text: 'Continue with Email',
                onTap: () {
                  // 👉 handle email login
                },
                outlined: true,
                borderColor: ColorConstant.borderColor,
                textColor: ColorConstant.headlineTextColor,
                icon: Icons.mail_outline,
                iconColor: ColorConstant.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: size.height * 0.18),
              // ---------------- FOOTER ----------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      color: ColorConstant.labelTextColor,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "By continuing, you agree to Shopzo's "),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: ColorConstant.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // 👉 open Terms of Service
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: ColorConstant.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // 👉 open Privacy Policy
                          },
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}