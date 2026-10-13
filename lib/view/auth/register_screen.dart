import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _authViewModel = AuthViewModel();

  String _rawNumber = '';
  bool _isPhoneValid = false;
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  Future<void> _onRegister() async {
    if (_nameController.text.trim().isEmpty) {
      AppUtils.error(context, 'Please enter your full name');
      return;
    }
    // Email is optional on the backend — only validate format if the user typed something.
    if (_emailController.text.trim().isNotEmpty &&
        !_isValidEmail(_emailController.text.trim())) {
      AppUtils.error(context, 'Please enter a valid email address');
      return;
    }
    if (!_isPhoneValid || _rawNumber.isEmpty) {
      AppUtils.error(context, 'Please enter a valid mobile number');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      AppUtils.error(context, 'Please enter a password');
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      AppUtils.error(context, 'Password must be at least 6 characters');
      return;
    }

    setState(() => _loading = true);

    final success = await _authViewModel.register(
      name: _nameController.text.trim(),
      phone: _rawNumber,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      AppUtils.success(context, 'Account created successfully. Please log in.');
      // Register API doesn't return a token, so there's no session to start —
      // just pop back to the Login screen underneath.
      Navigator.pop(context);
    } else {
      AppUtils.error(
        context,
        _authViewModel.errorMessage ?? 'Registration failed. Please try again.',
      );
    }
  }

  void _onLoginTap() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();


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
                text: 'Create Account',
                fontSize: 25,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                color: ColorConstant.headlineTextColor,
                alignment: Alignment.center,
              ),

              SizedBox(height: size.height * 0.01),

              TextContext(
                text: 'Sign up with your details to get started.',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: ColorConstant.labelTextColor,
                height: 1.4,
                alignment: Alignment.center,
              ),

              SizedBox(height: size.height * 0.04),

              // ---------------- FULL NAME LABEL ----------------
              TextContext(
                text: 'Full Name',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorConstant.bodyTextColor,
              ),

              SizedBox(height: size.height * 0.01),

              // ---------------- FULL NAME FIELD ----------------
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter your full name',
                fillColor: ColorConstant.primaryLight,
                showBorder: false,
                borderRadius: 16,
                contentPadding: 16,
                keyboardType: TextInputType.name,
              ),

              SizedBox(height: size.height * 0.025),

              // ---------------- EMAIL LABEL ----------------
              TextContext(
                text: 'Email Address (optional)',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorConstant.bodyTextColor,
              ),

              SizedBox(height: size.height * 0.01),

              // ---------------- EMAIL FIELD ----------------
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email address',
                fillColor: ColorConstant.primaryLight,
                showBorder: false,
                borderRadius: 16,
                contentPadding: 16,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: size.height * 0.025),

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
                controller: _phoneNumber,
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
                  _rawNumber = phone.number;
                },
                onCountryChanged: (country) {},
                validator: (phone) {
                  _isPhoneValid = phone != null && phone.number.isNotEmpty;
                  return null;
                },
              ),

              SizedBox(height: size.height * 0.025),

              // ---------------- PASSWORD LABEL ----------------
              TextContext(
                text: 'Password',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorConstant.bodyTextColor,
              ),

              SizedBox(height: size.height * 0.01),

              // ---------------- PASSWORD FIELD ----------------
              CustomTextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                hintText: 'Create a password',
                fillColor: ColorConstant.primaryLight,
                showBorder: false,
                borderRadius: 16,
                contentPadding: 16,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: ColorConstant.placeholderColor,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.035),

              // ---------------- REGISTER BUTTON ----------------
              CustomButton(
                text: 'Register',
                onTap: _onRegister,
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

              // ---------------- LOGIN CARD ----------------
              InkWell(
                onTap: _onLoginTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.016,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorConstant.primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: const BoxDecoration(
                          color: ColorConstant.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextContext(
                              text: 'Already have an account?',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.headlineTextColor,
                            ),
                            const SizedBox(height: 2),
                            TextContext(
                              text: 'Log in with your mobile number',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: ColorConstant.labelTextColor,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: ColorConstant.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.06),

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