import 'package:flutter/material.dart';
import 'button_context.dart';
import 'color_constant.dart';
import 'text_context.dart';

class DeletePopup {
  DeletePopup._();

  static Future<bool?> show(
    BuildContext context, {
    String title = "Are you sure?",
    String message = "This action cannot be undone.",
    String confirmText = "Delete",
    String cancelText = "Cancel",
    IconData icon = Icons.delete_rounded,
    Color iconColor = ColorConstant.errorColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 18),
              TextContext(
                text: title,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextContext(
                text: message,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: cancelText,
                      outlined: true,
                      height: 48,
                      borderColor: ColorConstant.borderColor,
                      textColor: ColorConstant.bodyTextColor,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: confirmText,
                      height: 48,
                      color: iconColor,
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
