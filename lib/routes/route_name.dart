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

  // ---- Core / Shell ----
  static const String mainWrapper = "/main_wrapper";
  static const String home = "/home";
  static const String categories = "/categories";
  static const String categoryProducts = "/category-products";
  static const String search = "/search";
  static const String productDetail = "/product-detail";
  static const String notifications = "/notifications";

  // ---- Cart / Checkout ----
  static const String cart = "/cart";
  static const String checkoutAddress = "/checkout-address";
  static const String checkoutSummary = "/checkout-summary";
  static const String checkoutPayment = "/checkout-payment";

  // ---- Address ----
  static const String addressList = "/address-list";
  static const String addEditAddress = "/add-edit-address";

  // ---- Payment ----
  static const String paymentMethods = "/payment-methods";
  static const String addPaymentMethod = "/add-payment-method";

  // ---- Orders ----
  static const String myOrders = "/my-orders";
  static const String orderDetail = "/order-detail";

  // ---- Account ----
  static const String wishlist = "/wishlist";
  static const String coupons = "/coupons";
  static const String helpSupport = "/help-support";
  static const String profileInformation = "/profile-information";
  static const String editProfile = "/edit-profile";
  static const String PrivacySecurity = "/prevacy_security";

  static const String aboutUs = '/about-us';
  static const String termsConditions = '/terms-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String returnRefund = '/return-refund';
  static const String register = '/register';
  static const String reviewRating = '/review-rating';
  static const String subCategory = '/sub-category';

}