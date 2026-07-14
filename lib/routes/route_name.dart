/// Shopzo — every screen's route name as a constant.
/// Never use raw string route names when calling Navigator — always
/// reference RouteName.xxx so a typo becomes a compile-time-visible bug.
class RouteName {
  RouteName._();

  static const String splash = "/splash";
  static const String onboarding = "/onboarding";

  // ---- Auth ----
  static const String login = "/login";
  static const String otpVerify = "/otp-verify";
  static const String register = "/register";

  // ---- Core ----
  static const String home = "/home";
  static const String categories = "/categories";
  static const String productListing = "/product-listing";
  static const String search = "/search";
  static const String productDetail = "/product-detail";
  static const String reviews = "/reviews";

  // ---- Cart / Checkout ----
  static const String cart = "/cart";
  static const String addressList = "/address-list";
  static const String addEditAddress = "/add-edit-address";
  static const String checkout = "/checkout";
  static const String payment = "/payment";
  static const String orderConfirmation = "/order-confirmation";

  // ---- Orders ----
  static const String orderTracking = "/order-tracking";
  static const String myOrders = "/my-orders";
  static const String orderDetail = "/order-detail";
  static const String returnRequest = "/return-request";

  // ---- Account ----
  static const String wishlist = "/wishlist";
  static const String notifications = "/notifications";
  static const String profile = "/profile";
  static const String editProfile = "/edit-profile";
  static const String coupons = "/coupons";
  static const String helpSupport = "/help-support";

  // ---- Misc ----
  static const String noInternet = "/no-internet";
}
