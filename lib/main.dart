import 'package:flutter/material.dart';
import 'package:shopzo/utils/connectivty_wrapper.dart';
import 'package:shopzo/utils/utils.dart';
import 'res/color_constant.dart';
import 'routes/app_routes.dart';
import 'routes/route_name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shopzo",
      debugShowCheckedModeBanner: false,

      // Required so AppUtils snackbars/dialogs can be shown from
      // anywhere (not just from inside a widget's build method).
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
    );
  }
}