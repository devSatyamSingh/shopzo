import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import 'package:easy_localization/easy_localization.dart';

/// Shopzo — shared 3-step checkout progress indicator
class CheckoutStepper extends StatelessWidget {
  final int currentStep; // 1 = Address, 2 = Summary, 3 = Payment

  const CheckoutStepper({super.key, required this.currentStep});

  static const List<String> _labels = ['Address', 'Summary', 'Payment'];

  double get _progressValue {
    switch (currentStep) {
      case 1:
        return 0.16;
      case 2:
        return 0.66;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();


    return Column(
      children: [
        SizedBox(
          height: 3,
          width: double.infinity,
          child: Stack(
            children: [
              Container(color: ColorConstant.borderColor),
              FractionallySizedBox(
                widthFactor: _progressValue,
                child: Container(color: ColorConstant.primaryColor),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.025),

        // ---------------- CIRCLES + CONNECTING LINES ----------------
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Row(
            children: List.generate(3, (index) {
              final step = index + 1;
              final bool isFirst = index == 0;
              final bool isLast = index == 2;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isFirst
                                ? Colors.transparent
                                : (step - 1 <= currentStep
                                      ? ColorConstant.primaryColor
                                      : ColorConstant.borderColor),
                          ),
                        ),
                        _StepCircle(step: step, currentStep: currentStep),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isLast
                                ? Colors.transparent
                                : (step <= currentStep
                                      ? ColorConstant.primaryColor
                                      : ColorConstant.borderColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.008),
                    TextContext(
                      text: [
                        'checkout.steps.address'.tr(),
                        'checkout.steps.summary'.tr(),
                        'checkout.steps.payment'.tr(),
                      ][index],
                      fontSize: 12,
                      fontWeight: step == currentStep
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: step <= currentStep
                          ? ColorConstant.primaryColor
                          : ColorConstant.placeholderColor,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        SizedBox(height: size.height * 0.02),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int step;
  final int currentStep;

  const _StepCircle({required this.step, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool isDone = step < currentStep;
    final bool isCurrent = step == currentStep;

    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isDone || isCurrent)
            ? ColorConstant.primaryColor
            : ColorConstant.whiteColor,
        border: (isDone || isCurrent)
            ? null
            : Border.all(color: ColorConstant.borderColor, width: 1.4),
      ),
      alignment: Alignment.center,
      child: isDone
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
          : isCurrent
          ? (currentStep == 1
                ? Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  )
                : Container(
                    height: 9,
                    width: 9,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ))
          : Text(
              '$step',
              style: TextStyle(
                color: ColorConstant.placeholderColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
    );
  }
}
