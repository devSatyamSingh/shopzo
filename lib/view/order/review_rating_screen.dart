import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/app_storage.dart';
import '../../viewmodel/review_viewmodel.dart';

/// Order Detail screen ke andar se call karo:
///   showReviewBottomSheet(context, productId: item.productId, productName: item.displayName);
void showReviewBottomSheet(BuildContext context, {required String productId, required String productName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<ReviewViewModel>(),
      child: _ReviewSheetContent(productId: productId, productName: productName),
    ),
  );
}

class _ReviewSheetContent extends StatefulWidget {
  final String productId;
  final String productName;
  const _ReviewSheetContent({required this.productId, required this.productName});

  @override
  State<_ReviewSheetContent> createState() => _ReviewSheetContentState();
}

class _ReviewSheetContentState extends State<_ReviewSheetContent> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().fetchReviews(widget.productId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    final picked = await _picker.pickMultiImage(maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
    if (picked.isNotEmpty) setState(() => _images.addAll(picked.take(5 - _images.length)));
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please rate the product'), backgroundColor: ColorConstant.errorColor));
      return;
    }
    final vm = context.read<ReviewViewModel>();
    final ok = await vm.submitReview(
      productId: widget.productId,
      rating: _rating.toInt(),
      comment: _commentController.text.trim(),
      images: _images.map((x) => File(x.path)).toList(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted! It'll be visible once approved."), backgroundColor: ColorConstant.successColor),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.submitError ?? 'Failed to submit review'), backgroundColor: ColorConstant.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCustomerId = AppStorage.getCustomer()?['id']?.toString();
    return Consumer<ReviewViewModel>(
      builder: (context, vm, _) {
        final alreadyReviewed = vm.hasUserReviewed(widget.productId, currentCustomerId);
        final pending = vm.isPendingApproval(widget.productId);

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(color: ColorConstant.whiteColor, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                children: [
                  Center(child: Container(height: 4, width: 40, decoration: BoxDecoration(color: ColorConstant.borderColor, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  TextContext(text: widget.productName, fontSize: 16, fontWeight: FontWeight.w700, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),

                  if (pending || alreadyReviewed) ...[
                    _buildPendingOrDoneBanner(pending),
                    const SizedBox(height: 16),
                  ] else ...[
                    const TextContext(text: 'How would you rate this product?', fontSize: 14.5, fontWeight: FontWeight.w600),
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final starIndex = i + 1;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = starIndex.toDouble()),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                _rating >= starIndex ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 38,
                                color: _rating >= starIndex ? ColorConstant.ratingStarColor : ColorConstant.borderColor,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TextContext(text: 'Write your review', fontSize: 14.5, fontWeight: FontWeight.w600),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: ColorConstant.borderColor)),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        maxLength: 500,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                        decoration: const InputDecoration(
                          hintText: 'Share your experience...',
                          hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: ColorConstant.placeholderColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextContext(text: 'Add Photos', fontSize: 14.5, fontWeight: FontWeight.w600),
                        TextContext(text: '${_images.length}/5', fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.placeholderColor),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 78,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int i = 0; i < _images.length; i++) _buildImageThumb(i),
                          if (_images.length < 5) _buildAddPhotoButton(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: vm.isSubmitting ? 'Submitting...' : 'Submit Review',
                      onTap: vm.isSubmitting ? null : _submit,
                      icon: vm.isSubmitting ? null : Icons.send_rounded,
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Divider(color: ColorConstant.dividerColor),
                  const SizedBox(height: 10),
                  TextContext(text: 'Reviews (${vm.reviewsFor(widget.productId).length})', fontSize: 14.5, fontWeight: FontWeight.w600),
                  const SizedBox(height: 10),

                  if (vm.isLoading)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor)))
                  else if (vm.reviewsFor(widget.productId).isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: TextContext(text: 'No reviews yet. Be the first to review!', fontSize: 13, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                    )
                  else
                    for (final review in vm.reviewsFor(widget.productId)) _buildReviewTile(review),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingOrDoneBanner(bool pending) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (pending ? ColorConstant.orangeColor : ColorConstant.successColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(pending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
              color: pending ? ColorConstant.orangeColor : ColorConstant.successColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextContext(
              text: pending
                  ? "Your review has been submitted and is awaiting approval. It'll appear here once approved."
                  : "You've already reviewed this product.",
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: pending ? ColorConstant.orangeColor : ColorConstant.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumb(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(_images[index].path), height: 70, width: 70, fit: BoxFit.cover),
          ),
          Positioned(
            top: 2, right: 2,
            child: GestureDetector(
              onTap: () => setState(() => _images.removeAt(index)),
              child: Container(
                height: 20, width: 20,
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 70, width: 70,
        decoration: BoxDecoration(color: ColorConstant.whiteColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: ColorConstant.borderColor)),
        alignment: Alignment.center,
        child: const Icon(Icons.add_photo_alternate_rounded, color: ColorConstant.primaryColor, size: 26),
      ),
    );
  }

  Widget _buildReviewTile(review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextContext(text: review.customerName, fontSize: 13, fontWeight: FontWeight.w600),
              const SizedBox(width: 8),
              Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_border_rounded, size: 14, color: ColorConstant.ratingStarColor))),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            TextContext(text: review.comment!, fontSize: 12.5, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
          ],
        ],
      ),
    );
  }
}