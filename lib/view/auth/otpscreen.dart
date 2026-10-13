import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';

class OtpScreen extends StatefulWidget {
  final String fullPhoneNumber;

  const OtpScreen({super.key, required this.fullPhoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const int _resendSeconds = 58;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onResend() {
    if (_secondsLeft != 0) return;
    // 👉 call your resend-OTP API here
    setState(() {
      _errorText = null;
      _otpController.clear();
    });
    _startTimer();
  }

  void _onVerify() {
    if (_otpController.text.length < 4) {
      setState(() => _errorText = 'Please enter the complete 4-digit code');
      return;
    }

    setState(() {
      _errorText = null;
      _loading = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, RouteName.mainWrapper);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();


    final defaultPinTheme = PinTheme(
      width: size.width * 0.15,
      height: size.width * 0.15,
      textStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: ColorConstant.headlineTextColor,
        fontFamily: 'Poppins',
      ),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConstant.borderColor, width: 1.2),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: ColorConstant.primaryColor, width: 1.6),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: ColorConstant.primaryColor, width: 1.2),
        color: ColorConstant.primaryLight,
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: ColorConstant.errorColor, width: 1.4),
      ),
    );

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.019),
          
                // ---------------- BACK BUTTON ----------------
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 47,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorConstant.primaryLight,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back,
                      color: ColorConstant.headlineTextColor,
                      size: 27,
                    ),
                  ),
                ),
          
                SizedBox(height: size.height * 0.03),
          
                // ---------------- APP LOGO ----------------
                Center(
                  child: Container(
                    height: size.width * 0.24,
                    width: size.width * 0.24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/shopzolo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          
                SizedBox(height: size.height * 0.02),
          
                // ---------------- TITLE ----------------
                TextContext(
                  text: 'Verify Your Number',
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  color: ColorConstant.headlineTextColor,
                  alignment: Alignment.center,
                ),
          
                SizedBox(height: size.height * 0.012),
          
                // ---------------- SUBTITLE ----------------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.028),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 1.3,
                        color: ColorConstant.labelTextColor,
                      ),
                      children: [
                        const TextSpan(text: 'Enter the 4-digit code sent to '),
                        TextSpan(
                          text: widget.fullPhoneNumber.isNotEmpty
                              ? widget.fullPhoneNumber
                              : '+91 98765 43210',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: ColorConstant.headlineTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                SizedBox(height: size.height * 0.04),
          
                // ---------------- OTP FIELD (pinput) ----------------
                Center(
                  child: Pinput(
                    length: 4,
                    controller: _otpController,
                    focusNode: _focusNode,
                    autofocus: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    forceErrorState: _errorText != null,
                    separatorBuilder: (index) => SizedBox(width: size.width * 0.035),
                    showCursor: true,
                    onChanged: (value) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                    onCompleted: (value) => _onVerify(),
                  ),
                ),
          
                if (_errorText != null) ...[
                  SizedBox(height: size.height * 0.012),
                  Center(
                    child: TextContext(
                      text: _errorText!,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.errorColor,
                    ),
                  ),
                ],
          
                SizedBox(height: size.height * 0.03),
          
                // ---------------- RESEND CODE ----------------
                Center(
                  child: Column(
                    children: [
                      TextContext(
                        text: "Didn't receive the code?",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
                      SizedBox(height: size.height * 0.006),
                      GestureDetector(
                        onTap: _onResend,
                        child: TextContext(
                          text: _secondsLeft == 0
                              ? 'Resend Code'
                              : 'Resend Code in $_formattedTime',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _secondsLeft == 0
                              ? ColorConstant.primaryColor
                              : ColorConstant.primaryColor.withOpacity(.6),
                        ),
                      ),
                    ],
                  ),
                ),
          
                SizedBox(height: size.height * 0.05),
          
                // ---------------- VERIFY BUTTON ----------------
                CustomButton(
                  text: 'Verify & Proceed',
                  onTap: _onVerify,
                  loading: _loading,
                  color: ColorConstant.primaryColor,
                ),
          
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}