import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../utils/app_storage.dart';
import '../../utils/utils.dart';
import '../../viewmodel/review/review_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';

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
  String? _localError;

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
      setState(() {
        _localError = 'reviews.rating_required'.tr();
      });
      return;
    }
    setState(() => _localError = null);

    final vm = context.read<ReviewViewModel>();
    final ok = await vm.submitReview(
      productId: widget.productId,
      rating: _rating.toInt(),
      comment: _commentController.text.trim(),
      images: _images.map((x) => File(x.path)).toList(),
    );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      AppUtils.success(
        null,
        'reviews.submitted_message'.tr(),
        title: 'reviews.submitted_title'.tr(),
      );
    } else {
      setState(() => _localError = vm.submitError ?? 'reviews.failed'.tr());
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
                    TextContext(text: 'reviews.rate_product'.tr(), fontSize: 14.5, fontWeight: FontWeight.w600),
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
                    TextContext(text: 'reviews.write_review'.tr(), fontSize: 14.5, fontWeight: FontWeight.w600),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: ColorConstant.borderColor)),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        maxLength: 500,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                        decoration:  InputDecoration(
                          hintText: 'reviews.share_experience'.tr(),
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
                        TextContext(text: 'reviews.add_photos'.tr(), fontSize: 14.5, fontWeight: FontWeight.w600),
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
                    if (_localError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: ColorConstant.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorConstant.errorColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: ColorConstant.errorColor, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextContext(
                                text: _localError!,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    CustomButton(
                      text: vm.isSubmitting ? 'reviews.submitting'.tr() : 'reviews.submit'.tr(),
                      onTap: vm.isSubmitting ? null : _submit,
                      icon: vm.isSubmitting ? null : Icons.send_rounded,
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Divider(color: ColorConstant.dividerColor),
                  const SizedBox(height: 10),
                  TextContext(
                    text: 'reviews.reviews'.tr(args: [vm.reviewsFor(widget.productId).length.toString()]),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),

                  if (vm.isLoading)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor)))
                  else if (vm.reviewsFor(widget.productId).isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: TextContext(
                        text: 'reviews.no_reviews'.tr(),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.labelTextColor,
                      ),
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
              text: pending ? 'reviews.pending_message'.tr() : 'reviews.already_reviewed'.tr(),
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
    final List<String> images = (review.images as List?)?.cast<String>() ?? [];

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
          if (images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () => _openFullScreenGallery(context, images, i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        images[i],
                        height: 64,
                        width: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 64,
                          width: 64,
                          color: ColorConstant.fieldFillColor,
                          child: const Icon(Icons.image_not_supported_outlined, size: 18, color: ColorConstant.placeholderColor),
                        ),
                        loadingBuilder: (context, child, progress) => progress == null
                            ? child
                            : Container(
                          height: 64,
                          width: 64,
                          color: ColorConstant.fieldFillColor,
                          alignment: Alignment.center,
                          child: const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openFullScreenGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenImageViewer({required this.images, required this.initialIndex});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 48),
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600, fontFamily: "Poppins"),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}