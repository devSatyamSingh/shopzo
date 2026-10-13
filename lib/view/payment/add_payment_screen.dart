import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/payout_method_viewmodel.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPayoutMethodViewModel(),
      child: const _AddUpiView(),
    );
  }
}

class _AddUpiView extends StatefulWidget {
  const _AddUpiView();

  @override
  State<_AddUpiView> createState() => _AddUpiViewState();
}

class _AddUpiViewState extends State<_AddUpiView> {
  final _vpaController = TextEditingController();
  final _labelController = TextEditingController();

  static const List<String> _suggestedHandles = [
    '@okaxis',
    '@ybl',
    '@paytm',
    '@ibl',
    '@okhdfcbank',
  ];

  bool get _isValid => AddPayoutMethodViewModel.isValidUpi(_vpaController.text);

  @override
  void dispose() {
    _vpaController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _onHandleTap(String handle) {
    final current = _vpaController.text.split('@').first;
    _vpaController.text = '$current$handle';
    _vpaController.selection =
        TextSelection.collapsed(offset: _vpaController.text.length);
    setState(() {});
  }

  Future<void> _submit() async {
    AppUtils.hideKeyboard(context);
    final vm = context.read<AddPayoutMethodViewModel>();
    final ok = await vm.add(
      upiId: _vpaController.text,
      label: _labelController.text,
    );
    if (!mounted) return;
    if (ok) {
      AppUtils.success(context, 'UPI ID add Successfully');
      Navigator.pop(context, true);
    } else {
      AppUtils.error(context, vm.errorMessage ?? 'Could not add UPI');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<AddPayoutMethodViewModel>();

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('Add UPI ID'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ColorConstant.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstant.blackColor.withOpacity(.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(text: 'Virtual Payment Address (VPA)'),
                    CustomTextField(
                      controller: _vpaController,
                      hintText: 'example@upi',
                      fillColor: ColorConstant.primaryLight,
                      showBorder: false,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: size.height * 0.018),
                    TextContext(
                      text: 'Suggested Handles',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.labelTextColor,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Wrap(
                      spacing: size.width * 0.02,
                      runSpacing: size.height * 0.01,
                      children: _suggestedHandles.map((handle) {
                        return GestureDetector(
                          onTap: () => _onHandleTap(handle),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ColorConstant.borderColor),
                            ),
                            child: Text(
                              handle,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.bodyTextColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: size.height * 0.022),
                    const _FieldLabel(text: 'Label (optional)'),
                    CustomTextField(
                      controller: _labelController,
                      hintText: 'e.g. MY main UPI',
                      fillColor: ColorConstant.primaryLight,
                      showBorder: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.022),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstant.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextContext(
                            text: ' For Refund',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: ColorConstant.primaryColor,
                          ),
                          SizedBox(height: size.height * 0.006),
                          TextContext(
                            text: 'If your return or exchange is approved or cancelled, the refund can be sent directly to this UPI ID. The label is only for your reference.',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            color: ColorConstant.primaryColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.account_balance_rounded,
                        size: 40,
                        color: ColorConstant.primaryColor.withOpacity(.5)),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.03),

              CustomButton(
                text: 'Add UPI ID',
                onTap: (_isValid && !vm.isAdding) ? _submit : () {},
                loading: vm.isAdding,
                color: _isValid
                    ? ColorConstant.primaryColor
                    : ColorConstant.placeholderColor,
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextContext(
        text: text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ColorConstant.bodyTextColor,
      ),
    );
  }
}