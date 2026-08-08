import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import 'register_screen.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordController = TextEditingController();
  final _authViewModel = AuthViewModel();

  String _rawNumber = '';
  bool _isPhoneValid = false;
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_isPhoneValid || _rawNumber.isEmpty) {
      AppUtils.error(context, 'auth.invalid_mobile'.tr());
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      AppUtils.error(context, 'auth.empty_password'.tr());
      return;
    }

    setState(() => _loading = true);

    final success = await _authViewModel.login(
      phone: _rawNumber,
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      AppUtils.success(context, 'auth.login_success'.tr());
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteName.mainWrapper,
            (route) => false,
      );
    } else {
      AppUtils.error(
        context,
        _authViewModel.errorMessage ?? 'auth.login_failed'.tr(),
      );
    }
  }

  void _onRegisterTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
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

              Center(
                child: Container(
                  height: size.width * 0.23,
                  width: size.width * 0.23,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/shopzolo.png', fit: BoxFit.cover),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              TextContext(
                text: 'auth.welcome_back'.tr(),
                fontSize: 25,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                color: ColorConstant.headlineTextColor,
                alignment: Alignment.center,
              ),

              SizedBox(height: size.height * 0.01),

              TextContext(
                text: 'auth.login_subtitle'.tr(),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: ColorConstant.labelTextColor,
                height: 1.4,
                alignment: Alignment.center,
              ),

              SizedBox(height: size.height * 0.04),

              TextContext(
                text: 'auth.mobile_number'.tr(),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorConstant.bodyTextColor,
              ),

              SizedBox(height: size.height * 0.01),

              IntlPhoneField(
                initialCountryCode: 'IN',
                disableLengthCheck: false,
                showDropdownIcon: true,
                dropdownIconPosition: IconPosition.trailing,
                flagsButtonPadding: const EdgeInsets.only(left: 12),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: ColorConstant.headlineTextColor),
                dropdownTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ColorConstant.headlineTextColor),
                decoration: InputDecoration(
                  hintText: 'auth.mobile_hint'.tr(),
                  hintStyle: TextStyle(fontSize: 14, color: ColorConstant.placeholderColor),
                  filled: true,
                  fillColor: ColorConstant.primaryLight,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: ColorConstant.primaryColor, width: 1.4),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: ColorConstant.errorColor),
                  ),
                ),
                onChanged: (phone) {
                  _rawNumber = phone.number;
                },
                onCountryChanged: (country) {},
                validator: (phone) {
                  _isPhoneValid = phone != null && phone.number.isNotEmpty;
                  return null;
                },
              ),

              SizedBox(height: size.height * 0.025),

              TextContext(
                text: 'auth.password'.tr(),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorConstant.bodyTextColor,
              ),

              SizedBox(height: size.height * 0.01),

              CustomTextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                hintText: 'auth.password_hint'.tr(),
                fillColor: ColorConstant.primaryLight,
                showBorder: false,
                borderRadius: 16,
                contentPadding: 16,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: ColorConstant.placeholderColor,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.012),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: TextContext(
                    text: 'auth.forgot_password'.tr(),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.primaryColor,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              CustomButton(
                text: 'auth.log_in'.tr(),
                onTap: _onLogin,
                loading: _loading,
                color: ColorConstant.primaryColor,
                icon: Icons.arrow_forward,
                iconColor: ColorConstant.whiteColor,
              ),

              SizedBox(height: size.height * 0.03),

              Row(
                children: [
                  Expanded(child: Divider(color: ColorConstant.dividerColor, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextContext(
                      text: 'common.or'.tr(),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                  ),
                  Expanded(child: Divider(color: ColorConstant.dividerColor, thickness: 1)),
                ],
              ),

              SizedBox(height: size.height * 0.025),

              InkWell(
                onTap: _onRegisterTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.016),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorConstant.primaryColor.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: const BoxDecoration(color: ColorConstant.primaryColor, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextContext(
                              text: 'auth.new_to_shopzo'.tr(),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.headlineTextColor,
                            ),
                            const SizedBox(height: 2),
                            TextContext(
                              text: 'auth.create_account_subtitle'.tr(),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: ColorConstant.labelTextColor,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ColorConstant.primaryColor),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.06),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: ColorConstant.labelTextColor, height: 1.5),
                    children: [
                      TextSpan(text: 'auth.terms_prefix'.tr()),
                      TextSpan(
                        text: 'auth.terms_of_service'.tr(),
                        style: TextStyle(color: ColorConstant.primaryColor, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(text: 'auth.terms_middle'.tr()),
                      TextSpan(
                        text: 'auth.privacy_policy'.tr(),
                        style: TextStyle(color: ColorConstant.primaryColor, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(text: 'auth.terms_suffix'.tr()),
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

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import '../../res/button_context.dart';
// import '../../res/color_constant.dart';
// import '../../res/text_context.dart';
// import '../../routes/route_name.dart';
// import '../../utils/utils.dart';
// import 'otpscreen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   String _fullPhoneNumber = '';
//   String _rawNumber = '';
//   bool _isValid = false;
//   bool _loading = false;
//
//   void _onContinue() {
//     if (!_isValid || _rawNumber.isEmpty) {
//       AppUtils.error(context, 'Please enter a valid mobile number');
//       return;
//     }
//
//     setState(() => _loading = true);
//
//     Future.delayed(const Duration(milliseconds: 600), () {
//       if (!mounted) return;
//       setState(() => _loading = false);
//       Navigator.pushNamed(
//         context,
//         RouteName.otpVerify,
//         arguments: _fullPhoneNumber,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: ColorConstant.whiteColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: size.width * 0.065),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: size.height * 0.04),
//
//               // ---------------- APP LOGO ----------------
//               Center(
//                 child: Container(
//                   height: size.width * 0.23,
//                   width: size.width * 0.23,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: Image.asset(
//                     'assets/images/shopzolo.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: size.height * 0.02),
//
//               // ---------------- HEADLINE ----------------
//               TextContext(
//                 text: 'Welcome to Shopzo',
//                 fontSize: 25,
//                 fontWeight: FontWeight.w600,
//                 textAlign: TextAlign.center,
//                 color: ColorConstant.headlineTextColor,
//                 alignment: Alignment.center,
//               ),
//
//               SizedBox(height: size.height * 0.01),
//
//               TextContext(
//                 text: 'Discover premium products from verified global vendors.',
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//                 textAlign: TextAlign.center,
//                 color: ColorConstant.labelTextColor,
//                 height: 1.4,
//                 alignment: Alignment.center,
//               ),
//
//               SizedBox(height: size.height * 0.04),
//
//               // ---------------- MOBILE LABEL ----------------
//               TextContext(
//                 text: 'Mobile Number',
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//                 color: ColorConstant.bodyTextColor,
//               ),
//
//               SizedBox(height: size.height * 0.01),
//
//               // ---------------- PHONE FIELD (country code + flag) ----------------
//               IntlPhoneField(
//                 initialCountryCode: 'IN',
//                 disableLengthCheck: false,
//                 showDropdownIcon: true,
//                 dropdownIconPosition: IconPosition.trailing,
//                 flagsButtonPadding: const EdgeInsets.only(left: 12),
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                   color: ColorConstant.headlineTextColor,
//                 ),
//                 dropdownTextStyle: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: ColorConstant.headlineTextColor,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Enter your mobile number',
//                   hintStyle: TextStyle(
//                     fontSize: 14,
//                     color: ColorConstant.placeholderColor,
//                   ),
//                   filled: true,
//                   fillColor: ColorConstant.primaryLight,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide(
//                       color: ColorConstant.primaryColor,
//                       width: 1.4,
//                     ),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide(color: ColorConstant.errorColor),
//                   ),
//                 ),
//                 onChanged: (phone) {
//                   _fullPhoneNumber = phone.completeNumber;
//                   _rawNumber = phone.number;
//                 },
//                 onCountryChanged: (country) {},
//                 validator: (phone) {
//                   _isValid = phone != null && phone.number.isNotEmpty;
//                   return null;
//                 },
//               ),
//
//               SizedBox(height: size.height * 0.03),
//
//               // ---------------- CONTINUE BUTTON ----------------
//               CustomButton(
//                 text: 'Continue',
//                 onTap: _onContinue,
//                 loading: _loading,
//                 color: ColorConstant.primaryColor,
//                 icon: Icons.arrow_forward,
//                 iconColor: ColorConstant.whiteColor,
//               ),
//
//               SizedBox(height: size.height * 0.03),
//
//               // ---------------- OR DIVIDER ----------------
//               Row(
//                 children: [
//                   Expanded(
//                     child: Divider(color: ColorConstant.dividerColor, thickness: 1),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: TextContext(
//                       text: 'OR',
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: ColorConstant.labelTextColor,
//                     ),
//                   ),
//                   Expanded(
//                     child: Divider(color: ColorConstant.dividerColor, thickness: 1),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: size.height * 0.025),
//
//               // ---------------- CONTINUE WITH EMAIL ----------------
//               CustomButton(
//                 text: 'Continue with Email',
//                 onTap: () {
//                 },
//                 outlined: true,
//                 borderColor: ColorConstant.borderColor,
//                 textColor: ColorConstant.headlineTextColor,
//                 icon: Icons.mail_outline,
//                 iconColor: ColorConstant.primaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//               SizedBox(height: size.height * 0.18),
//               // ---------------- FOOTER ----------------
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
//                 child: RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontFamily: 'Poppins',
//                       color: ColorConstant.labelTextColor,
//                       height: 1.5,
//                     ),
//                     children: [
//                       const TextSpan(text: "By continuing, you agree to Shopzo's "),
//                       TextSpan(
//                         text: 'Terms of Service',
//                         style: TextStyle(
//                           color: ColorConstant.primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                           },
//                       ),
//                       const TextSpan(text: ' and '),
//                       TextSpan(
//                         text: 'Privacy Policy',
//                         style: TextStyle(
//                           color: ColorConstant.primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                           },
//                       ),
//                       const TextSpan(text: '.'),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: size.height * 0.03),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
