import 'package:flutter/material.dart';
import 'color_constant.dart';

/// Shopzo — reusable primary/secondary button.
/// Defaults to the brand primary color; pass `gradient:
/// ColorConstant.brandGradient` for the Shop→zo hero-style CTA button.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  final double? height;
  final double? width;

  final double? fontSize;
  final Color? textColor;
  final Color? color;

  final Gradient? gradient;

  final FontWeight? fontWeight;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  final BorderRadiusGeometry? borderRadius;

  final List<BoxShadow>? boxShadow;

  final Widget? child;

  final bool loading;

  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  final bool outlined;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height,
    this.width,
    this.fontSize,
    this.textColor,
    this.color,
    this.gradient,
    this.fontWeight,
    this.margin,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.child,
    this.loading = false,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.outlined = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: loading ? null : onTap,
      child: Container(
        alignment: Alignment.center,
        margin: margin,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        height: height ?? 56,
        width: width ?? screenWidth,
        decoration: BoxDecoration(
          color: outlined
              ? ColorConstant.whiteColor
              : (gradient == null ? (color ?? ColorConstant.primaryColor) : null),
          gradient: outlined ? null : gradient,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: outlined
              ? Border.all(
                  color: borderColor ?? ColorConstant.primaryColor,
                  width: 1.4,
                )
              : null,
          boxShadow: outlined
              ? null
              : (boxShadow ??
                  [
                    BoxShadow(
                      color: (color ?? ColorConstant.primaryColor).withOpacity(.25),
                      blurRadius: 7,
                      offset: const Offset(0, 4),
                    ),
                  ]),
        ),
        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: outlined ? ColorConstant.primaryColor : Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : child ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: iconColor ??
                            (outlined ? ColorConstant.primaryColor : Colors.white),
                        size: iconSize ?? 20,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize ?? 16,
                          color: textColor ??
                              (outlined ? ColorConstant.primaryColor : Colors.white),
                          fontWeight: fontWeight ?? FontWeight.w600,
                          fontFamily: "Poppins",
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
