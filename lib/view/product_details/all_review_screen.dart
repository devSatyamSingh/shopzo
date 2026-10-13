import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../localization/language_provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../model/product/product_detail_model.dart';


class AllReviewsScreen extends StatefulWidget {
  final ProductDetailModel product;

  const AllReviewsScreen({super.key, required this.product});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  String _timeAgo(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);

    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1
          ? 'product_detail.time_week'.tr(args: [weeks.toString()])
          : 'product_detail.time_weeks'.tr(args: [weeks.toString()]);
    }
    if (diff.inDays >= 1) {
      return diff.inDays == 1
          ? 'product_detail.time_day'.tr(args: [diff.inDays.toString()])
          : 'product_detail.time_days'.tr(args: [diff.inDays.toString()]);
    }
    if (diff.inHours >= 1) {
      return diff.inHours == 1
          ? 'product_detail.time_hour'.tr(args: [diff.inHours.toString()])
          : 'product_detail.time_hours'.tr(args: [diff.inHours.toString()]);
    }
    return 'product_detail.just_now'.tr();
  }

  void _openFullScreenViewer({
    required List<String> images,
    required int initialIndex,
    required String heroPrefix,
    required String reviewerName,
    String? comment,
    required int rating,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenReviewImageViewer(
            images: images,
            initialIndex: initialIndex,
            heroPrefix: heroPrefix,
            reviewerName: reviewerName,
            comment: comment,
            rating: rating,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    final reviews = widget.product.reviews;

    final total = reviews.length;

    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      if (counts.containsKey(r.rating)) counts[r.rating] = counts[r.rating]! + 1;
    }

    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        elevation: 0.5,
        foregroundColor: ColorConstant.headlineTextColor,
        title: TextContext(
          text: total == 1
              ? 'product_detail.review_count'.tr(args: [total.toString()])
              : 'product_detail.reviews_count'.tr(args: [total.toString()]),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? _buildSkeletonList(key: const ValueKey('skeleton'))
            : ListView.separated(
          key: const ValueKey('loaded'),
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length + 1, // +1 for rating summary header
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildRatingSummary(total, counts);
            }
            final reviewIndex = index - 1;
            final review = reviews[reviewIndex];
            return _buildReviewCard(review, reviewIndex);
          },
        ),
      ),
    );
  }

  /// ---------------- SKELETON (shimmer pulse) ----------------
  Widget _buildSkeletonList({required Key key}) {
    return ListView.separated(
      key: key,
      padding: const EdgeInsets.all(16),
      itemCount: 5, // 1 summary skeleton + 4 review skeletons
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) return const _RatingSummarySkeleton();
        return const _ReviewCardSkeleton();
      },
    );
  }

  Widget _buildRatingSummary(int total, Map<int, int> counts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              TextContext(
                text: widget.product.avgRating.toStringAsFixed(1),
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < widget.product.avgRating.round()
                        ? ColorConstant.ratingStarColor
                        : ColorConstant.borderColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextContext(
                text: total == 1
                    ? 'product_detail.review_count'.tr(args: [total.toString()])
                    : 'product_detail.reviews_count'.tr(args: [total.toString()]),
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                color: ColorConstant.labelTextColor,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final fraction = total == 0 ? 0.0 : (counts[star] ?? 0) / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                        child: Text(
                          "$star",
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontFamily: "Poppins",
                            color: ColorConstant.labelTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 6,
                            backgroundColor: ColorConstant.borderColor,
                            valueColor: const AlwaysStoppedAnimation(
                              ColorConstant.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ProductReviewModel review, int reviewIndex) {
    final initial = review.customerName.isNotEmpty
        ? review.customerName[0].toUpperCase()
        : '?';
    final heroPrefix = 'all_review_$reviewIndex';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstant.cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstant.borderColor),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: const BoxDecoration(
                  color: ColorConstant.primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContext(
                      text: review.customerName,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: i < review.rating
                              ? ColorConstant.ratingStarColor
                              : ColorConstant.borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextContext(
                text: _timeAgo(review.createdAt),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: ColorConstant.placeholderColor,
              ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            TextContext(
              text: review.comment!,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: ColorConstant.bodyTextColor,
              height: 1.5,
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _openFullScreenViewer(
                    images: review.images,
                    initialIndex: i,
                    heroPrefix: heroPrefix,
                    reviewerName: review.customerName,
                    comment: review.comment,
                    rating: review.rating,
                  ),
                  child: Hero(
                    tag: '${heroPrefix}_img_$i',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        review.images[i],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: ColorConstant.borderColor,
                          child: Icon(
                            Icons.image_outlined,
                            size: 20,
                            color: ColorConstant.placeholderColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ---------------- RATING SUMMARY SKELETON ----------------
class _RatingSummarySkeleton extends StatefulWidget {
  const _RatingSummarySkeleton();

  @override
  State<_RatingSummarySkeleton> createState() => _RatingSummarySkeletonState();
}

class _RatingSummarySkeletonState extends State<_RatingSummarySkeleton>
    with SingleTickerProviderStateMixin {
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

  Widget _bar({double? width, double height = 10}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorConstant.borderColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConstant.fieldFillColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                _bar(width: 40, height: 28),
                const SizedBox(height: 8),
                _bar(width: 60, height: 10),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: List.generate(
                  5,
                      (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: _bar(width: double.infinity, height: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- REVIEW CARD SKELETON ----------------
class _ReviewCardSkeleton extends StatefulWidget {
  const _ReviewCardSkeleton();

  @override
  State<_ReviewCardSkeleton> createState() => _ReviewCardSkeletonState();
}

class _ReviewCardSkeletonState extends State<_ReviewCardSkeleton>
    with SingleTickerProviderStateMixin {
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

  Widget _bar({double? width, double height = 10}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorConstant.borderColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorConstant.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: ColorConstant.borderColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(width: 90, height: 11),
                      const SizedBox(height: 6),
                      _bar(width: 60, height: 9),
                    ],
                  ),
                ),
                _bar(width: 40, height: 9),
              ],
            ),
            const SizedBox(height: 12),
            _bar(width: double.infinity, height: 10),
            const SizedBox(height: 6),
            _bar(width: 200, height: 10),
          ],
        ),
      ),
    );
  }
}

/// ---------------- FULL SCREEN REVIEW IMAGE VIEWER ----------------
class _FullScreenReviewImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroPrefix;
  final String reviewerName;
  final String? comment;
  final int rating;

  const _FullScreenReviewImageViewer({
    required this.images,
    required this.initialIndex,
    required this.heroPrefix,
    required this.reviewerName,
    this.comment,
    required this.rating,
  });

  @override
  State<_FullScreenReviewImageViewer> createState() =>
      _FullScreenReviewImageViewerState();
}

class _FullScreenReviewImageViewerState
    extends State<_FullScreenReviewImageViewer> {
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
      body: SafeArea(
        child: Stack(
          children: [
            // ---- Zoomable, swipeable images ----
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Hero(
                      tag: '${widget.heroPrefix}_img_$index',
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ---- Close button ----
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),

            // ---- Page counter ----
            if (widget.images.length > 1)
              Positioned(
                top: 14,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${widget.images.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),

            // ---- Reviewer name + comment overlay ----
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.reviewerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            5,
                                (i) => Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: i < widget.rating
                                  ? ColorConstant.ratingStarColor
                                  : Colors.white30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.comment != null &&
                        widget.comment!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.comment!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: "Poppins",
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}