import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../../model/cms_page_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../viewmodel/cms_viewmodel.dart';


class CmsPageScreen extends StatelessWidget {
  final CmsPageType type;
  const CmsPageScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CmsPageViewModel()..fetchPage(type.apiValue),
      child: _CmsPageView(type: type),
    );
  }
}

class _CmsPageView extends StatelessWidget {
  final CmsPageType type;
  const _CmsPageView({required this.type});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<CmsPageViewModel>();

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        title: Text(vm.page?.title ?? type.fallbackTitle),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // ---------------- SKELETON LOADING ----------------
            if (vm.isLoading && vm.page == null) {
              return const _CmsSkeleton();
            }

            // ---------------- ERROR ----------------
            if (vm.status == CmsPageStatus.error && vm.page == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 46,
                        color: ColorConstant.placeholderColor,
                      ),
                      const SizedBox(height: 12),
                      TextContext(
                        text: vm.errorMessage ?? 'Failed to load page',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.labelTextColor,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.read<CmsPageViewModel>().retry(),
                        child: const TextContext(
                          text: 'Retry',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ---------------- LOADED ----------------
            final page = vm.page!;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.055,
                vertical: size.height * 0.022,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- header icon + title chip ----
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Icon(type.icon, color: ColorConstant.primaryColor, size: 24),
                  ),
                  SizedBox(height: size.height * 0.016),
                  TextContext(
                    text: page.title,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.headlineTextColor,
                  ),
                  if (page.formattedUpdatedAt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    TextContext(
                      text: page.formattedUpdatedAt,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorConstant.placeholderColor,
                    ),
                  ],
                  SizedBox(height: size.height * 0.02),
                  const Divider(height: 1, color: ColorConstant.dividerColor),
                  SizedBox(height: size.height * 0.02),

                  // ---- actual HTML content from backend ----
                  Html(
                    data: page.content,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontFamily: "Poppins",
                        fontSize: FontSize(13.5),
                        color: ColorConstant.bodyTextColor,
                        lineHeight: const LineHeight(1.6),
                      ),
                      "h1": Style(
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.w700,
                        color: ColorConstant.headlineTextColor,
                        margin: Margins.only(top: 14, bottom: 8),
                      ),
                      "h2": Style(
                        fontSize: FontSize(16),
                        fontWeight: FontWeight.w700,
                        color: ColorConstant.headlineTextColor,
                        margin: Margins.only(top: 14, bottom: 8),
                      ),
                      "h3": Style(
                        fontSize: FontSize(14.5),
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.headlineTextColor,
                        margin: Margins.only(top: 12, bottom: 6),
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 10),
                      ),
                      "strong": Style(
                        fontWeight: FontWeight.w700,
                        color: ColorConstant.headlineTextColor,
                      ),
                      "ul": Style(
                        margin: Margins.only(bottom: 10, left: 4),
                      ),
                      "li": Style(
                        margin: Margins.only(bottom: 6),
                      ),
                      "a": Style(
                        color: ColorConstant.primaryColor,
                        textDecoration: TextDecoration.underline,
                      ),
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ---------------- SKELETON LOADER — paragraph-jaisi shimmer lines ----------------
class _CmsSkeleton extends StatefulWidget {
  const _CmsSkeleton();

  @override
  State<_CmsSkeleton> createState() => _CmsSkeletonState();
}

class _CmsSkeletonState extends State<_CmsSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar({double? width, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.055,
          vertical: size.height * 0.022,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: ColorConstant.fieldFillColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 18),
            _bar(width: size.width * 0.6, height: 18),
            const SizedBox(height: 10),
            _bar(width: size.width * 0.35, height: 11),
            const SizedBox(height: 22),
            Container(height: 1, color: ColorConstant.dividerColor),
            const SizedBox(height: 22),

            _bar(width: size.width * 0.4, height: 14),
            const SizedBox(height: 12),
            for (int i = 0; i < 4; i++) ...[
              _bar(),
              const SizedBox(height: 8),
            ],
            _bar(width: size.width * 0.7),
            const SizedBox(height: 24),

            _bar(width: size.width * 0.45, height: 14),
            const SizedBox(height: 12),
            for (int i = 0; i < 3; i++) ...[
              _bar(),
              const SizedBox(height: 8),
            ],
            _bar(width: size.width * 0.5),
          ],
        ),
      ),
    );
  }
}