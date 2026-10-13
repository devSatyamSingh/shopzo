import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/view/address/add_address_screen.dart';
import '../../localization/language_provider.dart';
import '../../model/address/address_model.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/button_context.dart';
import '../../utils/skelton_box.dart';
import '../../utils/utils.dart';
import '../../viewmodel/address/address_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  int _selectedIndex = 0;
  bool _isLoadingLocation = false;
  AddressModel? _currentLocationAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().fetchAddresses();
    });
  }

  // ---------------- USE CURRENT LOCATION ----------------
  Future<void> _onUseCurrentLocation() async {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    setState(() => _isLoadingLocation = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        if (!mounted) return;
        AppUtils.error(
          context,
          'select_address.could_not_fetch_location'.tr(),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      final place = placemarks.first;

      setState(() {
        _currentLocationAddress = AddressModel(
          id: 'current-location-${DateTime.now().millisecondsSinceEpoch}',
          customerId: '',
          type: 'SHIPPING',
          line1: place.subLocality?.isNotEmpty == true ? place.subLocality! : 'Current Location',
          line2: place.street,
          city: place.locality ?? '',
          state: place.administrativeArea ?? '',
          postalCode: place.postalCode ?? '',
          country: place.country ?? 'India',
          isDefault: false,
          createdAt: DateTime.now().toIso8601String(),
        );
        _selectedIndex = 0;
        _isLoadingLocation = false;
      });

      if (!mounted) return;
      AppUtils.success(
        context,
        'select_address.location_added'.tr(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
      AppUtils.error(
        context,
        'select_address.could_not_detect_location'.tr(),
      );
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppUtils.error(
        context,
        'select_address.turn_on_gps'.tr(),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppUtils.error(
          context,
          'select_address.permission_required'.tr(),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppUtils.error(
        context,
        'select_address.permission_permanently_denied'.tr(),
      );
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  void _onAddNewAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    // AddressViewModel already updates its own list on success —
    // nothing else to do here.
  }

  void _onEdit(AddressModel address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddAddressScreen(editAddress: address)),
    );
  }

  void _onDelete(AddressModel address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'select_address.delete_address'.tr(),
        ),
        content: Text(
          'select_address.delete_confirmation'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: TextContext(
              text: 'select_address.cancel'.tr(),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorConstant.bodyTextColor,
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context.read<AddressViewModel>().deleteAddress(address.id);
              if (!mounted) return;
              if (success) {
                setState(() {
                  if (_selectedIndex > 0) _selectedIndex = 0;
                });
                AppUtils.success(
                  context,
                  'select_address.address_deleted'.tr(),
                );
              } else {
                AppUtils.error(
                  context,
                  context.read<AddressViewModel>().errorMessage ??
                      'select_address.delete_failed'.tr(),
                );
              }
            },
            child: TextContext(
              text: 'select_address.delete'.tr(),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorConstant.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  void _onDeliverHere(List<AddressModel> displayList) {
    if (displayList.isEmpty) return;
    final selectedAddress = displayList[_selectedIndex];
    Navigator.pop(context, selectedAddress);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();


    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: Text(
          'select_address.title'.tr(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<AddressViewModel>(
          builder: (context, viewModel, _) {
            // ---------------- SKELETON ----------------
            if (viewModel.isLoading && viewModel.addresses.isEmpty) {
              return _AddressListSkeleton(size: size);
            }

            // ---------------- ERROR ----------------
            if (viewModel.status == AddressLoadStatus.error && viewModel.addresses.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 46, color: ColorConstant.placeholderColor),
                      SizedBox(height: size.height * 0.015),
                      TextContext(
                        text: viewModel.errorMessage ?? 'select_address.something_went_wrong'.tr(),                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                        color: ColorConstant.labelTextColor,
                      ),
                      SizedBox(height: size.height * 0.02),
                      TextButton(
                        onPressed: () => viewModel.fetchAddresses(forceRefresh: true),
                        child: TextContext(
                          text: 'select_address.retry'.tr(),
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

            // saved addresses + the (unsaved) current-location card, if any
            final displayList = [
              if (_currentLocationAddress != null) _currentLocationAddress!,
              ...viewModel.addresses,
            ];

            if (_selectedIndex >= displayList.length) _selectedIndex = 0;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.02),

                        // ---------------- USE CURRENT LOCATION ----------------
                        GestureDetector(
                          onTap: _isLoadingLocation ? null : _onUseCurrentLocation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _isLoadingLocation
                                  ? ColorConstant.primaryLight.withOpacity(.5)
                                  : ColorConstant.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: ColorConstant.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: _isLoadingLocation
                                      ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Icon(
                                    Icons.my_location_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextContext(
                                        text: _isLoadingLocation
                                            ? 'select_address.detecting_location'.tr()
                                            : 'select_address.use_current_location'.tr(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _isLoadingLocation
                                            ? ColorConstant.placeholderColor
                                            : ColorConstant.primaryColor,
                                      ),
                                      TextContext(
                                        text: _isLoadingLocation
                                            ? 'select_address.detecting_location_subtitle'.tr()
                                            : 'select_address.detect_location_subtitle'.tr(),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w400,
                                        color: _isLoadingLocation
                                            ? ColorConstant.placeholderColor
                                            : ColorConstant.labelTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!_isLoadingLocation)
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: ColorConstant.primaryColor,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.028),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextContext(
                              text: 'select_address.saved_addresses'.tr(),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.headlineTextColor,
                            ),
                            TextContext(
                              text: 'select_address.addresses_count'.tr(
                                args: [
                                  viewModel.addresses.length.toString(),
                                ],
                              ),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: ColorConstant.labelTextColor,
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.015),

                        // ---------------- EMPTY ----------------
                        if (displayList.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
                            child: Center(
                              child: TextContext(
                                text: 'select_address.no_saved_addresses'.tr(),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorConstant.labelTextColor,
                              ),
                            ),
                          ),

                        // ---------------- ADDRESS CARDS ----------------
                        ...List.generate(displayList.length, (index) {
                          final address = displayList[index];
                          final isSelected = index == _selectedIndex;
                          final isUnsavedCurrentLocation =
                              _currentLocationAddress != null && index == 0;

                          return Padding(
                            padding: EdgeInsets.only(bottom: size.height * 0.018),
                            child: _SavedAddressCard(
                              address: address,
                              isSelected: isSelected,
                              showEditDelete: !isUnsavedCurrentLocation,
                              onTap: () => setState(() => _selectedIndex = index),
                              onEdit: () => _onEdit(address),
                              onDelete: () => _onDelete(address),
                            ),
                          );
                        }),

                        // ---------------- ADD NEW ADDRESS ----------------
                        GestureDetector(
                          onTap: _onAddNewAddress,
                          child: _DashedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ColorConstant.primaryColor, width: 1.6),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.add_rounded,
                                      size: 18, color: ColorConstant.primaryColor),
                                ),
                                const SizedBox(width: 10),
                                TextContext(
                                  text: 'select_address.add_new_address'.tr(),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstant.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),
                ),

                // ---------------- BOTTOM BUTTON ----------------
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.015,
                  ),
                  child: CustomButton(
                    text: 'select_address.deliver_here'.tr(),
                    onTap: () => _onDeliverHere(displayList),
                    color: ColorConstant.primaryColor,
                    icon: Icons.keyboard_double_arrow_right_rounded,
                    iconColor: ColorConstant.whiteColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ---------------- SAVED ADDRESS CARD ----------------
class _SavedAddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final bool showEditDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavedAddressCard({
    required this.address,
    required this.isSelected,
    required this.showEditDelete,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  IconData get _typeIcon =>
      address.type == 'BILLING' ? Icons.receipt_long_rounded : Icons.local_shipping_rounded;

  String get _typeLabel => address.type == 'BILLING' ? 'Billing Address' : 'Shipping Address';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- type row: icon + label + DEFAULT badge + radio ----
            Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_typeIcon, size: 16, color: ColorConstant.primaryColor),
                ),
                const SizedBox(width: 10),
                TextContext(
                  text: _typeLabel,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.headlineTextColor,
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorConstant.successColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'select_address.default'.tr(),
                      style: TextStyle(
                        color: ColorConstant.successColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 22,
                  color: isSelected ? ColorConstant.primaryColor : ColorConstant.borderColor,
                ),
              ],
            ),

            SizedBox(height: size.height * 0.012),

            TextContext(
              text: address.fullAddress,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: ColorConstant.labelTextColor,
            ),

            if (showEditDelete) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
                child: Divider(color: ColorConstant.dividerColor, height: 1),
              ),

              // ---- edit / delete row ----
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 15, color: ColorConstant.primaryColor),
                        const SizedBox(width: 5),
                        TextContext(
                          text: 'select_address.edit'.tr(),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: size.width * 0.06),
                  GestureDetector(
                    onTap: onDelete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 15, color: ColorConstant.errorColor),
                        const SizedBox(width: 5),
                        TextContext(
                          text: 'select_address.delete'.tr(),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.errorColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ---------------- SKELETON ----------------
class _AddressListSkeleton extends StatelessWidget {
  final Size size;
  const _AddressListSkeleton({required this.size});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 72, borderRadius: BorderRadius.circular(16)),
          SizedBox(height: size.height * 0.03),
          SkeletonBox(width: 130, height: 16, borderRadius: BorderRadius.circular(4)),
          SizedBox(height: size.height * 0.015),
          for (int i = 0; i < 2; i++) ...[
            SkeletonBox(width: double.infinity, height: 140, borderRadius: BorderRadius.circular(16)),
            SizedBox(height: size.height * 0.018),
          ],
        ],
      ),
    );
  }
}

/// ---------------- DASHED BORDER BOX ----------------
class _DashedBox extends StatelessWidget {
  final Widget child;
  const _DashedBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: ColorConstant.primaryColor),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dashLength = 6.0;
      const gapLength = 5.0;
      while (distance < metric.length) {
        dashPath.addPath(metric.extractPath(distance, distance + dashLength), Offset.zero);
        distance += dashLength + gapLength;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}