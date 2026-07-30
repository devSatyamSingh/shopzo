class ApiUrl {
  ApiUrl._();

  //  switch this one line when moving staging → production
  static const String baseUrl = 'https://madhu.fctesting.shop/api';

  // ---- Auth ----
  static const String sendOtp = "$baseUrl/auth/send-otp";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String resendOtp = "$baseUrl/auth/resend-otp";
  static const String register = '$baseUrl/customer/register';
  static const String login = '$baseUrl/customer/login';
  static const String refreshToken = '$baseUrl/customer/refresh';
  static const String logout = '$baseUrl/customer/logout';
  static const String categories = '$baseUrl/categories';
  static String categoryById(String id) => '$baseUrl/categories/$id';

  // ---- Home ----
  static const String homeData = "$baseUrl/home";
  static const String banners = "$baseUrl/home/banners";
  static const String flashDeals = "$baseUrl/home/flash-deals";
  static const String topPicks = "$baseUrl/home/top-picks";
  static const String trending = "$baseUrl/home/trending";

  // ---- Categories / Brands ----
  static String categoryProducts(String categoryId) =>
      "$baseUrl/categories/$categoryId/products";
  static const String brands = "$baseUrl/brands";
  static String brandProducts(String brandId) => "$baseUrl/brands/$brandId/products";

  // ---- Search ----
  static const String search = "$baseUrl/search";

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
    return '$baseUrl/products?$query';
  }

  /// Public storefront product listing — used by Home sections
  /// (Trending Now, Flash Deals, Top Picks) and category browsing.
  static String websiteProducts({
    int page = 1,
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
    return '$baseUrl/websiteProducts?$query';
  }

  /// Full product detail — includes variants, attributes and reviews.
  static String productById(String id) => '$baseUrl/products/$id';

  // ---- Cart ----
  static const String cart = "$baseUrl/website/cart";
  static const String cartItems = "$baseUrl/website/cart/items";
  static String cartItem(String itemId) => "$baseUrl/website/cart/items/$itemId";

  // ---- Checkout ----
  static const String checkoutSummary = "$baseUrl/checkout/summary";
  static const String deliverySlots = "$baseUrl/checkout/delivery-slots";
  static const String placeOrder = "$baseUrl/checkout/place-order";

  // ---- Address ----
  static const String addresses = '$baseUrl/addresses';
  static String addressById(String id) => '$baseUrl/addresses/$id';

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