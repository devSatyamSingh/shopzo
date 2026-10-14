import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../model/order/order_model.dart';
import '../../model/order/return_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';
import '../../viewmodel/orderview/create_return_viewmodel.dart';

void showReturnFormBottomSheet(
    BuildContext context, {
      required OrderItemModel item,
      VoidCallback? onSuccess,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => CreateReturnViewModel(),
      child: _ReturnFormSheet(item: item, onSuccess: onSuccess),
    ),
  );
}

class _ReturnFormSheet extends StatefulWidget {
  final OrderItemModel item;
  final VoidCallback? onSuccess;
  const _ReturnFormSheet({required this.item, this.onSuccess});

  @override
  State<_ReturnFormSheet> createState() => _ReturnFormSheetState();
}

class _ReturnFormSheetState extends State<_ReturnFormSheet> {
  final _noteController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Backend ko hamesha English value jati hai (reasonOptions),
  /// yahan sirf screen par dikhne wala label translate hota hai.
  String _reasonLabel(String r) {
    switch (r) {
      case 'Size issue':
        return 'return_form.reason_size_issue'.tr();
      case 'Damaged product':
        return 'return_form.reason_damaged'.tr();
      case 'Wrong item delivered':
        return 'return_form.reason_wrong_item'.tr();
      case 'Quality not as expected':
        return 'return_form.reason_quality'.tr();
      case 'Item no longer needed':
        return 'return_form.reason_not_needed'.tr();
      case 'Others':
        return 'return_form.reason_others'.tr();
      default:
        return r;
    }
  }

