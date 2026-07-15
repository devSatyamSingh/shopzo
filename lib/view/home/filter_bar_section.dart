import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class FilterChipModel {
  final String label;
  final IconData? icon;
  final bool hasDropdown;

  const FilterChipModel({
    required this.label,
    this.icon,
    this.hasDropdown = true,
  });
}

class FilterBarSection extends StatelessWidget {
  final ValueChanged<int>? onChipTap;

  const FilterBarSection({super.key, this.onChipTap});

  static const List<FilterChipModel> _chips = [
    FilterChipModel(label: 'Sort', icon: Icons.swap_vert_rounded, hasDropdown: false),
    FilterChipModel(label: 'Price'),
    FilterChipModel(label: 'Filters', icon: Icons.tune_rounded),
    FilterChipModel(label: 'Gender'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.05,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => SizedBox(width: size.width * 0.025),
        itemBuilder: (context, index) {
          final chip = _chips[index];
          return GestureDetector(
            onTap: () => onChipTap?.call(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ColorConstant.borderColor),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (chip.icon != null) ...[
                    Icon(chip.icon, size: 16, color: ColorConstant.bodyTextColor),
                    const SizedBox(width: 6),
                  ],
                  TextContext(
                    text: chip.label,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.bodyTextColor,
                  ),
                  if (chip.hasDropdown) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: ColorConstant.bodyTextColor),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}