import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../model/order/order_model.dart';
import '../../model/order/return_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../viewmodel/orderview/create_return_viewmodel.dart';

void showReturnFormBottomSheet(BuildContext context, {required OrderItemModel item}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => CreateReturnViewModel(),
      child: _ReturnFormSheet(item: item),
    ),
  );
}

class _ReturnFormSheet extends StatefulWidget {
  final OrderItemModel item;
  const _ReturnFormSheet({required this.item});

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

  Future<void> _pickImage(CreateReturnViewModel vm) async {
    // Backend ek "images" field leta hai (multiple bhej sakte hain) — abhi max 3 rakh rahe hain UI me
    if (vm.images.length >= 3) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) vm.addImage(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
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
                    Container(height: 4, width: 40, decoration: BoxDecoration(color: ColorConstant.borderColor, borderRadius: BorderRadius.circular(10))),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---- product header ----
                            Row(
                              children: [
                                Container(
                                  height: 54, width: 54,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: ColorConstant.fieldFillColor),
                                  child: item.displayImage != null
                                      ? Image.network(item.displayImage!, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: ColorConstant.placeholderColor))
                                      : const Icon(Icons.image_outlined, color: ColorConstant.placeholderColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextContext(text: item.displayName, fontSize: 14.5, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 3),
                                      TextContext(text: "Qty ordered: ${item.quantity}", fontSize: 12, fontWeight: FontWeight.w400, color: ColorConstant.labelTextColor),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ---- Return / Exchange toggle ----
                            const TextContext(text: "What do you want to do?", fontSize: 13.5, fontWeight: FontWeight.w600),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _TypePill(
                                    label: "Return",
                                    icon: Icons.keyboard_return_rounded,
                                    isSelected: vm.requestType == ReturnRequestType.returnOnly,
                                    onTap: () => vm.setRequestType(ReturnRequestType.returnOnly,
                                        productId: item.productId, currentVariantId: item.variantId),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _TypePill(
                                    label: "Exchange",
                                    icon: Icons.swap_horiz_rounded,
                                    isSelected: vm.requestType == ReturnRequestType.exchange,
                                    onTap: () => vm.setRequestType(ReturnRequestType.exchange,
                                        productId: item.productId, currentVariantId: item.variantId),
                                  ),
                                ),
                              ],
                            ),

                            // ---- Exchange variant dropdown (sirf Exchange select hone par) ----
                            if (vm.requestType == ReturnRequestType.exchange) ...[
                              const SizedBox(height: 18),
                              const TextContext(text: "Select new variant", fontSize: 13.5, fontWeight: FontWeight.w600),
                              const SizedBox(height: 8),
                              if (vm.isLoadingVariants)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor)),
                                )
                              else if (vm.exchangeVariants.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: ColorConstant.errorColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, size: 16, color: ColorConstant.errorColor),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextContext(
                                          text: "Is product ka koi doosra variant available nahi hai, isliye Exchange possible nahi hai. Return select karein.",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: ColorConstant.errorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                _buildDropdownContainer(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: vm.selectedExchangeVariantId,
                                      hint: const Text("Choose variant", style: TextStyle(fontFamily: "Poppins", fontSize: 13.5, color: ColorConstant.placeholderColor)),
                                      items: vm.exchangeVariants
                                          .map((v) => DropdownMenuItem(value: v.id, child: Text(v.name, style: const TextStyle(fontFamily: "Poppins", fontSize: 13.5))))
                                          .toList(),
                                      onChanged: (val) => vm.setExchangeVariant(val),
                                    ),
                                  ),
                                ),
                            ],

                            const SizedBox(height: 18),
                            const TextContext(text: "Reason", fontSize: 13.5, fontWeight: FontWeight.w600),
                            const SizedBox(height: 8),
                            _buildDropdownContainer(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: vm.reason,
                                  hint: const Text("Select a reason", style: TextStyle(fontFamily: "Poppins", fontSize: 13.5, color: ColorConstant.placeholderColor)),
                                  items: CreateReturnViewModel.reasonOptions
                                      .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontFamily: "Poppins", fontSize: 13.5))))
                                      .toList(),
                                  onChanged: vm.setReason,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),
                            const TextContext(text: "Tell us more", fontSize: 13.5, fontWeight: FontWeight.w600),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: ColorConstant.borderColor)),
                              child: TextFormField(
                                controller: _noteController,
                                maxLines: 4,
                                onChanged: vm.setReasonNote,
                                style: const TextStyle(fontFamily: "Poppins", fontSize: 13.5),
                                decoration: const InputDecoration(
                                  hintText: "e.g. Size chhota nikla, ek size upar chahiye...",
                                  hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13, color: ColorConstant.placeholderColor),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),
                            const TextContext(text: "Quantity", fontSize: 13.5, fontWeight: FontWeight.w600),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _qtyBtn(Icons.remove_rounded, () => vm.setQuantity(vm.quantity - 1, max: item.quantity)),
                                Container(
                                  width: 46,
                                  alignment: Alignment.center,
                                  child: TextContext(text: "${vm.quantity}", fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                _qtyBtn(Icons.add_rounded, () => vm.setQuantity(vm.quantity + 1, max: item.quantity)),
                              ],
                            ),

                            const SizedBox(height: 18),
                            const TextContext(text: "Add photos (optional)", fontSize: 13.5, fontWeight: FontWeight.w600),
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
                                        height: 72, width: 72,
                                        decoration: BoxDecoration(
                                          color: ColorConstant.fieldFillColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: ColorConstant.borderColor, style: BorderStyle.solid),
                                        ),
                                        child: const Icon(Icons.add_a_photo_outlined, color: ColorConstant.placeholderColor, size: 22),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            if (vm.status == CreateReturnStatus.error && vm.errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: ColorConstant.errorColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: ColorConstant.errorColor, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: TextContext(text: vm.errorMessage!, fontSize: 12, color: ColorConstant.errorColor)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: CustomButton(
                        text: vm.isSubmitting
                            ? "Submitting..."
                            : (vm.requestType == ReturnRequestType.exchange ? "Submit Exchange Request" : "Submit Return Request"),
                        width: double.infinity,
                        height: 52,
                        onTap: (vm.isSubmitting || !vm.canSubmit)
                            ? null
                            : () async {
                          final ok = await vm.submit(orderItemId: item.id);
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.of(context).pop();
                            _showResultSnackBar(
                              context,
                              success: true,
                              message: vm.requestType == ReturnRequestType.exchange
                                  ? "Exchange request submitted (Status: ${vm.createdReturn?.statusRaw ?? 'REQUESTED'})"
                                  : "Return request submitted (Status: ${vm.createdReturn?.statusRaw ?? 'REQUESTED'})",
                            );
                          }
                        },
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
      decoration: BoxDecoration(color: ColorConstant.fieldFillColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: ColorConstant.borderColor)),
      child: child,
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 36, width: 36,
        decoration: BoxDecoration(color: ColorConstant.primaryLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: ColorConstant.primaryColor),
      ),
    );
  }

  Widget _imageThumb(File file, {required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          height: 72, width: 72,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        Positioned(
          top: -4, right: -4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              height: 20, width: 20,
              decoration: const BoxDecoration(color: ColorConstant.errorColor, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showResultSnackBar(BuildContext context, {required bool success, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? ColorConstant.successColor : ColorConstant.errorColor,
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypePill({required this.label, required this.icon, required this.isSelected, required this.onTap});

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
          border: Border.all(color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: isSelected ? Colors.white : ColorConstant.labelTextColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontFamily: "Poppins", fontSize: 13.5, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : ColorConstant.headlineTextColor)),
          ],
        ),
      ),
    );
  }
}