  Future<void> _pickImage(CreateReturnViewModel vm) async {
    // Backend max 3 images leta hai
    if (vm.images.length >= 3) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) vm.addImage(File(picked.path));
  }

  Future<void> _openAddUpi(CreateReturnViewModel vm) async {
    final added = await Navigator.pushNamed(context, RouteName.addPaymentMethod);
    if (added == true && mounted) {
      await vm.fetchPayoutMethods(force: true);
      if (vm.payoutMethods.isNotEmpty && vm.selectedPayoutMethodId == null) {
        vm.setPayoutMethod(vm.payoutMethods.last.id); // naya add hua UPI
      }
    }
  }

  Future<void> _onSubmit(CreateReturnViewModel vm, OrderItemModel item) async {
    AppUtils.hideKeyboard(context);
    final ok = await vm.submit(orderItemId: item.id, productId: item.productId);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
      AppUtils.success(
        context,
        vm.createdReturn?.statusRaw != null
            ? 'return_form.submitted_status'
            .tr(namedArgs: {'status': vm.createdReturn!.statusRaw})
            : 'return_form.submitted'.tr(),
      );
    } else {
      AppUtils.error(context, vm.errorMessage ?? 'return_form.something_wrong'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final int remainingQty = (item.quantity - item.returnedQty) < 1
        ? 1
        : (item.quantity - item.returnedQty);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: ColorConstant.whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Consumer<CreateReturnViewModel>(
              builder: (context, vm, _) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: ColorConstant.borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---------------- PRODUCT HEADER ----------------
                            Row(
                              children: [
                                Container(
                                  height: 54,
                                  width: 54,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: ColorConstant.fieldFillColor,
                                  ),
                                  child: item.displayImage != null
                                      ? Image.network(
                                    item.displayImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: ColorConstant.placeholderColor,
                                    ),
                                  )
                                      : const Icon(
                                    Icons.image_outlined,
                                    color: ColorConstant.placeholderColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextContext(
                                        text: item.displayName,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      TextContext(
                                        text: 'return_form.qty_available'
                                            .tr(namedArgs: {'qty': '$remainingQty'}),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: ColorConstant.labelTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ---------------- RETURN / EXCHANGE ----------------
                            TextContext(
                              text: 'return_form.what_to_do'.tr(),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _TypePill(
                                    label: 'return_form.return'.tr(),
                                    icon: Icons.keyboard_return_rounded,
                                    isSelected: vm.requestType == ReturnRequestType.returnOnly,
                                    onTap: () => vm.setRequestType(
                                      ReturnRequestType.returnOnly,
                                      productId: item.productId,
                                      currentVariantId: item.variantId,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _TypePill(
                                    label: 'return_form.exchange'.tr(),
                                    icon: Icons.swap_horiz_rounded,
                                    isSelected: vm.requestType == ReturnRequestType.exchange,
                                    onTap: () => vm.setRequestType(
                                      ReturnRequestType.exchange,
                                      productId: item.productId,
                                      currentVariantId: item.variantId,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ---------------- EXCHANGE VARIANT ----------------
                            // Sirf tab dikhta hai jab product ke dusre variants hon.
                            // Variant-less product me sirf productId jata hai.
                            if (vm.requestType == ReturnRequestType.exchange) ...[
                              if (vm.isLoadingVariants) ...[
                                const SizedBox(height: 18),
                                const _Loader(),
                              ] else if (vm.exchangeVariants.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                TextContext(
                                  text: 'return_form.select_new_variant'.tr(),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 8),
                                _buildDropdownContainer(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: vm.selectedExchangeVariantId,
                                      hint: Text(
                                        'return_form.choose_variant'.tr(),
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 13.5,
                                          color: ColorConstant.placeholderColor,
                                        ),
                                      ),
                                      items: vm.exchangeVariants
                                          .map((v) => DropdownMenuItem(
                                        value: v.id,
                                        child: Text(
                                          v.name,
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ))
                                          .toList(),
                                      onChanged: (val) => vm.setExchangeVariant(val),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 12),
                                _InfoNote(text: 'return_form.no_variants_note'.tr()),
                              ],
                            ],

                            // ---------------- REASON ----------------
                            const SizedBox(height: 18),
                            TextContext(
                              text: 'return_form.reason'.tr(),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            _buildDropdownContainer(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: vm.reason,
                                  hint: Text(
                                    'return_form.select_reason'.tr(),
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 13.5,
                                      color: ColorConstant.placeholderColor,
                                    ),
                                  ),
                                  items: CreateReturnViewModel.reasonOptions
                                      .map((r) => DropdownMenuItem(
                                    value: r, // English value -> backend
                                    child: Text(
                                      _reasonLabel(r), // translated label
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: vm.setReason,
                                ),
                              ),
                            ),

                            // ---------------- NOTE (optional) ----------------
                            const SizedBox(height: 18),
                            TextContext(
                              text: 'return_form.tell_us_more'.tr(),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: ColorConstant.fieldFillColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: ColorConstant.borderColor),
                              ),
                              child: TextFormField(
                                controller: _noteController,
                                maxLines: 4,
                                onChanged: vm.setReasonNote,
                                style: const TextStyle(fontFamily: "Poppins", fontSize: 13.5),
                                decoration: InputDecoration(
                                  hintText: 'return_form.note_hint'.tr(),
                                  hintStyle: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 13,
                                    color: ColorConstant.placeholderColor,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                              ),
                            ),

                            // ---------------- QUANTITY ----------------
                            const SizedBox(height: 18),
                            TextContext(
                              text: 'return_form.quantity'.tr(),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _qtyBtn(
                                  Icons.remove_rounded,
                                      () => vm.setQuantity(vm.quantity - 1, max: remainingQty),
                                ),
                                Container(
                                  width: 46,
                                  alignment: Alignment.center,
                                  child: TextContext(
                                    text: "${vm.quantity}",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _qtyBtn(
                                  Icons.add_rounded,
                                      () => vm.setQuantity(vm.quantity + 1, max: remainingQty),
                                ),
                              ],
                            ),

                            // ---------------- REFUND TO ----------------
                            const SizedBox(height: 18),
                            TextContext(
                              text: 'return_form.refund_to'.tr(),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _TypePill(
                                    label: 'return_form.wallet'.tr(),
                                    icon: Icons.account_balance_wallet_outlined,
                                    isSelected: vm.refundTo == ReturnRefundTo.wallet,
                                    onTap: () => vm.setRefundTo(ReturnRefundTo.wallet),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _TypePill(
                                    label: 'return_form.upi'.tr(),
                                    icon: Icons.qr_code_2_rounded,
                                    isSelected: vm.refundTo == ReturnRefundTo.upi,
                                    onTap: () => vm.setRefundTo(ReturnRefundTo.upi),
                                  ),
                                ),
                              ],
                            ),

                            // ---- Wallet: sirf info ----
                            if (vm.refundTo == ReturnRefundTo.wallet) ...[
                              const SizedBox(height: 10),
                              _InfoNote(text: 'return_form.wallet_note'.tr()),
                            ],

                            // ---- UPI: list / add ----
                            if (vm.refundTo == ReturnRefundTo.upi) ...[
                              const SizedBox(height: 12),
                              if (vm.isLoadingPayouts)
                                const _Loader()
                              else if (vm.payoutMethods.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ColorConstant.fieldFillColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: ColorConstant.borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextContext(
                                          text: 'return_form.no_upi_note'.tr(),
                                          fontSize: 12.5,
                                          color: ColorConstant.labelTextColor,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _openAddUpi(vm),
                                        child: Text('return_form.add_upi_id'.tr()),
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
                                  _buildDropdownContainer(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: vm.selectedPayoutMethodId,
                                        hint: Text(
                                          'return_form.select_upi'.tr(),
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 13.5,
                                            color: ColorConstant.placeholderColor,
                                          ),
                                        ),
                                        items: vm.payoutMethods
                                            .map((m) => DropdownMenuItem(
                                          value: m.id,
                                          child: Text(
                                            m.displayName,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ))
                                            .toList(),
                                        onChanged: vm.setPayoutMethod,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: TextButton(
                                      onPressed: () => _openAddUpi(vm),
                                      child: Text('return_form.add_new_upi'.tr()),
                                    ),
                                  ),
                                ],
                            ],

                            // ---------------- PHOTOS ----------------
                            const SizedBox(height: 14),
                            TextContext(
                              text: 'return_form.add_photos'.tr(),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 72,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (final img in vm.images) ...[
                                    _imageThumb(img, onRemove: () => vm.removeImage(img)),
                                    const SizedBox(width: 10),
                                  ],
                                  if (vm.images.length < 3)
                                    InkWell(
                                      onTap: () => _pickImage(vm),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 72,
                                        width: 72,
                                        decoration: BoxDecoration(
                                          color: ColorConstant.fieldFillColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: ColorConstant.borderColor),
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_outlined,
                                          color: ColorConstant.placeholderColor,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // ---------------- ERROR ----------------
                            if (vm.status == CreateReturnStatus.error &&
                                vm.errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ColorConstant.errorColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: ColorConstant.errorColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextContext(
                                        text: vm.errorMessage!,
                                        fontSize: 12,
                                        color: ColorConstant.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ---------------- SUBMIT ----------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: CustomButton(
                        text: vm.isSubmitting
                            ? 'return_form.submitting'.tr()
                            : (vm.requestType == ReturnRequestType.exchange
                            ? 'return_form.submit_exchange'.tr()
                            : 'return_form.submit_return'.tr()),
                        width: double.infinity,
                        height: 52,
                        onTap: (vm.isSubmitting || !vm.canSubmit)
                            ? null
                            : () => _onSubmit(vm, item),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConstant.borderColor),
      ),
      child: child,
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: ColorConstant.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: ColorConstant.primaryColor),
      ),
    );
  }

  Widget _imageThumb(File file, {required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 72,
          width: 72,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        PositionedDirectional(
          top: -4,
          end: -4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                color: ColorConstant.errorColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- SMALL WIDGETS ----------------
class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: ColorConstant.primaryColor,
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstant.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: ColorConstant.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextContext(
              text: text,
              fontSize: 12,
              height: 1.4,
              color: ColorConstant.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? ColorConstant.primaryColor : ColorConstant.fieldFillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 17,
                color: isSelected ? Colors.white : ColorConstant.labelTextColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ColorConstant.headlineTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}