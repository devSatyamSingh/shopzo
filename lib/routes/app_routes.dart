import 'package:flutter/material.dart';
import '../view/auth/login_screen.dart';
import '../view/auth/otpscreen.dart';
import '../view/home/home_screen.dart';
import '../view/onboarding/onboardingscreen.dart';
import '../view/splash/splash_screen.dart';
import 'route_name.dart';

/// Shopzo — centralized route generator.
/// Set MaterialApp(onGenerateRoute: AppRoutes.generateRoute) in main.dart
/// and navigate with Navigator.pushNamed(context, RouteName.xxx).
///
/// As you build more screens, add one case per RouteName constant here.
class AppRoutes {
  AppRoutes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splash:
        return _page(const SplashScreen());

      case RouteName.login:
        return _page(const LoginScreen());

      case RouteName.otpVerify:
        final phone = settings.arguments as String? ?? '';
        return _page(OtpScreen(fullPhoneNumber: phone));

      case RouteName.home:
        return _page(const HomeScreen());

      case RouteName.onboarding:
        return _page(const OnboardingScreen());

      // TODO: add the remaining screens as you build them, e.g.
      // case RouteName.productDetail:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return _page(ProductDetailScreen(productId: args['id']));

      default:
        return _page(
          Scaffold(
            body: Center(child: Text("No route defined for ${settings.name}")),
          ),
        );
    }
  }

  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
