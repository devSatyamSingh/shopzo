import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'color_constant.dart';
import 'text_context.dart';

/// Shopzo — reusable Image Upload helper.
/// Used for: profile photo, product image upload (admin), review photo,
/// return-request photo proof, shop logo upload (tenant onboarding), etc.
///
/// Add to pubspec.yaml:
///   image_picker: ^1.1.2
class ImageUploadHelper {
  ImageUploadHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Shows a bottom sheet with Camera / Gallery options and returns
  /// the picked File, or null if the user cancels.
  static Future<File?> pickImage(
    BuildContext context, {
    bool allowCamera = true,
    bool allowGallery = true,
    double imageQuality = 80,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceSheet(
        allowCamera: allowCamera,
        allowGallery: allowGallery,
      ),
    );

    if (source == null) return null;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality.toInt(),
    );

    if (picked == null) return null;
    return File(picked.path);
  }

  /// Pick multiple images at once (e.g. product gallery images — admin side)
  static Future<List<File>> pickMultipleImages({
    double imageQuality = 80,
    int? limit,
  }) async {
    final List<XFile> picked = await _picker.pickMultiImage(
      imageQuality: imageQuality.toInt(),
      limit: limit,
    );
    return picked.map((e) => File(e.path)).toList();
  }
}

class _ImageSourceSheet extends StatelessWidget {
  final bool allowCamera;
  final bool allowGallery;

  const _ImageSourceSheet({
    required this.allowCamera,
    required this.allowGallery,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: ColorConstant.borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const TextContext(
              text: "Upload Photo",
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (allowCamera)
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: "Camera",
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                if (allowCamera && allowGallery) const SizedBox(width: 16),
                if (allowGallery)
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.photo_library_rounded,
                      label: "Gallery",
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: ColorConstant.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: ColorConstant.primaryColor, size: 28),
            const SizedBox(height: 8),
            TextContext(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
