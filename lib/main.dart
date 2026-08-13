import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/utils/app_storage.dart';
import 'package:shopzo/utils/connectivty_wrapper.dart';
import 'package:shopzo/utils/utils.dart';
import 'package:shopzo/localization/app_locales.dart';
import 'package:shopzo/localization/language_provider.dart';
import 'package:shopzo/viewmodel/address/address_provider.dart';
import 'package:shopzo/view/filter_model.dart';
import 'package:shopzo/viewmodel/address/address_viewmodel.dart';
import 'package:shopzo/viewmodel/banner_viewmodel.dart';
import 'package:shopzo/viewmodel/best_seller_viewmodel.dart';
import 'package:shopzo/viewmodel/cart/cart_viewmodel.dart';
import 'package:shopzo/viewmodel/category_subcategory/category_viewmodel.dart';
import 'package:shopzo/viewmodel/cms_viewmodel.dart';
import 'package:shopzo/viewmodel/coupon/coupon_viewmodel.dart';
import 'package:shopzo/viewmodel/order_checkout/order_checkout_viewmodel.dart';
import 'package:shopzo/viewmodel/orderview/create_return_viewmodel.dart';
import 'package:shopzo/viewmodel/orderview/order_details_viewmodel.dart';
import 'package:shopzo/viewmodel/orderview/orderlist_viewmodel.dart';
import 'package:shopzo/viewmodel/orderview/return_details_viewmodel.dart';
import 'package:shopzo/viewmodel/orderview/return_list_viewmodel.dart';
import 'package:shopzo/viewmodel/product/product_viewmodel.dart';
import 'package:shopzo/viewmodel/productdetails_and_list/product_details_viewmodel.dart';
import 'package:shopzo/viewmodel/productdetails_and_list/product_list_viewmodel.dart';
import 'package:shopzo/viewmodel/profile_viewmodel.dart';
import 'package:shopzo/viewmodel/review/review_viewmodel.dart';
import 'package:shopzo/viewmodel/search_viewmodel.dart';
import 'package:shopzo/viewmodel/support_viewmodel.dart';
import 'package:shopzo/viewmodel/top_pick_viewmodel.dart';
import 'package:shopzo/viewmodel/wishlist_viewmodel.dart';
import 'res/color_constant.dart';
import 'routes/app_routes.dart';
import 'routes/route_name.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AppStorage.init();

  final savedLanguageCode = AppStorage.getLanguageCode();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: 'assets/translations',
      fallbackLocale: AppLocales.defaultLocale,
      startLocale: Locale(savedLanguageCode),
      saveLocale: false,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => ProductListViewModel()),
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryProductViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => CouponViewModel()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => BannerViewModel()),
        ChangeNotifierProvider(create: (_) => BestSellerViewModel()),
        ChangeNotifierProvider(create: (_) => TopPicksViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CreateReturnViewModel()),
        ChangeNotifierProvider(create: (_) => ReturnDetailViewModel()),
        ChangeNotifierProvider(create: (_) => ReturnListViewModel()),
        ChangeNotifierProvider(create: (_) => SupportViewModel()),
        ChangeNotifierProvider(create: (_) => CmsPageViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => OrderDetailViewModel(),),
      ],
      child: MaterialApp(
        title: "Shopzo",
        debugShowCheckedModeBanner: false,
        navigatorKey: AppUtils.navigatorKey,
        scaffoldMessengerKey: AppUtils.messengerKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: "Poppins",
          scaffoldBackgroundColor: ColorConstant.scaffoldBgColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: ColorConstant.primaryColor,
            primary: ColorConstant.primaryColor,
            secondary: ColorConstant.orangeColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: ColorConstant.whiteColor,
            elevation: 0,
            iconTheme: IconThemeData(color: ColorConstant.headlineTextColor),
            titleTextStyle: TextStyle(
              color: ColorConstant.headlineTextColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
        ),
        initialRoute: RouteName.splash,
        onGenerateRoute: AppRoutes.generateRoute,
        builder: (context, child) {
          return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}