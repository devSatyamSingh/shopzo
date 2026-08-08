import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../res/button_context.dart';
import '../../../res/color_constant.dart';
import '../../../res/date_picker.dart';
import '../../../res/dropdown_context.dart';
import '../../../res/text_context.dart';
import '../../../res/textfiled_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/profile_viewmodel.dart';

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
  DateTime? _selectedDob;
  bool _prefilled = false;

  final List<String> _genderOptions = const ["Male", "Female", "Other"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  void _prefillFromProfile(ProfileViewModel vm) {
    if (_prefilled || vm.profile == null) return;
    final p = vm.profile!;
    _nameController.text = p.name;
    _emailController.text = p.email;
    _phoneController.text = p.phone;
    _selectedDob = p.dob;
    if (p.dob != null) _dobController.text = _formatDate(p.dob!);
    _selectedGender = p.genderLabel;
    _prefilled = true;
  }

  String _formatDate(DateTime d) => "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _onSave(ProfileViewModel vm) async {
    AppUtils.hideKeyboard(context);
    if (!_formKey.currentState!.validate()) return;

    final ok = await vm.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      dob: _selectedDob,
      gender: _selectedGender,
    );

    if (!mounted) return;

    if (ok) {
      AppUtils.success(context, "Your profile has been updated");
      Navigator.of(context).maybePop();
    } else {
      AppUtils.error(context, vm.saveError ?? "Failed to update profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, vm, _) {
            // profile detail screen se already loaded hoga — but agar direct
            // is screen pe aaya user, to yaha se fetch kar lo
            if (vm.profile == null && !vm.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) => vm.fetchProfile());
            }
            _prefillFromProfile(vm);

            return Column(
              children: [
                _buildHeader(context, size),
                Expanded(
                  child: (vm.isLoading && vm.profile == null)
                      ? const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor))
                      : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.02),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAvatarBlock(size),
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
                            validator: (v) => AppUtils.validatePhone(v),
                          ),
                          SizedBox(height: size.height * 0.02),

                          CustomDatePickerField(
                            title: "Date of Birth",
                            hintText: "DD/MM/YYYY",
                            controller: _dobController,
                            prefixIcon: Icons.cake_outlined,
                            lastDate: DateTime.now(),
                            onDateSelected: (date) => _selectedDob = date, // ⚠️ confirm callback name in your CustomDatePickerField
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
                            loading: vm.isSaving,
                            icon: Icons.check_rounded,
                            onTap: vm.isSaving ? null : () => _onSave(vm),
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
            child: TextContext(text: "Edit Profile", fontSize: 18, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildAvatarBlock(Size size) {
    final double avatarSize = (size.width * 0.28).clamp(96.0, 130.0);
    final initial = _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?';

    return Center(
      child: Container(
        height: avatarSize,
        width: avatarSize,
        decoration: BoxDecoration(
          color: ColorConstant.primaryLight,
          shape: BoxShape.circle,
          border: Border.all(color: ColorConstant.borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(fontSize: avatarSize * 0.4, fontWeight: FontWeight.w700, color: ColorConstant.primaryColor, fontFamily: "Poppins"),
        ),
      ),
    );
  }
}