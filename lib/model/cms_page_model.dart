import 'package:flutter/material.dart';

/// Backend types: ABOUT_US, TERMS_AND_CONDITIONS, PRIVACY_POLICY, RETURN_AND_REFUND_POLICY
enum CmsPageType {
  aboutUs,
  termsAndConditions,
  privacyPolicy,
  returnAndRefundPolicy,
}

extension CmsPageTypeX on CmsPageType {
  /// API me jo exact string bhejna/match karna hai
  String get apiValue {
    switch (this) {
      case CmsPageType.aboutUs:
        return 'ABOUT_US';
      case CmsPageType.termsAndConditions:
        return 'TERMS_AND_CONDITIONS';
      case CmsPageType.privacyPolicy:
        return 'PRIVACY_POLICY';
      case CmsPageType.returnAndRefundPolicy:
        return 'RETURN_AND_REFUND_POLICY';
    }
  }

  /// API se title aane se pehle AppBar me dikhane wala fallback title
  String get fallbackTitle {
    switch (this) {
      case CmsPageType.aboutUs:
        return 'About Us';
      case CmsPageType.termsAndConditions:
        return 'Terms and Conditions';
      case CmsPageType.privacyPolicy:
        return 'Privacy Policy';
      case CmsPageType.returnAndRefundPolicy:
        return 'Return and Refund Policy';
    }
  }

  IconData get icon {
    switch (this) {
      case CmsPageType.aboutUs:
        return Icons.info_outline_rounded;
      case CmsPageType.termsAndConditions:
        return Icons.description_outlined;
      case CmsPageType.privacyPolicy:
        return Icons.privacy_tip_outlined;
      case CmsPageType.returnAndRefundPolicy:
        return Icons.assignment_return_outlined;
    }
  }
}

/// GET /website/pages — list item (type, title, updatedAt)
class CmsPageListItem {
  final String type;
  final String title;
  final String updatedAt;

  CmsPageListItem({
    required this.type,
    required this.title,
    required this.updatedAt,
  });

  factory CmsPageListItem.fromJson(Map<String, dynamic> json) {
    return CmsPageListItem(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

/// GET /website/pages/:type — full detail (content HTML ke saath)
class CmsPageDetailModel {
  final String id;
  final String type;
  final String title;
  final String content;
  final String updatedAt;

  CmsPageDetailModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  factory CmsPageDetailModel.fromJson(Map<String, dynamic> json) {
    return CmsPageDetailModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  // e.g. "Updated 12 Aug 2026"
  String get formattedUpdatedAt {
    final date = DateTime.tryParse(updatedAt);
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Updated ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}