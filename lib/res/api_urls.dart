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
  static const String customerProfile = '$baseUrl/v1/customer/profile';

  // ---- Home ----
  static const String homeData = "$baseUrl/v1/home";
  static const String banners = '$baseUrl/v1/website/banners';
  static const String flashDeals = "$baseUrl/v1/home/flash-deals";
  static const String trendingProducts  = "$baseUrl/v1/websiteProducts/trending";
  static const String bestSellers = "$baseUrl/v1/websiteProducts/bestsellers";

  // ---- Categories / Brands ----
  static String categoryProducts(String categoryId) => "$baseUrl/v1/categories/$categoryId/products";
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

  static String websiteProducts({
    int page = 1,
    int limit = 1000,
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (minPrice != null) 'minPrice': '$minPrice',
      if (maxPrice != null) 'maxPrice': '$maxPrice',
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$baseUrl/v1/websiteProducts?$query';
  }

  static String searchSuggestions(String query, {int limit = 8}) =>
      '$baseUrl/v1/website/search/suggestions?q=${Uri.encodeComponent(query)}&limit=$limit';

  // ---- Home ----
  static String recommendedProducts({int limit = 10}) =>
      '$baseUrl/v1/websiteProducts/recommended?limit=$limit';

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
  static const String orders = "$baseUrl/v1/orders";
  static const String placeOnlineOrder = "$baseUrl/v1/orders/online";
  static const String previewOrder = "$baseUrl/v1/orders/preview";
  static String orderById(String orderId) => "$baseUrl/v1/orders/$orderId";
  static String cancelOrder(String orderId) => "$baseUrl/v1/orders/$orderId/cancel";

  // ---- Return/Exchange ----
  static String get returns => '$baseUrl/v1/website/returns';
  static String returnById(String id) => '$baseUrl/v1/website/returns/$id';
  static String cancelReturn(String id) => '$baseUrl/v1/website/returns/$id/cancel';

  // ---- Wishlist ----
  static const String wishlist = '$baseUrl/v1/website/wishlist';
  static const String wishlistToggle = '$baseUrl/v1/website/wishlist/toggle';
  static String wishlistMoveToCart(String id) => '$baseUrl/v1/website/wishlist/$id/move-to-cart';

  // ---- Coupons ----
  static const String coupons = "$baseUrl/v1/coupons";
  static const String activeCoupons = "$baseUrl/v1/coupons/active";
  static const String validateCoupon = "$baseUrl/v1/coupons/validate";
  // ---- Notifications ----
  static const String notifications = "$baseUrl/v1/notifications";

  // ---- Reviews ----
  static const String reviews = "$baseUrl/v1/reviews";

  static String productReviews(String productId) =>
      "$baseUrl/v1/reviews/product/$productId";

  // ---- Profile ----
  static const String profile = "$baseUrl/v1/profile";
  static const String updateProfile = "$baseUrl/v1/profile/update";
  static const String updateProfilePhoto = "$baseUrl/v1/profile/photo";

  // Support ticket endpoints — same URL, GET = list, POST = create
  static String get mySupportTickets => '$baseUrl/v1/website/support';
  static String get createSupportTicket => '$baseUrl/v1/website/support';

  // CMS website pages
  static String get websitePages => '$baseUrl/v1/website/pages';
  static String pageByType(String type) => '$baseUrl/v1/website/pages/$type';

  // Slug-based product detail — sirf relatedProducts nikalne ke liye use ho raha hai
  static String websiteProductBySlug(String slug) => '$baseUrl/v1/websiteProducts/$slug';
}
