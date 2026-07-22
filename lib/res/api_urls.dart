
class ApiUrl {
  ApiUrl._();

  //  switch this one line when moving staging → production
  static const String baseUrl = "https://api.shopzo.com/v1";

  // ---- Auth ----
  static const String sendOtp = "$baseUrl/auth/send-otp";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String resendOtp = "$baseUrl/auth/resend-otp";
  static const String logout = "$baseUrl/auth/logout";

  // ---- Home ----
  static const String homeData = "$baseUrl/home";
  static const String banners = "$baseUrl/home/banners";
  static const String flashDeals = "$baseUrl/home/flash-deals";
  static const String topPicks = "$baseUrl/home/top-picks";
  static const String trending = "$baseUrl/home/trending";

  // ---- Categories / Brands ----
  static const String categories = "$baseUrl/categories";
  static String categoryProducts(String categoryId) =>
      "$baseUrl/categories/$categoryId/products";
  static const String brands = "$baseUrl/brands";
  static String brandProducts(String brandId) => "$baseUrl/brands/$brandId/products";

  // ---- Search ----
  static const String search = "$baseUrl/search";

  // ---- Products ----
  static String productDetail(String productId) => "$baseUrl/products/$productId";
  static String productReviews(String productId) => "$baseUrl/products/$productId/reviews";

  // ---- Cart ----
  static const String cart = "$baseUrl/cart";
  static const String addToCart = "$baseUrl/cart/add";
  static String updateCartItem(String itemId) => "$baseUrl/cart/$itemId";
  static String removeCartItem(String itemId) => "$baseUrl/cart/$itemId";
  static const String applyCoupon = "$baseUrl/cart/apply-coupon";
  static const String removeCoupon = "$baseUrl/cart/remove-coupon";

  // ---- Checkout ----
  static const String checkoutSummary = "$baseUrl/checkout/summary";
  static const String deliverySlots = "$baseUrl/checkout/delivery-slots";
  static const String placeOrder = "$baseUrl/checkout/place-order";

  // ---- Address ----
  static const String addresses = "$baseUrl/addresses";
  static String addressById(String addressId) => "$baseUrl/addresses/$addressId";
  static const String reverseGeocode = "$baseUrl/addresses/reverse-geocode";

  // ---- Payment ----
  static const String paymentMethods = "$baseUrl/payment-methods";
  static const String addCard = "$baseUrl/payment-methods/cards";
  static const String addUpi = "$baseUrl/payment-methods/upi";
  static const String initiatePayment = "$baseUrl/payment/initiate";
  static const String verifyPayment = "$baseUrl/payment/verify";

  // ---- Orders ----
  static const String myOrders = "$baseUrl/orders";
  static String orderDetail(String orderId) => "$baseUrl/orders/$orderId";
  static String cancelOrder(String orderId) => "$baseUrl/orders/$orderId/cancel";
  static String trackOrder(String orderId) => "$baseUrl/orders/$orderId/track";

  // ---- Wishlist ----
  static const String wishlist = "$baseUrl/wishlist";
  static String toggleWishlist(String productId) => "$baseUrl/wishlist/$productId";

  // ---- Coupons ----
  static const String coupons = "$baseUrl/coupons";

  // ---- Notifications ----
  static const String notifications = "$baseUrl/notifications";

  // ---- Profile ----
  static const String profile = "$baseUrl/profile";
  static const String updateProfile = "$baseUrl/profile/update";
  static const String updateProfilePhoto = "$baseUrl/profile/photo";
}