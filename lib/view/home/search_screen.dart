import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/search_product_model.dart';
import '../../model/search_suggestion_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/button_context.dart';
import '../../viewmodel/cart/cart_viewmodel.dart';
import '../../viewmodel/search_viewmodel.dart';
import '../product_details/product_details_screen.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _discoverList = [
    "Smartphones",
    "Shoes",
    "T-Shirts",
    "Skincare",
    "Laptops",
    "Watches",
    "Bags",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final vm = context.read<SearchViewModel>();
      vm.clearSearch();
      vm.loadRecentSearches();
      vm.loadRecommended();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final vm = context.read<SearchViewModel>();
    if (!vm.hasSubmittedSearch) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      vm.loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _submit(String query) {
    if (query.trim().isEmpty) return;
    _controller.text = query;
    context.read<SearchViewModel>().submitSearch(query);
    _focusNode.unfocus();
  }

  void _openProduct(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vm = context.watch<SearchViewModel>();

    final bool canPopNow = !vm.hasSubmittedSearch && _controller.text.trim().isEmpty;

    return PopScope(
        canPop: canPopNow,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _controller.clear();
          vm.clearSearch();
          setState(() {});
        },
        child: Scaffold(
          backgroundColor: ColorConstant.whiteColor,
          body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(size),
            Expanded(
              child: Consumer<SearchViewModel>(
                builder: (context, vm, _) {
                  if (vm.hasSubmittedSearch) {
                    return _buildResultsView(size, vm);
                  }
                  if (vm.currentQuery.trim().length >= 2) {
                    return _buildSuggestionsView(size, vm);
                  }
                  return _buildDiscoveryView(size, vm);
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  /// ---------------- SEARCH BAR ----------------
  Widget _buildSearchBar(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .045,
        vertical: size.height * .01,
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_rounded, color: ColorConstant.headlineTextColor),
            ),
          ),
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: ColorConstant.fieldFillColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: ColorConstant.placeholderColor, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(fontSize: 14.5, fontFamily: "Poppins"),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "Search for products...",
                        hintStyle: TextStyle(
                          color: ColorConstant.placeholderColor,
                          fontSize: 14.5,
                          fontFamily: "Poppins",
                        ),
                      ),
                      onChanged: (v) {
                        context.read<SearchViewModel>().onQueryChanged(v);
                        setState(() {}); // clear-icon visibility refresh
                      },
                      onSubmitted: _submit,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    InkWell(
                      onTap: () {
                        _controller.clear();
                        context.read<SearchViewModel>().clearSearch();
                        setState(() {});
                      },
                      child: Icon(Icons.close_rounded, size: 19, color: ColorConstant.placeholderColor),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- DISCOVERY (idle state) ----------------
  Widget _buildDiscoveryView(Size size, SearchViewModel vm) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: size.width * .045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vm.recentSearches.isNotEmpty) ...[
            SizedBox(height: size.height * .012),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextContext(text: "Recent Searches", fontSize: 15, fontWeight: FontWeight.w600),
                InkWell(
                  onTap: vm.clearRecentSearches,
                  child: TextContext(
                    text: "Clear All",
                    fontSize: 12.5,
                    color: ColorConstant.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * .014),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.recentSearches.length,
              separatorBuilder: (_, __) => SizedBox(height: size.height * .014),
              itemBuilder: (context, index) {
                final term = vm.recentSearches[index];
                return InkWell(
                  onTap: () => _submit(term),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, size: 18, color: ColorConstant.placeholderColor),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextContext(text: term, fontSize: 13.5, fontWeight: FontWeight.w500),
                      ),
                      InkWell(
                        onTap: () => vm.removeRecentSearch(index),
                        child: Icon(Icons.close_rounded, size: 16, color: ColorConstant.placeholderColor),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: size.height * .026),
          ],
          TextContext(text: "Discover More", fontSize: 15, fontWeight: FontWeight.w600),
          SizedBox(height: size.height * .016),
          Wrap(
            spacing: size.width * .022,
            runSpacing: size.height * .012,
            children: _discoverList.map((item) {
              return InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _submit(item),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * .04,
                    vertical: size.height * .01,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConstant.whiteColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: ColorConstant.borderColor),
                  ),
                  child: TextContext(
                    text: item,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: ColorConstant.headlineTextColor,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: size.height * .028),
          TextContext(text: "Recommended for You", fontSize: 15, fontWeight: FontWeight.w600),
          SizedBox(height: size.height * .016),
          _buildRecommendedGrid(size, vm),
        ],
      ),
    );
  }

  /// ---------------- RECOMMENDED FOR YOU ----------------
  Widget _buildRecommendedGrid(Size size, SearchViewModel vm) {
    if (vm.isRecommendedLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: size.height * .018,
          crossAxisSpacing: size.width * .034,
          childAspectRatio: .68,
        ),
        itemBuilder: (_, __) => const _ProductSkeletonCard(),
      );
    }

    if (vm.recommendedStatus == RecommendedStatus.error || vm.recommended.isEmpty) {
      // API fail ho jaye ya khaali aaye toh poora section chup-chaap hide —
      // discovery screen ka baaki hissa (recent + discover chips) affect nahi hona chahiye.
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.recommended.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: size.height * .018,
        crossAxisSpacing: size.width * .034,
        childAspectRatio: .68,
      ),
      itemBuilder: (context, index) {
        final product = vm.recommended[index];
        return _SearchProductCard(
          product: product,
          onTap: () => _openProduct(product.id),
        );
      },
    );
  }

  /// ---------------- SUGGESTIONS (typeahead — sirf list, koi direct navigation nahi) ----------------
  Widget _buildSuggestionsView(Size size, SearchViewModel vm) {
    if (vm.isSuggestionLoading) {
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: size.width * .045, vertical: 12),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => const _SuggestionSkeletonRow(),
      );
    }

    if (vm.suggestions.isEmpty) {
      // Kuch nahi mila abhi tak, ya user ne 2 characters se kam type kiya hai
      // (idle state) — is case me kuch bhi mat dikhao taaki UI flicker na ho.
      if (vm.suggestionStatus != SuggestionStatus.loaded) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.only(top: size.height * .06),
        child: Center(
          child: TextContext(
            text: "No matches found",
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: ColorConstant.labelTextColor,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: size.width * .045, vertical: 12),
      itemCount: vm.suggestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = vm.suggestions[index];
        return _SuggestionRow(
          item: item,
          // 🔧 FIX: suggestion tap pe product detail seedha NAHI khulta —
          // sirf uss naam se full search submit hoti hai, results grid
          // dikhta hai, wahan se card tap karke product detail khulta hai.
          onTap: () => _submit(item.name),
        );
      },
    );
  }

  /// ---------------- RESULTS (after submit / Enter / suggestion tap) ----------------
  Widget _buildResultsView(Size size, SearchViewModel vm) {
    return Column(
      children: [
        _buildFilterRow(size, vm),
        Expanded(child: _buildResultsBody(size, vm)),
      ],
    );
  }

  Widget _buildFilterRow(Size size, SearchViewModel vm) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * .045, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorConstant.dividerColor)),
      ),
      child: Row(
        children: [
          _filterChip(
            label: "Sort",
            icon: Icons.swap_vert_rounded,
            active: vm.hasActiveSort,
            onTap: () => _showSortSheet(context, vm),
          ),
          const SizedBox(width: 10),
          _filterChip(
            label: "Price",
            icon: Icons.currency_rupee_rounded,
            active: vm.hasActivePriceFilter,
            onTap: () => _showPriceSheet(context, vm),
          ),
          if (vm.hasActiveSort || vm.hasActivePriceFilter) ...[
            const SizedBox(width: 10),
            InkWell(
              onTap: vm.clearFilters,
              child: TextContext(
                text: "Clear",
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: ColorConstant.orangeColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? ColorConstant.primaryColor.withOpacity(.08) : ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? ColorConstant.primaryColor : ColorConstant.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? ColorConstant.primaryColor : ColorConstant.labelTextColor),
            const SizedBox(width: 5),
            TextContext(
              text: label,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: active ? ColorConstant.primaryColor : ColorConstant.headlineTextColor,
            ),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: active ? ColorConstant.primaryColor : ColorConstant.labelTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBody(Size size, SearchViewModel vm) {
    // ---- LOADING (first page) ----
    if (vm.resultStatus == SearchResultStatus.loading) {
      return _buildResultsSkeletonGrid(size);
    }

    // ---- ERROR ----
    if (vm.resultStatus == SearchResultStatus.error && vm.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40, color: ColorConstant.placeholderColor),
              const SizedBox(height: 10),
              TextContext(
                text: vm.errorMessage ?? "Something went wrong",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ColorConstant.labelTextColor,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: vm.retry,
                child: TextContext(text: "Retry", fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor),
              ),
            ],
          ),
        ),
      );
    }

    // ---- EMPTY ----
    if (vm.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 42, color: ColorConstant.placeholderColor),
              const SizedBox(height: 10),
              TextContext(
                text: 'No products found for "${vm.currentQuery}"',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: ColorConstant.labelTextColor,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // ---- GRID + PAGINATION ----
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        size.width * .045,
        size.height * .016,
        size.width * .045,
        size.height * .02,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: vm.results.length + (vm.isLoadingMore ? 2 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: size.height * .018,
        crossAxisSpacing: size.width * .034,
        childAspectRatio: .68,
      ),
      itemBuilder: (context, index) {
        if (index >= vm.results.length) {
          return const _ProductSkeletonCard();
        }
        final product = vm.results[index];
        return _SearchProductCard(
          product: product,
          onTap: () => _openProduct(product.id),
        );
      },
    );
  }

  Widget _buildResultsSkeletonGrid(Size size) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        size.width * .045,
        size.height * .016,
        size.width * .045,
        size.height * .02,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: size.height * .018,
        crossAxisSpacing: size.width * .034,
        childAspectRatio: .68,
      ),
      itemBuilder: (_, __) => const _ProductSkeletonCard(),
    );
  }

  void _showSortSheet(BuildContext context, SearchViewModel vm) {
    // 🔧 Ye 3 sort values (price_asc/price_desc/newest) placeholder hain —
    // Madhu se confirm kar lena backend exact kya expect karta hai.
    final options = {
      null: "Relevance",
      "price_asc": "Price: Low to High",
      "price_desc": "Price: High to Low",
      "newest": "Newest First",
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConstant.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextContext(text: "Sort By", fontSize: 15, fontWeight: FontWeight.w600),
                ),
                ...options.entries.map((e) {
                  final selected = vm.sortBy == e.key;
                  return InkWell(
                    onTap: () {
                      vm.setSort(e.key);
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            size: 19,
                            color: selected ? ColorConstant.primaryColor : ColorConstant.placeholderColor,
                          ),
                          const SizedBox(width: 12),
                          TextContext(
                            text: e.value,
                            fontSize: 13.5,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected ? ColorConstant.primaryColor : ColorConstant.headlineTextColor,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPriceSheet(BuildContext context, SearchViewModel vm) {
    final minController = TextEditingController(text: vm.minPrice?.toStringAsFixed(0) ?? '');
    final maxController = TextEditingController(text: vm.maxPrice?.toStringAsFixed(0) ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConstant.whiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextContext(text: "Price Range", fontSize: 15, fontWeight: FontWeight.w600),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13.5, fontFamily: "Poppins"),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "Min",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: ColorConstant.borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13.5, fontFamily: "Poppins"),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "Max",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: ColorConstant.borderColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CustomButton(
                  text: "Apply",
                  height: 48,
                  onTap: () {
                    final min = double.tryParse(minController.text.trim());
                    final max = double.tryParse(maxController.text.trim());
                    vm.setPriceRange(min, max);
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ---------------- SUGGESTION ROW ----------------
class _SuggestionRow extends StatelessWidget {
  final SearchSuggestionModel item;
  final VoidCallback onTap;

  const _SuggestionRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (item.image != null && item.image!.isNotEmpty)
                  ? Image.network(
                item.image!,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 40,
                  width: 40,
                  color: ColorConstant.fieldFillColor,
                  child: Icon(Icons.image_outlined, size: 18, color: ColorConstant.placeholderColor),
                ),
              )
                  : Container(
                height: 40,
                width: 40,
                color: ColorConstant.fieldFillColor,
                child: Icon(Icons.search_rounded, size: 18, color: ColorConstant.placeholderColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextContext(
                text: item.name,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextContext(
              text: item.formattedPrice,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstant.labelTextColor,
            ),
            const SizedBox(width: 6),
            // 🔧 FIX: pehle "north_west" (open) icon tha jo suggest karta tha
            // ki tap karne se seedha kuch khulega. Ab "north_east" search-fill
            // arrow icon — matches ke Flipkart/Amazon jaisa "fill & search" hint.
            Icon(Icons.north_east_rounded, size: 15, color: ColorConstant.placeholderColor),
          ],
        ),
      ),
    );
  }
}

class _SuggestionSkeletonRow extends StatefulWidget {
  const _SuggestionSkeletonRow();

  @override
  State<_SuggestionSkeletonRow> createState() => _SuggestionSkeletonRowState();
}

class _SuggestionSkeletonRowState extends State<_SuggestionSkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .4, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Row(
        children: [
          Container(height: 40, width: 40, decoration: BoxDecoration(color: ColorConstant.borderColor, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 12, decoration: BoxDecoration(color: ColorConstant.borderColor, borderRadius: BorderRadius.circular(6)))),
        ],
      ),
    );
  }
}

/// ---------------- SEARCH RESULT PRODUCT CARD ----------------
class _SearchProductCard extends StatelessWidget {
  final SearchProductModel product;
  final VoidCallback onTap;

  const _SearchProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();
    final isAdding = cartVm.isAdding(product.id);
    final inCart = cartVm.isInCart(product.id, variantId: null);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorConstant.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: Container(
                color: ColorConstant.fieldFillColor,
                child: (product.image != null && product.image!.isNotEmpty)
                    ? Image.network(
                  product.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.image_outlined, size: 30, color: ColorConstant.placeholderColor),
                )
                    : Icon(Icons.image_outlined, size: 30, color: ColorConstant.placeholderColor),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextContext(
                          text: product.name,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          height: 1.3,
                        ),
                        if (product.category?.name != null) ...[
                          const SizedBox(height: 2),
                          TextContext(
                            text: product.category!.name,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: ColorConstant.labelTextColor,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextContext(
                            text: product.formattedPrice,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        InkWell(
                          onTap: (!product.inStock || isAdding)
                              ? null
                              : () {
                            if (product.hasVariants) {
                              // Variant select karna zaroori hai — seedha detail
                              // page pe le jao, wahi se add-to-cart hoga.
                              onTap();
                              return;
                            }
                            context.read<CartViewModel>().addToCart(
                              productId: product.id,
                              variantId: null,
                              quantity: 1,
                              context: context,
                            );
                          },
                          child: Container(
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              color: !product.inStock
                                  ? ColorConstant.placeholderColor
                                  : ColorConstant.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: isAdding
                                ? const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.6, color: Colors.white),
                            )
                                : Icon(
                              inCart ? Icons.check_rounded : Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ProductSkeletonCard extends StatefulWidget {
  const _ProductSkeletonCard();

  @override
  State<_ProductSkeletonCard> createState() => _ProductSkeletonCardState();
}

class _ProductSkeletonCardState extends State<_ProductSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar({double? width, double height = 11}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .45, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorConstant.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1.05, child: Container(color: ColorConstant.fieldFillColor)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: double.infinity, height: 11),
                  const SizedBox(height: 6),
                  _bar(width: 60, height: 10),
                  const SizedBox(height: 10),
                  _bar(width: 50, height: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}