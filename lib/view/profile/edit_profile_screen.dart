import 'dart:io';
import 'package:flutter/material.dart';
import '../../../res/button_context.dart';
import '../../../res/color_constant.dart';
import '../../../res/date_picker.dart';
import '../../../res/dropdown_context.dart';
import '../../../res/image_upload_constant.dart';
import '../../../res/text_context.dart';
import '../../../res/textfiled_context.dart';
import '../../utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  File? _pickedAvatar;
  bool _isSaving = false;

  final List<String> _genderOptions = const ["Male", "Female", "Other", "Prefer not to say"];

  static const String _existingAvatarUrl = 'assets/images/pro12.jpg';

  @override
  void initState() {
    super.initState();
    // TODO: pre-fill from real user data (provider / bloc / auth service)
    _nameController = TextEditingController(text: "Satyam Singh");
    _emailController = TextEditingController(text: "satyam@gmail.com");
    _phoneController = TextEditingController(text: "9876543210");
    _dobController.text = "15/08/1996";
    _selectedGender = "Male";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await ImageUploadHelper.pickImage(context);
    if (file != null) setState(() => _pickedAvatar = file);
  }

  Future<void> _onSave() async {
    AppUtils.hideKeyboard(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // TODO: call your update-profile API here, e.g.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSaving = false);

    AppUtils.success(context, "Your profile has been updated");
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.02),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAvatarPicker(size),
                      SizedBox(height: size.height * 0.03),

                      const TextContext(text: "Full Name", fontSize: 13, fontWeight: FontWeight.w600),
                      SizedBox(height: size.height * 0.01),
                      CustomTextField(
                        controller: _nameController,
                        hintText: "Enter your full name",
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: ColorConstant.placeholderColor, size: 20),
                        validator: (v) => AppUtils.validateNotEmpty(v, field: "Name"),
                      ),
                      SizedBox(height: size.height * 0.02),

                      const TextContext(text: "Email Address", fontSize: 13, fontWeight: FontWeight.w600),
                      SizedBox(height: size.height * 0.01),
                      CustomTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: "Enter your email",
                        prefixIcon: const Icon(Icons.mail_outline_rounded, color: ColorConstant.placeholderColor, size: 20),
                        validator: AppUtils.validateEmail,
                      ),
                      SizedBox(height: size.height * 0.02),

                      const TextContext(text: "Phone Number", fontSize: 13, fontWeight: FontWeight.w600),
                      SizedBox(height: size.height * 0.01),
                      CustomTextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        hintText: "Enter your mobile number",
                        prefixText: "+91  ",
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.verified_rounded, color: ColorConstant.successColor, size: 18),
                        ),
                        validator: (v) => AppUtils.validatePhone(v),
                      ),
                      SizedBox(height: size.height * 0.02),

                      CustomDatePickerField(
                        title: "Date of Birth",
                        hintText: "DD/MM/YYYY",
                        controller: _dobController,
                        prefixIcon: Icons.cake_outlined,
                        lastDate: DateTime.now(),
                      ),
                      SizedBox(height: size.height * 0.02),

                      CustomDropdownField<String>(
                        title: "Gender",
                        hintText: "Select gender",
                        value: _selectedGender,
                        prefixIcon: Icons.wc_rounded,
                        items: DropdownItems.fromStrings(_genderOptions),
                        onChanged: (value) => setState(() => _selectedGender = value),
                      ),
                      SizedBox(height: size.height * 0.04),

                      CustomButton(
                        text: "Save Changes",
                        height: 54,
                        loading: _isSaving,
                        icon: Icons.check_rounded,
                        onTap: _onSave,
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
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
              text: "Edit Profile",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 34), // balances the back button for true centering
        ],
      ),
    );
  }

  /// ---------------- AVATAR PICKER ----------------
  Widget _buildAvatarPicker(Size size) {
    final double avatarSize = (size.width * 0.28).clamp(96.0, 130.0);

    return Center(
      child: Stack(
        children: [
          Container(
            height: avatarSize,
            width: avatarSize,
            decoration: BoxDecoration(
              color: ColorConstant.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: ColorConstant.borderColor, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: _pickedAvatar != null
                ? Image.file(_pickedAvatar!, fit: BoxFit.cover)
                : Image.asset(
              _existingAvatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.person_rounded, size: avatarSize * 0.5, color: ColorConstant.primaryColor),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickAvatar,
              customBorder: const CircleBorder(),
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorConstant.whiteColor, width: 2.5),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}