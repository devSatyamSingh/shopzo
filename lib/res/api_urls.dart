class ApiUrl {
  ApiUrl._();

  //  switch this one line when moving staging → production
  static const String baseUrl = 'https://madhu.fctesting.shop/api';

  // ---- Auth ----
  static const String sendOtp = "$baseUrl/v1/auth/send-otp";
  static const String verifyOtp = "$baseUrl/v1/auth/verify-otp";
  static const String resendOtp = "$baseUrl/v1/auth/resend-otp";
  static const String register = '$baseUrl/v1/customer/register';
  static const String login = '$baseUrl/v1/customer/login';
  static const String refreshToken = '$baseUrl/v1/customer/refresh';
  static const String logout = '$baseUrl/v1/customer/logout';
  static const String categories = '$baseUrl/v1/categories';
  static String categoryById(String id) => '$baseUrl/v1/categories/$id';

  // ---- Home ----
  static const String homeData = "$baseUrl/v1/home";
  static const String banners = "$baseUrl/v1/home/banners";
  static const String flashDeals = "$baseUrl/v1/home/flash-deals";
  static const String topPicks = "$baseUrl/v1/home/top-picks";
  static const String trending = "$baseUrl/v1/home/trending";

  // ---- Categories / Brands ----
  static String categoryProducts(String categoryId) =>
      "$baseUrl/v1/categories/$categoryId/products";
  static const String brands = "$baseUrl/v1/brands";
  static String brandProducts(String brandId) => "$baseUrl/v1/brands/$brandId/products";

  // ---- Search ----
  static const String search = "$baseUrl/v1/search";

  // ---- Products ----
  static String products({
    required int page,
    int limit = 20,
    String? categoryId,
    String? search,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$baseUrl/v1/products?$query';
  }

  /// Public storefront product listing — used by Home sections
  /// (Trending Now, Flash Deals, Top Picks) and category browsing.
  static String websiteProducts({
    int page = 1,
    int limit = 1000,
    String? categoryId,
    String? search,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$baseUrl/v1/websiteProducts?$query';
  }

  /// Full product detail — includes variants, attributes and reviews.
  static String productById(String id) => '$baseUrl/v1/products/$id';

  // ---- Cart ----
  static const String cart = "$baseUrl/v1/website/cart";
  static const String cartItems = "$baseUrl/v1/website/cart/items";
  static String cartItem(String itemId) => "$baseUrl/v1/website/cart/items/$itemId";

  // ---- Checkout ----
  static const String checkoutSummary = "$baseUrl/v1/checkout/summary";
  static const String deliverySlots = "$baseUrl/v1/checkout/delivery-slots";
  static const String placeOrder = "$baseUrl/v1/checkout/place-order";

  // ---- Address ----
  static const String addresses = '$baseUrl/v1/addresses';
  static String addressById(String id) => '$baseUrl/v1/addresses/$id';

  // ---- Payment ----
  static const String paymentMethods = "$baseUrl/payment-methods";
  static const String addCard = "$baseUrl/payment-methods/cards";
  static const String addUpi = "$baseUrl/payment-methods/upi";
  static const String initiatePayment = "$baseUrl/payment/initiate";
  static const String verifyPayment = "$baseUrl/payment/verify";

  // ---- Orders ----
  static const String myOrders = "$baseUrl/v1/orders";
  static String orderDetail(String orderId) => "$baseUrl/v1/orders/$orderId";
  static String cancelOrder(String orderId) => "$baseUrl/v1/orders/$orderId/cancel";
  static String trackOrder(String orderId) => "$baseUrl/v1/orders/$orderId/track";

  // ---- Wishlist ----
  static const String wishlist = "$baseUrl/v1/wishlist";
  static String toggleWishlist(String productId) => "$baseUrl/v1/wishlist/$productId";

  // ---- Coupons ----
  static const String coupons = "$baseUrl/v1/coupons";
  static const String activeCoupons = "$baseUrl/v1/coupons/active";
  static const String validateCoupon = "$baseUrl/v1/coupons/validate";
  // ---- Notifications ----
  static const String notifications = "$baseUrl/v1/notifications";

  // ---- Profile ----
  static const String profile = "$baseUrl/v1/profile";
  static const String updateProfile = "$baseUrl/v1/profile/update";
  static const String updateProfilePhoto = "$baseUrl/v1/profile/photo";
}