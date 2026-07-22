import 'package:flutter/material.dart';
import 'package:shopzo/view/account/prevacy_securty_screen.dart';
import '../view/about_us_screen.dart';
import '../view/account/account_screen.dart';
import '../view/account/coupons_screen.dart';
import '../view/account/help_center_screen.dart';
import '../view/address/add_address_screen.dart';
import '../view/address/address_list_screen.dart';
import '../view/auth/login_screen.dart';
import '../view/auth/otpscreen.dart';
import '../view/auth/register_screen.dart';
import '../view/bottombar/main_wrapper_screen.dart';
import '../view/cart/cart_screen.dart';
import '../view/category/category_product_list.dart';
import '../view/category/category_screen.dart';
import '../view/checkout/checkout_step1_screen.dart';
import '../view/checkout/checkout_step2_screen.dart';
import '../view/checkout/checkout_step3_screen.dart';
import '../view/home/home_screen.dart';
import '../view/home/search_screen.dart';
import '../view/notification_screen.dart';
import '../view/onboarding/onboardingscreen.dart';
import '../view/order/order_deatils_screen.dart';
import '../view/order/order_list_screen.dart';
import '../view/order/review_rating_screen.dart';
import '../view/payment/add_payment_screen.dart';
import '../view/payment/payment_methods_screen.dart';
import '../view/privacy_policy_screen.dart';
import '../view/product_details/product_details_screen.dart';
import '../view/profile/edit_profile_screen.dart';
import '../view/profile/profile_information_screen.dart';
import '../view/return_refund_screen.dart';
import '../view/splash/splash_screen.dart';
import '../view/terms_cond_screen.dart';
import '../view/wishlist/wishlist_screen.dart';
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
    // ---- Splash / Onboarding ----
      case RouteName.splash:
        return _page(const SplashScreen());

      case RouteName.onboarding:
        return _page(const OnboardingScreen());

    // ---- Auth ----
      case RouteName.login:
        return _page(const LoginScreen());

      case RouteName.otpVerify:
        final phone = settings.arguments as String? ?? '';
        return _page(OtpScreen(fullPhoneNumber: phone));

    // ---- Core / Shell ----
      case RouteName.mainWrapper:
        return _page(const MainWrapper());

      case RouteName.home:
        return _page(const HomeScreen());

      case RouteName.categories:
        return _page(const CategoryScreen());

      case RouteName.categoryProducts:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _page(
          CategoryProductsScreen(
            categoryId: args['categoryId'] as String? ?? '',
            categoryName: args['categoryName'] as String? ?? '',
            tintColor: args['tintColor'] as Color? ?? const Color(0xFFEFEFEF),
          ),
        );

      case RouteName.search:
        return _page(const SearchScreen());

      case RouteName.productDetail:
        return _page(const ProductDetailScreen());

      case RouteName.notifications:
        return _page(const NotificationScreen());

    // ---- Cart / Checkout ----
      case RouteName.cart:
        return _page(const CartScreen());

      case RouteName.checkoutAddress:
        return _page(const CheckoutAddressScreen());

      case RouteName.checkoutSummary:
        return _page(const CheckoutSummaryScreen());

      case RouteName.checkoutPayment:
        return _page(const CheckoutPaymentScreen());

    // ---- Address ----
      case RouteName.addressList:
        return _page(const SelectAddressScreen());

      case RouteName.addEditAddress:
        return _page(const AddAddressScreen());

    // ---- Payment ----
      case RouteName.paymentMethods:
        return _page(const PaymentMethodsScreen());

      case RouteName.addPaymentMethod:
        return _page(const AddPaymentMethodScreen());

    // ---- Orders ----
      case RouteName.myOrders:
        return _page(const OrdersScreen());

      case RouteName.orderDetail:
        return _page(const OrderDetailScreen());

    // ---- Account ----
      case RouteName.wishlist:
        return _page(const WishlistScreen());

      case RouteName.coupons:
        return _page(const CouponsScreen());

      case RouteName.helpSupport:
        return _page(const HelpCenterScreen());

      case RouteName.profileInformation:
        return _page(const ProfileInformationScreen());

      case RouteName.editProfile:
        return _page(const EditProfileScreen());
      case RouteName.PrivacySecurity:
        return _page(const PrivacySecurityScreen());
      case RouteName.aboutUs:
        return _page(const AboutUsScreen());

      case RouteName.termsConditions:
        return _page(const TermsConditionsScreen());

      case RouteName.privacyPolicy:
        return _page(const PrivacyPolicyScreen());

      case RouteName.returnRefund:
        return _page(const ReturnRefundScreen());

      case RouteName.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

    // lib/routes/app_routes.dart
      case RouteName.reviewRating:
        return _page(const ReviewRatingScreen());

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