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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final languageProvider = context.watch<LanguageProvider>();
    final currentCode = languageProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: TextContext(
          text: 'settings.select_language'.tr(),
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          itemCount: AppLocales.languages.length,
          separatorBuilder: (_, __) => SizedBox(height: size.height * 0.015),
          itemBuilder: (context, index) {
            final LanguageModel lang = AppLocales.languages[index];
            final bool isSelected = lang.code == currentCode;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await context.read<LanguageProvider>().changeLanguage(
                  context,
                  Locale(lang.code),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.045,
                  vertical: size.height * 0.018,
                ),
                decoration: BoxDecoration(
                  color: ColorConstant.cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? ColorConstant.primaryColor
                        : ColorConstant.dividerColor,
                    width: isSelected ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
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
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? ColorConstant.primaryColor
                          : ColorConstant.placeholderColor,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}