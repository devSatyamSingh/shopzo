import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_locales.dart';
import '../../localization/language_model.dart';
import '../../localization/language_provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  // Vibrant gradient palette cycled per language avatar badge.
  static const List<List<Color>> _badgeGradients = [
    [Color(0xFF6366F1), Color(0xFF4F46E5)], // indigo
    [Color(0xFFF97316), Color(0xFFEA580C)], // orange
    [Color(0xFF16A34A), Color(0xFF15803D)], // green
    [Color(0xFFDB2777), Color(0xFFBE185D)], // pink
    [Color(0xFF0EA5E9), Color(0xFF0284C7)], // sky
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final languageProvider = context.watch<LanguageProvider>();
    final currentCode = languageProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            SizedBox(height: size.height * 0.006),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextContext(
                  text: 'settings.language_subtitle'.tr(),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.labelTextColor,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.012),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.008,
                ),
                itemCount: AppLocales.languages.length,
                separatorBuilder: (_, __) => SizedBox(height: size.height * 0.014),
                itemBuilder: (context, index) {
                  final LanguageModel lang = AppLocales.languages[index];
                  final bool isSelected = lang.code == currentCode;
                  final gradient = _badgeGradients[index % _badgeGradients.length];

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      await context.read<LanguageProvider>().changeLanguage(
                        context,
                        Locale(lang.code),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.016,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? ColorConstant.primaryLight : ColorConstant.cardBgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor.withOpacity(0.6),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? ColorConstant.primaryColor.withOpacity(0.14)
                                : ColorConstant.blackColor.withOpacity(0.035),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lang.code.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextContext(
                                  text: lang.nativeName,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.headlineTextColor,
                                ),
                                const SizedBox(height: 2),
                                TextContext(
                                  text: lang.name,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstant.labelTextColor,
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: isSelected
                                ? Container(
                              key: const ValueKey('selected'),
                              height: 26,
                              width: 26,
                              decoration: const BoxDecoration(
                                color: ColorConstant.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                            )
                                : Container(
                              key: const ValueKey('unselected'),
                              height: 26,
                              width: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: ColorConstant.borderColor, width: 1.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.fromLTRB(size.width * 0.03, size.height * 0.014, size.width * 0.045, size.height * 0.016),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        boxShadow: [
          BoxShadow(color: ColorConstant.blackColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_rounded, color: ColorConstant.headlineTextColor, size: 20),
            ),
          ),
          Expanded(
            child: TextContext(
              text: 'settings.select_language'.tr(),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ColorConstant.headlineTextColor,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 38), // symmetry
        ],
      ),
    );
  }
}