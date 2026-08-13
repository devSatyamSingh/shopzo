import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/product_by_category/category_product_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/skelton_box.dart';
import '../../utils/utils.dart';
import '../../viewmodel/product/product_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';


class CategoryProductListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductListScreen> createState() =>
      _CategoryProductListScreenState();
}

class _CategoryProductListScreenState
    extends State<CategoryProductListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProductViewModel>().fetchProducts(
        categoryId: widget.categoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CategoryProductListView(
      categoryName: widget.categoryName,
    );
  }
}

class _CategoryProductListView extends StatefulWidget {
  final String categoryName;
  const _CategoryProductListView({required this.categoryName});

  @override
  State<_CategoryProductListView> createState() => _CategoryProductListViewState();
}

class _CategoryProductListViewState extends State<_CategoryProductListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final nearBottom =
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300;
    if (nearBottom) {
      context.read<CategoryProductViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onProductTap(CategoryProductModel product) {
    Navigator.pushNamed(
      context,
      RouteName.productDetail,
      arguments: {'productId': product.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.scaffoldBgColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ColorConstant.headlineTextColor),
        title: TextContext(
          text: widget.categoryName,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
      ),
      body: SafeArea(
        child: Consumer<CategoryProductViewModel>(
          builder: (context, viewModel, _) {
            // ---------------- SKELETON (first load) ----------------
            if (viewModel.isLoading && viewModel.products.isEmpty) {
              return _ProductSkeletonGrid(size: size);
            }

            // ---------------- ERROR (first load) ----------------
            if (viewModel.status == ProductLoadStatus.error && viewModel.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 46, color: ColorConstant.placeholderColor),
                      SizedBox(height: size.height * 0.015),
                      TextContext(
                        text: viewModel.errorMessage ??
                            'category_products.failed_load'.tr(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                        color: ColorConstant.labelTextColor,
                      ),
                      SizedBox(height: size.height * 0.02),
                      TextButton(
                        onPressed: () => viewModel.refresh(),
                        child: TextContext(
                          text: 'category_products.retry'.tr(),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ---------------- EMPTY ----------------
            if (viewModel.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 46, color: ColorConstant.placeholderColor),
                      SizedBox(height: size.height * 0.015),
                      TextContext(
                        text: 'category_products.no_products'.tr(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                        color: ColorConstant.labelTextColor,
                      ),
                    ],
                  ),
                ),
              );
            }

            // ---------------- REAL DATA ----------------
            return RefreshIndicator(
              color: ColorConstant.primaryColor,
              onRefresh: () => viewModel.refresh(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(size.width * 0.04),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: size.height * 0.02,
                        crossAxisSpacing: size.width * 0.035,
                        childAspectRatio: 0.66,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final product = viewModel.products[index];
                          return _ProductGridCard(
                            product: product,
                            onTap: () => _onProductTap(product),
                          );
                        },
                        childCount: viewModel.products.length,
                      ),
                    ),
                  ),
                  if (viewModel.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                        child: Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: ColorConstant.primaryColor,
                              strokeWidth: 2.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: size.height * 0.015)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final CategoryProductModel product;
  final VoidCallback onTap;

  const _ProductGridCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ColorConstant.blackColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: ColorConstant.fieldFillColor,
                alignment: Alignment.center,
                child: product.primaryImage != null
                    ? Image.network(
                  product.primaryImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox.shrink();
                  },
                  errorBuilder: (context, error, stack) => Icon(
                    Icons.image_not_supported_outlined,
                    size: 30,
                    color: ColorConstant.placeholderColor,
                  ),
                )
                    : Icon(
                  Icons.image_not_supported_outlined,
                  size: 30,
                  color: ColorConstant.placeholderColor,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextContext(
                      text: product.name,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: ColorConstant.headlineTextColor,
                    ),
                    const SizedBox(height: 4),
                    TextContext(
                      text: AppUtils.formatCurrency(product.price),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ColorConstant.primaryColor,
                    ),
                    if (!product.inStock) ...[
                      const SizedBox(height: 2),
                      TextContext(
                        text: 'category_products.out_of_stock'.tr(),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.errorColor,
                      ),
                    ] else if (product.isLowStock) ...[
                      const SizedBox(height: 2),
                      TextContext(
                        text: 'category_products.only_left'.tr(
                          args: [product.stock.toString()],
                        ),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.orangeColor,
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

class _ProductSkeletonGrid extends StatelessWidget {
  final Size size;
  const _ProductSkeletonGrid({required this.size});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(size.width * 0.04),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: size.height * 0.02,
        crossAxisSpacing: size.width * 0.035,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blackColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                flex: 6,
                child: SkeletonBox(width: double.infinity, height: double.infinity),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(width: 80, height: 12, borderRadius: BorderRadius.circular(4)),
                      const SizedBox(height: 6),
                      SkeletonBox(width: 50, height: 12, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}