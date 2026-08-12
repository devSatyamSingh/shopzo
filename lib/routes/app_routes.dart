import 'package:flutter/material.dart';
import 'package:shopzo/routes/transition_animation.dart';
import 'package:shopzo/view/account/prevacy_securty_screen.dart';
import '../model/cms_page_model.dart';
import '../view/account/support_tickets_screen.dart';
import '../view/cms/about_us_screen.dart';
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
import '../view/cms/cms_screen.dart';
import '../view/home/home_screen.dart';
import '../view/home/search_screen.dart';
import '../view/category/sub_category_screen.dart';
import '../view/notification/notification_screen.dart';
import '../view/onboarding/onboardingscreen.dart';
import '../view/order/my_return_screen.dart';
import '../view/order/order_deatils_screen.dart';
import '../view/order/order_list_screen.dart';
import '../view/order/return_deatils_screen.dart';
import '../view/order/review_rating_screen.dart';
import '../view/payment/add_payment_screen.dart';
import '../view/payment/payment_methods_screen.dart';
import '../view/cms/privacy_policy_screen.dart';
import '../view/product_details/product_details_screen.dart';
import '../view/profile/edit_profile_screen.dart';
import '../view/profile/profile_information_screen.dart';
import '../view/cms/return_refund_screen.dart';
import '../view/splash/splash_screen.dart';
import '../view/cms/terms_cond_screen.dart';
import '../view/wishlist/wishlist_screen.dart';
import 'route_name.dart';

/// Shopzo — centralized route generator with custom animations.
/// Set MaterialApp(onGenerateRoute: AppRoutes.generateRoute) in main.dart
/// and navigate with Navigator.pushNamed(context, RouteName.xxx).
class AppRoutes {
  AppRoutes._();

  // Default transition duration
  static const Duration _transitionDuration = Duration(milliseconds: 400);

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // ---- Splash / Onboarding (Fade transitions) ----
      case RouteName.splash:
        return _getPageRoute(
          const SplashScreen(),
          settings,
          transitionType: TransitionType.fade,
        );

      case RouteName.onboarding:
        return _getPageRoute(
          const OnboardingScreen(),
          settings,
          transitionType: TransitionType.fade,
        );

