import 'package:flutter/material.dart';
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
            fontWeight: FontWeight.w700,
            fontFamily: "Poppins",
          ),
        ),
      ),
      initialRoute: RouteName.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
