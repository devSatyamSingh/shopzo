import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/utils/app_storage.dart';
import 'package:shopzo/utils/connectivty_wrapper.dart';
import 'package:shopzo/utils/utils.dart';
import 'package:shopzo/viewmodel/address_provider.dart';
import 'package:shopzo/view/filter_model.dart';
import 'package:shopzo/viewmodel/category_viewmodel.dart';
import 'res/color_constant.dart';
import 'routes/app_routes.dart';
import 'routes/route_name.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
      ],
      child: MaterialApp(
        title: "Shopzo",
        debugShowCheckedModeBanner: false,
        navigatorKey: AppUtils.navigatorKey,
        scaffoldMessengerKey: AppUtils.messengerKey,

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

        // This is what makes the No-Internet screen appear on top of
        // whichever screen the user is currently on, without losing
        // that screen's state (form data, scroll position, etc.).
        builder: (context, child) {
          return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}