    // ---- Auth (Slide up transitions) ----
      case RouteName.login:
        return _getPageRoute(
          const LoginScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

      case RouteName.otpVerify:
        final phone = settings.arguments as String? ?? '';
        return _getPageRoute(
          OtpScreen(fullPhoneNumber: phone),
          settings,
          transitionType: TransitionType.slideUp,
        );

      case RouteName.register:
        return _getPageRoute(
          const RegisterScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

    // ---- Core / Shell (Scale + Fade) ----
      case RouteName.mainWrapper:
        return _getPageRoute(
          const MainWrapper(),
          settings,
          transitionType: TransitionType.scaleFade,
        );

      case RouteName.home:
        return _getPageRoute(
          const HomeScreen(),
          settings,
          transitionType: TransitionType.fade,
        );

      case RouteName.categories:
        return _getPageRoute(
          const CategoryScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.categoryProducts:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          CategoryProductListScreen(
            categoryId: args['categoryId'] as String? ?? '',
            categoryName: args['categoryName'] as String? ?? '',
          ),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.search:
        return _getPageRoute(
          const SearchScreen(),
          settings,
          transitionType: TransitionType.slideFromBottom,
        );

      case RouteName.productDetail:
        final args = settings.arguments;
        final String productId = args is Map ? args['productId'] as String : args as String;
        return _getPageRoute(
          ProductDetailScreen(productId: productId),
          settings,
          transitionType: TransitionType.zoomIn,
        );

      case RouteName.notifications:
        return _getPageRoute(
          const NotificationScreen(),
          settings,
          transitionType: TransitionType.slideFromTop,
        );

    // ---- Cart / Checkout (Slide up for checkout flow) ----
      case RouteName.cart:
        return _getPageRoute(
          const CartScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.checkoutAddress:
        return _getPageRoute(
          const CheckoutAddressScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

      case RouteName.checkoutSummary:
        return _getPageRoute(
          const CheckoutSummaryScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

      case RouteName.checkoutPayment:
        return _getPageRoute(
          const CheckoutPaymentScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

    // ---- Address ----
      case RouteName.addressList:
        return _getPageRoute(
          const SelectAddressScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.addEditAddress:
        return _getPageRoute(
          const AddAddressScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

    // ---- Payment ----
      case RouteName.paymentMethods:
        return _getPageRoute(
          const PaymentMethodsScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.addPaymentMethod:
        return _getPageRoute(
          const AddPaymentMethodScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

    // ---- Orders ----
      case RouteName.myOrders:
        return _getPageRoute(
          const OrdersScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.orderDetail:
        final orderId = settings.arguments as String;
        return _getPageRoute(
          OrderDetailScreen(orderId: orderId),
          settings,
          transitionType: TransitionType.zoomIn,
        );

    // ---- Account ----
      case RouteName.wishlist:
        return _getPageRoute(
          const WishlistScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.coupons:
        final args = settings.arguments;
        final double subtotal = args is Map
            ? (args['subtotal'] as num?)?.toDouble() ?? 0
            : (args is num ? args.toDouble() : 0);
        return _getPageRoute(
          CouponsScreen(subtotal: subtotal),
          settings,
          transitionType: TransitionType.slideFromBottom,
        );

      case RouteName.helpSupport:
        return _getPageRoute(
          const HelpCenterScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.profileInformation:
        return _getPageRoute(
          const ProfileInformationScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.editProfile:
        return _getPageRoute(
          const EditProfileScreen(),
          settings,
          transitionType: TransitionType.slideUp,
        );

      case RouteName.PrivacySecurity:
        return _getPageRoute(
          const PrivacySecurityScreen(),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.aboutUs:
        return MaterialPageRoute(
          builder: (_) => const CmsPageScreen(type: CmsPageType.aboutUs),
        );

      case RouteName.termsConditions:
        return MaterialPageRoute(
          builder: (_) => const CmsPageScreen(type: CmsPageType.termsAndConditions),
        );

      case RouteName.privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const CmsPageScreen(type: CmsPageType.privacyPolicy),
        );

      case RouteName.returnRefund:
        return MaterialPageRoute(
          builder: (_) => const CmsPageScreen(type: CmsPageType.returnAndRefundPolicy),
        );

      case RouteName.subCategory:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          SubCategoryScreen(
            categoryId: args['categoryId'] as String? ?? '',
            categoryName: args['categoryName'] as String? ?? '',
          ),
          settings,
          transitionType: TransitionType.slideFromRight,
        );

      case RouteName.myReturns:
        return MaterialPageRoute(builder: (_) => const MyReturnsScreen());

      case RouteName.returnDetail:
        final returnId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ReturnDetailScreen(returnId: returnId));

    // app_routes.dart — generateRoute ke switch-case me add karo
      case RouteName.mySupportTickets:
        return MaterialPageRoute(builder: (_) => const MySupportTicketsScreen());

      // case RouteName.reviewRating:
      //   return _getPageRoute(
      //     const ReviewRatingScreen(),
      //     settings,
      //     transitionType: TransitionType.slideUp,
      //   );

      default:
        return _getPageRoute(
          Scaffold(
            body: Center(
              child: Text("No route defined for ${settings.name}"),
            ),
          ),
          settings,
          transitionType: TransitionType.fade,
        );
    }
  }

  /// Main method to create page routes with custom animations
  static PageRoute _getPageRoute(
      Widget child,
      RouteSettings settings, {
        required TransitionType transitionType,
      }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return TransitionAnimations.buildTransition(
          transitionType,
          animation,
          secondaryAnimation,
          child,
        );
      },
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
    );
  }
}