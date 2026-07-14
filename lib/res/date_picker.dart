import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'color_constant.dart';
import 'text_context.dart';

/// Shopzo — reusable Date Picker field.
/// Useful for: customer DOB, delivery-slot date, coupon expiry (admin), etc.
class CustomDatePickerField extends StatefulWidget {
  final String hintText;
  final String? title;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime)? onDateSelected;
  final IconData? prefixIcon;
  final bool requiredField;
  final Color? fillColor;
  final double? borderRadius;
  final bool showBorder;
  final TextEditingController? controller;

  const CustomDatePickerField({
    super.key,
    required this.hintText,
    this.title,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.prefixIcon,
    this.requiredField = false,
    this.fillColor,
    this.borderRadius,
    this.showBorder = true,
    this.controller,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  DateTime? selectedDate;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();

    dateController = widget.controller ?? TextEditingController();

    if (dateController.text.isNotEmpty) {
      try {
        selectedDate = DateFormat("dd/MM/yyyy").parse(dateController.text);
      } catch (_) {}
    }
  }

  @override
  void didUpdateWidget(covariant CustomDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller && widget.controller != null) {
      dateController = widget.controller!;
    }
  }

  Future<void> pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1970),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstant.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ColorConstant.headlineTextColor,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              dayStyle: const TextStyle(fontFamily: "Poppins"),
              headerHeadlineStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: "Poppins",
              ),
              headerHelpStyle: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(pickedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Row(
            children: [
              TextContext(
                text: widget.title!,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              if (widget.requiredField)
                const Text(" *", style: TextStyle(color: ColorConstant.errorColor)),
            ],
          ),
          const SizedBox(height: 10),
        ],
        GestureDetector(
          onTap: pickDate,
          child: AbsorbPointer(
            child: TextField(
              controller: dateController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
                color: ColorConstant.headlineTextColor,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: "Poppins",
                  color: ColorConstant.placeholderColor,
                ),
                filled: true,
                fillColor: widget.fillColor ?? ColorConstant.fieldFillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: ColorConstant.primaryColor)
                    : null,
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor.withOpacity(.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: ColorConstant.primaryColor,
                    size: 22,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                  borderSide: widget.showBorder
                      ? const BorderSide(color: ColorConstant.borderColor)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                  borderSide: const BorderSide(
                    color: ColorConstant.primaryColor,
                    width: 1.4,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
