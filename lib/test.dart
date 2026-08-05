// import 'package:flutter/material.dart';
// import 'package:poojify/res/app_color.dart';
// import 'package:poojify/res/app_dimensions.dart';
// import 'package:poojify/res/app_gradient.dart';
// import 'package:poojify/res/const_widgets/const_gradient_container.dart';
// import 'package:poojify/view/home/buy_again_Section.dart';
// import 'package:poojify/view/home/cart_widget/center_cart_widget.dart';
// import 'package:poojify/view/home/home_dyamic_section.dart';
// import 'package:poojify/view/home/home_dynamic_shimer.dart';
// import 'package:poojify/view/home/whatsapp_widget/whtsapp_button.dart';
// import 'package:poojify/view/home/widgets/home_app_bar.dart';
// import 'package:poojify/view_model/app_notification_view_model.dart';
// import 'package:poojify/view_model/cart_view_model.dart';
// import 'package:poojify/view_model/home_section_view_model.dart';
// import 'package:poojify/view_model/order_his_view_model.dart';
// import 'package:provider/provider.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<HomeSectionsViewModel>().fetchHomeSections(context);
//       context.read<OrderHistoryViewModel>().fetchOrderDetails();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cartCount = context.select<CartSectionViewModel, int>((c) => c.totalCount);
//
//     return Scaffold(
//       backgroundColor: AppColor.background(context),
//       body: GradientContainer(
//         isDark: isDark,
//         borderRadius: AppGradients.topRounded,
//         child: Stack(
//           children: [
//             _HomeSectionsList(cartCount: cartCount),
//             WhatsAppButton(cartCount: cartCount, visible: true),
//             const CenteredCartBar(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _HomeSectionsList extends StatelessWidget {
//   const _HomeSectionsList({required this.cartCount});
//   final int cartCount;
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<HomeSectionsViewModel>();
//
//     if (vm.isLoading && vm.activeSections.isEmpty) {
//       return const HomeDynamicShimmer();
//     }
//
//     return RefreshIndicator(
//       color: AppColor.primary,
//       backgroundColor: AppColor.cardColor(context),
//       onRefresh: () async {
//         await Future.wait([
//           vm.fetchHomeSections(context),
//           context.read<OrderHistoryViewModel>().fetchOrderDetails(),
//         ]);
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(parent: ScrollPhysics()),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             HomeAppBar(
//               cartCount: cartCount,
//               notifCount: context.select<AppNotificationViewModel, int>((n) => n.unreadCount),
//             ),
//             AppSpacing.h10,
//             for (final section in vm.activeSections) HomeSectionBuilder(section: section),
//             const BuyAgainSection(),
//             AppSpacing.h56,
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
