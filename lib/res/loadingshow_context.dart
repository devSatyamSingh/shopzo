import 'package:flutter/material.dart';
import 'color_constant.dart';

/// Shopzo — reusable loading dialog/overlay.
/// Call LoadingContext.show(context) before an API call and
/// LoadingContext.hide(context) once the response arrives.
class LoadingContext {
  LoadingContext._();

  static bool _isShowing = false;

  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: ColorConstant.whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 34,
                  width: 34,
                  child: CircularProgressIndicator(
                    color: ColorConstant.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.bodyTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Small inline loader — use inside buttons/lists instead of the
/// full-screen dialog above (e.g. "load more products" spinner).
class InlineLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const InlineLoader({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          color: color ?? ColorConstant.primaryColor,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
