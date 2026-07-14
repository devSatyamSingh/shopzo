import 'package:flutter/material.dart';
import 'color_constant.dart';
import 'text_context.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String hintText;
  final String? title;
  final bool requiredField;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final IconData? prefixIcon;
  final Color? fillColor;
  final double? borderRadius;
  final bool showBorder;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    this.title,
    this.requiredField = false,
    this.value,
    this.onChanged,
    this.prefixIcon,
    this.fillColor,
    this.borderRadius,
    this.showBorder = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              TextContext(text: title!, fontSize: 14, fontWeight: FontWeight.w600),
              if (requiredField)
                const Text(" *", style: TextStyle(color: ColorConstant.errorColor)),
            ],
          ),
          const SizedBox(height: 10),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: ColorConstant.primaryColor),
          dropdownColor: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(16),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
            color: ColorConstant.headlineTextColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontFamily: "Poppins",
              color: ColorConstant.placeholderColor,
            ),
            filled: true,
            fillColor: fillColor ?? ColorConstant.fieldFillColor,
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: ColorConstant.primaryColor) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
              borderSide: showBorder
                  ? const BorderSide(color: ColorConstant.borderColor)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
              borderSide: const BorderSide(color: ColorConstant.primaryColor, width: 1.4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
              borderSide: const BorderSide(color: ColorConstant.errorColor),
            ),
          ),
        ),
      ],
    );
  }
}


class DropdownItems {
  static List<DropdownMenuItem<String>> fromStrings(List<String> values) {
    return values
        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
        .toList();
  }
}
