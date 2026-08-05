// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:poojify/main.dart';
// import 'package:poojify/model/home_model.dart';
// import 'package:poojify/res/app_color.dart';
// import 'package:poojify/res/app_dimensions.dart';
// import 'package:poojify/res/const_widgets/badge.dart';
// import 'package:poojify/utils/routes/routes_name.dart';
// import 'package:poojify/view/home/category/all_category_screen.dart';
// import 'package:poojify/view/home/section_card_shared.dart';
// import 'package:poojify/view/home/see_all_screen.dart';
// import 'package:poojify/view/home/widgets/section_header.dart';
//
// class _SectionMetrics {
//   final double itemWidth;
//   final double itemHeight;
//   final bool supportsGrid;
//   final int? gridColumns;
//
//   const _SectionMetrics({
//     required this.itemWidth,
//     required this.itemHeight,
//     this.supportsGrid = true,
//     this.gridColumns,
//   });
//
//   static _SectionMetrics of(String sectionType) {
//     switch (sectionType) {
//       case 'category':
//         return const _SectionMetrics(itemWidth: 78, itemHeight: 106, gridColumns: 4);
//       case 'pandit':
//         return const _SectionMetrics(itemWidth: 132, itemHeight: 190);
//       case 'best_offer':
//         return _SectionMetrics(
//           itemWidth: screenWidth * 0.6,
//           itemHeight: screenHeight * 0.17,
//           supportsGrid: false,
//         );
//       case 'products':
//       case 'combo_offer':
//       default:
//         return _SectionMetrics(
//           itemWidth: 112,
//           itemHeight: screenHeight * 0.28,
//           gridColumns: 3,
//         );
//     }
//   }
// }
//
// void navigateToCategory(BuildContext context, int? categoryId) {
//   if (categoryId == null) return;
//   Navigator.pushNamed(
//     context,
//     RouteName.allCategories,
//     arguments: AllCategoriesArgs(initialCategoryId: categoryId, showBack: true),
//   );
// }
//
// class HomeSectionBuilder extends StatelessWidget {
//   const HomeSectionBuilder({super.key, required this.section});
//   final HomeSection section;
//
//   @override
//   Widget build(BuildContext context) {
//     if (section.data.items.isEmpty) return const SizedBox.shrink();
//
//     final metrics = _SectionMetrics.of(section.sectionType);
//
//     switch (section.sectionType) {
//       case 'slider':
//         return _SliderSection(section: section);
//       case 'category':
//         return _DynamicListSection(
//           section: section,
//           metrics: metrics,
//           itemBuilder: (item) => _CategoryCard(item: item),
//         );
//       case 'pandit':
//         return _DynamicListSection(
//           section: section,
//           metrics: metrics,
//           itemBuilder: (item) => _PanditCard(item: item),
//         );
//       case 'best_offer':
//         return _DynamicListSection(
//           section: section,
//           metrics: metrics,
//           itemBuilder: (item) => _BestOfferCard(item: item, width: metrics.itemWidth),
//         );
//       case 'combo_offer':
//       case 'products':
//         return _DynamicListSection(
//           section: section,
//           metrics: metrics,
//           itemBuilder: (item) => SectionItemCard(item: item),
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }
//
// String _apiTypeFor(String sectionType) => switch (sectionType) {
//   'combo_offer' => 'combo',
//   'products' => 'product',
//   _ => sectionType,
// };
//
// const int _kMaxPreviewRows = 2;
//
// class _DynamicListSection extends StatelessWidget {
//   const _DynamicListSection({
//     required this.section,
//     required this.metrics,
//     required this.itemBuilder,
//   });
//
//   final HomeSection section;
//   final _SectionMetrics metrics;
//   final Widget Function(SectionItem) itemBuilder;
//
//   bool get _isGrid =>
//       metrics.supportsGrid &&
//           (section.config.viewType ?? section.data.viewType) == 'grid';
//
//   void _onSeeAll(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SeeAllScreen(
//           type: _apiTypeFor(section.sectionType),
//           title: section.config.title,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final config = section.config;
//     final data = section.data;
//
//     final limit = config.itemLimit > 0 ? config.itemLimit : data.items.length;
//     final visibleItems = data.items.take(limit).toList();
//     final showSeeMore = data.needsSeeMore(config.itemLimit);
//
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppSpacing.h16.height!),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SectionHeader(
//             title: config.title,
//             onSeeAll: showSeeMore ? () => _onSeeAll(context) : null,
//           ),
//           AppSpacing.h14,
//           Padding(
//             // Symmetric horizontal padding — every section, left and right,
//             padding: EdgeInsets.symmetric(horizontal: AppSpacing.w14.width!),
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 final double itemSpacing = AppSpacing.w12.width!;
//                 final double runSpacing = AppSpacing.h12.height!;
//                 final int? forcedColumns = _isGrid ? metrics.gridColumns : null;
//
//                 final double effectiveItemWidth = forcedColumns != null
//                     ? ((constraints.maxWidth -
//                     (itemSpacing * (forcedColumns - 1))) /
//                     forcedColumns)
//                     .clamp(1.0, metrics.itemWidth)
//                     : metrics.itemWidth;
//
//                 final int itemsPerRow = forcedColumns ??
//                     (visibleItems.isEmpty
//                         ? 1
//                         : ((constraints.maxWidth + itemSpacing) /
//                         (metrics.itemWidth + itemSpacing))
//                         .floor()
//                         .clamp(1, 999));
//
//                 final bool needsWrap =
//                     _isGrid && visibleItems.length > itemsPerRow;
//
//                 final List<SectionItem> shownItems = needsWrap
//                     ? visibleItems.take(itemsPerRow * _kMaxPreviewRows).toList()
//                     : visibleItems;
//
//                 // Grid mode: Wrap sizes to its tallest child per row.
//                 // List mode: horizontally-scrollable Row inside IntrinsicHeight
//                 // sizes to its tallest child too — every section takes
//                 // exactly the space its content needs, and rows are
//                 // left-aligned (same as before).
//                 final Widget content = needsWrap
//                     ? Wrap(
//                   spacing: itemSpacing,
//                   runSpacing: runSpacing,
//                   children: shownItems
//                       .map(
//                         (item) => SizedBox(
//                       width: effectiveItemWidth,
//                       child: itemBuilder(item),
//                     ),
//                   )
//                       .toList(),
//                 )
//                     : SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   physics: const BouncingScrollPhysics(),
//                   child: IntrinsicHeight(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         for (int i = 0; i < shownItems.length; i++) ...[
//                           if (i != 0) AppSpacing.w12,
//                           SizedBox(
//                             width: forcedColumns != null
//                                 ? effectiveItemWidth
//                                 : metrics.itemWidth,
//                             child: itemBuilder(shownItems[i]),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 );
//
//                 return AnimatedSwitcher(
//                   duration: AppDurations.normal,
//                   switchInCurve: Curves.easeOut,
//                   switchOutCurve: Curves.easeIn,
//                   transitionBuilder: (child, anim) => FadeTransition(
//                     opacity: anim,
//                     child: SizeTransition(
//                         sizeFactor: anim, axisAlignment: -1, child: child),
//                   ),
//                   child: SizedBox(
//                     key: ValueKey(
//                         '${section.id}_${needsWrap}_${shownItems.length}'),
//                     width: double.infinity,
//                     child: content,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SliderSection extends StatefulWidget {
//   const _SliderSection({required this.section});
//   final HomeSection section;
//
//   @override
//   State<_SliderSection> createState() => _SliderSectionState();
// }
//
// class _SliderSectionState extends State<_SliderSection> {
//   final PageController _pageCtrl = PageController();
//
//   @override
//   void dispose() {
//     _pageCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final banners = widget.section.data.items;
//     if (banners.isEmpty) return const SizedBox.shrink();
//
//     return Padding(
//       padding: EdgeInsets.only(
//         left: AppSpacing.w12.width!,
//         right: AppSpacing.w12.width!,
//         bottom: AppSpacing.h16.height!,
//       ),
//       child: SizedBox(
//         height: screenHeight * 0.24,
//         child: ClipRRect(
//           borderRadius: AppRadius.lg,
//           child: PageView.builder(
//             controller: _pageCtrl,
//             itemCount: banners.length,
//             itemBuilder: (_, i) {
//               final b = banners[i];
//               return GestureDetector(
//                 onTap: () => navigateToCategory(context, b.categoryId),
//                 child: b.image.isEmpty
//                     ? Container(color: AppColor.ltCardBorder)
//                     : CachedNetworkImage(
//                   imageUrl: b.image,
//                   width: double.infinity,
//                   height: screenHeight * 0.24,
//                   fit: BoxFit.fill,
//                   fadeInDuration: AppDurations.fast,
//                   errorWidget: (_, _, _) =>
//                       Container(color: AppColor.ltCardBorder),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _CategoryCard extends StatelessWidget {
//   const _CategoryCard({required this.item});
//   final SectionItem item;
//
//   static const double _boxSize = 75.0;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return GestureDetector(
//       onTap: () => navigateToCategory(context, item.id),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: _boxSize,
//             height: _boxSize,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: isDark ? AppColor.dkSurface : const Color(0xFFFAEEDC),
//               borderRadius: AppRadius.md,
//             ),
//             child: item.image.isEmpty
//                 ? Icon(Icons.auto_awesome_rounded,
//                 color: AppColor.primary.withAlpha(150))
//                 : CachedNetworkImage(
//               imageUrl: item.image,
//               fit: BoxFit.contain,
//               fadeInDuration: AppDurations.fast,
//               errorWidget: (_, _, _) => Icon(
//                   Icons.auto_awesome_rounded,
//                   color: AppColor.primary.withAlpha(150)),
//             ),
//           ),
//           AppSpacing.h6,
//           Text(
//             item.name.replaceAll('\n', ' ').trim(),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: GoogleFonts.poppins(
//               fontSize: AppFontSize.xs,
//               fontWeight: AppFontWeights.semiBold,
//               height: 1.2,
//               color: isDark ? AppColor.dkTextPrimary : AppColor.ltTextSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _PanditCard extends StatelessWidget {
//   const _PanditCard({required this.item});
//   final SectionItem item;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (item.id == null) return;
//         Navigator.pushNamed(context, RouteName.panditDetail, arguments: item.id);
//       },
//       child: Container(
//         padding: AppPadding.sm,
//         decoration: BoxDecoration(
//           color: AppColor.cardColor(context),
//           borderRadius: AppRadius.md,
//           border: Border.all(color: AppColor.cardBorder(context)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: AppRadius.sm,
//               child: item.image.isEmpty
//                   ? Container(
//                 width: screenWidth * 0.1,
//                 height: screenHeight * 0.1,
//                 color: AppColor.primary.withAlpha(30),
//                 child: Icon(Icons.person_rounded, color: AppColor.primary),
//               )
//                   : CachedNetworkImage(
//                 imageUrl: item.image,
//                 width: screenWidth * 0.25,
//                 height: screenHeight * 0.1,
//                 fit: BoxFit.cover,
//                 fadeInDuration: AppDurations.fast,
//               ),
//             ),
//             AppSpacing.h8,
//             Text(
//               item.name,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: GoogleFonts.poppins(
//                 fontSize: AppFontSize.sm,
//                 fontWeight: AppFontWeights.semiBold,
//                 color: AppColor.textPrimary(context),
//               ),
//             ),
//             if ((item.city ?? '').isNotEmpty) ...[
//               const SizedBox(height: 2),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.location_on_rounded,
//                       size: 11, color: AppColor.textHint(context)),
//                   const SizedBox(width: 2),
//                   Flexible(
//                     child: Text(
//                       item.city!,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.poppins(
//                           fontSize: AppFontSize.xs, color: AppColor.textHint(context)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             if (item.experienceYears != null) ...[
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                     color: AppColor.primary.withAlpha(22),
//                     borderRadius: AppRadius.circular),
//                 child: Text(
//                   '${item.experienceYears} yrs exp',
//                   style: GoogleFonts.poppins(
//                       fontSize: AppFontSize.xs,
//                       fontWeight: AppFontWeights.medium,
//                       color: AppColor.primaryDark),
//                 ),
//               ),
//             ],
//             AppSpacing.h8,
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               decoration:
//               BoxDecoration(color: AppColor.primary, borderRadius: AppRadius.sm),
//               child: Text(
//                 'Book Now',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   fontSize: AppFontSize.xs,
//                   fontWeight: AppFontWeights.semiBold,
//                   color: AppColor.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _BestOfferCard extends StatelessWidget {
//   const _BestOfferCard({required this.item, required this.width});
//   final SectionItem item;
//   final double width;
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: () => navigateToCategory(context, item.categoryId),
//     child: Container(
//       width: width,
//       decoration: BoxDecoration(
//         borderRadius: AppRadius.lg,
//         border: Border.all(color: AppColor.cardBorder(context)),
//       ),
//       child: ClipRRect(
//         borderRadius: AppRadius.lg,
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             item.image.isEmpty
//                 ? Container(color: AppColor.dkSurfaceTwo)
//                 : CachedNetworkImage(
//                 imageUrl: item.image,
//                 fit: BoxFit.cover,
//                 fadeInDuration: AppDurations.fast),
//             const Positioned(
//                 top: 8,
//                 left: 8,
//                 child: BadgeSection(label: '🔥 Best Offer', color: AppColor.yellow)),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(10, 22, 10, 10),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [AppColor.transparent, AppColor.black.withAlpha(190)],
//                   ),
//                 ),
//                 child: Text(
//                   item.name,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: GoogleFonts.poppins(
//                     fontSize: AppFontSize.sm - 1,
//                     fontWeight: AppFontWeights.medium,
//                     color: AppColor.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// } @Harsh Sir Founder Code sir