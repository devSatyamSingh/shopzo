/// Shopzo — All API endpoints in one place.
/// Never hardcode a URL inside a repo/service file — always reference
/// ApiUrls.xxx so switching environments (dev/staging/prod) is a
/// one-line change.
class ApiUrls {
  ApiUrls._();

  // ---------------- BASE ----------------
  // TODO: replace with your actual backend base URL per environment.
  static const String baseUrl = "https://api.shopzo.com/api/v1";

  // ---------------- AUTH ----------------
  static const String sendOtp = "$baseUrl/auth/send-otp";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String refreshToken = "$baseUrl/auth/refresh-token";
  static const String logout = "$baseUrl/auth/logout";

  // ---------------- TENANT / CONFIG ----------------
  static const String tenantConfig = "$baseUrl/tenant/config";

  // ---------------- HOME ----------------
  static const String banners = "$baseUrl/banners";
  static const String featuredProducts = "$baseUrl/products/featured";

  // ---------------- CATEGORY / PRODUCT ----------------
  static const String categories = "$baseUrl/categories";
  static const String products = "$baseUrl/products";
  static String productDetail(String id) => "$baseUrl/products/$id";
  static String productVariants(String id) => "$baseUrl/products/$id/variants";
  static const String searchProducts = "$baseUrl/products/search";

  // ---------------- CART ----------------
  static const String cart = "$baseUrl/cart";
  static const String addToCart = "$baseUrl/cart/add";
  static const String updateCartItem = "$baseUrl/cart/update";
  static const String removeCartItem = "$baseUrl/cart/remove";
  static const String cartCount = "$baseUrl/cart/count";

  // ---------------- COUPON ----------------
  static const String applyCoupon = "$baseUrl/coupons/apply";
  static const String availableCoupons = "$baseUrl/coupons";

  // ---------------- ADDRESS ----------------
  static const String addresses = "$baseUrl/addresses";
  static String addressById(String id) => "$baseUrl/addresses/$id";

  // ---------------- CHECKOUT / ORDER ----------------
  static const String validateCheckout = "$baseUrl/checkout/validate";
  static const String createOrder = "$baseUrl/orders";
  static const String myOrders = "$baseUrl/orders";
  static String orderDetail(String id) => "$baseUrl/orders/$id";
  static String orderTracking(String id) => "$baseUrl/orders/$id/tracking";
  static String cancelOrder(String id) => "$baseUrl/orders/$id/cancel";
  static String returnRequest(String id) => "$baseUrl/orders/$id/return";

  // ---------------- PAYMENT ----------------
  static const String createPaymentOrder = "$baseUrl/payments/create-order";
  static const String verifyPayment = "$baseUrl/payments/verify";

  // ---------------- WISHLIST ----------------
  static const String wishlist = "$baseUrl/wishlist";

  // ---------------- REVIEWS ----------------
  static String productReviews(String productId) =>
      "$baseUrl/products/$productId/reviews";
  static const String addReview = "$baseUrl/reviews";

  // ---------------- PROFILE ----------------
  static const String profile = "$baseUrl/profile";
  static const String updateProfile = "$baseUrl/profile/update";

  // ---------------- NOTIFICATIONS ----------------
  static const String notifications = "$baseUrl/notifications";

  // ---------------- SUPPORT ----------------
  static const String raiseTicket = "$baseUrl/support/ticket";
  static const String faqs = "$baseUrl/support/faqs";
}
