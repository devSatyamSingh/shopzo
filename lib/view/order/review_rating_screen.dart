// lib/view/review/review_rating_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/button_context.dart';

class ReviewRatingScreen extends StatefulWidget {
  const ReviewRatingScreen({super.key});

  @override
  State<ReviewRatingScreen> createState() => _ReviewRatingScreenState();
}

class _ReviewRatingScreenState extends State<ReviewRatingScreen> {
  double _rating = 0;
  int _hoveredRating = 0;
  final List<String> _selectedFeatures = [];
  final TextEditingController _reviewController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.high_quality_outlined, 'label': 'Quality Material'},
    {'icon': Icons.local_shipping_rounded, 'label': 'Fast Delivery'},
    {'icon': Icons.check_circle_rounded, 'label': 'Perfect Fit'},
    {'icon': Icons.attach_money_rounded, 'label': 'Value for Money'},
    {'icon': Icons.star_rounded, 'label': 'Premium Feel'},
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: ColorConstant.errorColor,
        ),
      );
      return;
    }

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _takePhoto() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: ColorConstant.errorColor,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _toggleFeature(String feature) {
    setState(() {
      if (_selectedFeatures.contains(feature)) {
        _selectedFeatures.remove(feature);
      } else {
        _selectedFeatures.add(feature);
      }
    });
  }

  void _submitReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please rate the product'),
          backgroundColor: ColorConstant.errorColor,
        ),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write a review'),
          backgroundColor: ColorConstant.errorColor,
        ),
      );
      return;
    }

    // Submit review logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Review submitted successfully!'),
        backgroundColor: ColorConstant.successColor,
      ),
    );

    // Navigate back after submission
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: ColorConstant.headlineTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextContext(
          text: 'Rate your Experience',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Verified Purchase Badge ----------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorConstant.successColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: ColorConstant.successColor, size: 16),
                  const SizedBox(width: 6),
                  TextContext(
                    text: 'VERIFIED PURCHASE',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.successColor,
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.012),

            // ---------------- Product Info ----------------
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: ColorConstant.fieldFillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.watch_rounded,
                      color: ColorConstant.placeholderColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextContext(
                        text: 'Vanguard Chrono - Silver Edition',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorConstant.headlineTextColor,
                      ),
                      TextContext(
                        text: 'Delivered on Oct 24, 2023',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.025),

            // ---------------- Rating Section ----------------
            TextContext(
              text: 'How would you rate this product?',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),

            SizedBox(height: size.height * 0.015),

            // Rating Stars
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starIndex.toDouble()),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredRating = starIndex),
                      onExit: (_) => setState(() => _hoveredRating = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          _rating >= starIndex || _hoveredRating >= starIndex
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 42,
                          color: _rating >= starIndex || _hoveredRating >= starIndex
                              ? ColorConstant.ratingStarColor
                              : ColorConstant.borderColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Rating Label
            Center(
              child: TextContext(
                text: _getRatingLabel(_rating),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _rating > 0
                    ? ColorConstant.primaryColor
                    : ColorConstant.placeholderColor,
              ),
            ),

            SizedBox(height: size.height * 0.025),

            // ---------------- Features Section ----------------
            TextContext(
              text: 'What did you like most?',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),

            SizedBox(height: size.height * 0.012),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _features.map((feature) {
                final isSelected = _selectedFeatures.contains(feature['label']);
                return GestureDetector(
                  onTap: () => _toggleFeature(feature['label']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorConstant.primaryColor
                          : ColorConstant.whiteColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? ColorConstant.primaryColor
                            : ColorConstant.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          feature['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : ColorConstant.bodyTextColor,
                        ),
                        const SizedBox(width: 6),
                        TextContext(
                          text: feature['label'] as String,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : ColorConstant.bodyTextColor,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: size.height * 0.025),

            // ---------------- Review Text Area ----------------
            TextContext(
              text: 'Tell us more',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),

            SizedBox(height: size.height * 0.012),

            Container(
              decoration: BoxDecoration(
                color: ColorConstant.whiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorConstant.borderColor),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 4,
                maxLength: 500,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: ColorConstant.headlineTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your detailed review here...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: ColorConstant.placeholderColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterText: '',
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // ---------------- Add Photos/Videos ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextContext(
                  text: 'Add Photos/Videos',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.headlineTextColor,
                ),
                TextContext(
                  text: '${_selectedImages.length}/5',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.placeholderColor,
                ),
              ],
            ),

            SizedBox(height: size.height * 0.012),

            // Image Grid with Add More and Camera options
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: size.height * 0.15,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length +
                      (_selectedImages.length < 5 ? 1 : 0) +
                      (_selectedImages.length < 5 ? 1 : 0), // Always show both options if less than 5
                  separatorBuilder: (_, __) => SizedBox(width: size.width * 0.03),
                  itemBuilder: (context, index) {
                    // Show images first
                    if (index < _selectedImages.length) {
                      return _buildImageCard(index, size);
                    }

                    // Calculate which option button to show
                    final buttonIndex = index - _selectedImages.length;

                    if (buttonIndex == 0) {
                      return _buildAddPhotoButton(size);
                    } else if (buttonIndex == 1) {
                      return _buildCameraButton(size);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              )
            else
            // Empty state - Show both add buttons
              SizedBox(
                height: size.height * 0.12,
                child: Row(
                  children: [
                    _buildAddPhotoButton(size),
                    SizedBox(width: size.width * 0.03),
                    _buildCameraButton(size),
                  ],
                ),
              ),

            SizedBox(height: size.height * 0.03),

            // ---------------- Submit Button ----------------
            CustomButton(
              text: 'Submit Review',
              onTap: _submitReview,
              color: ColorConstant.primaryColor,
              icon: Icons.send_rounded,
              iconColor: ColorConstant.whiteColor,
            ),

            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(int index, Size size) {
    return Stack(
      children: [
        Container(
          height: size.height * 0.15,
          width: size.height * 0.15,
          decoration: BoxDecoration(
            color: ColorConstant.fieldFillColor,
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(File(_selectedImages[index].path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              height: 24,
              width: 24,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(Size size) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: size.height * 0.15,
        width: size.height * 0.15,
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorConstant.borderColor,
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_rounded,
              color: ColorConstant.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            TextContext(
              text: 'Add Photos',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ColorConstant.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton(Size size) {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        height: size.height * 0.15,
        width: size.height * 0.15,
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorConstant.borderColor,
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              color: ColorConstant.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            TextContext(
              text: 'Camera',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ColorConstant.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating == 0) return 'Tap to rate';
    if (rating == 1) return 'Poor';
    if (rating == 2) return 'Fair';
    if (rating == 3) return 'Good';
    if (rating == 4) return 'Very Good';
    return 'Excellent';
  }
}