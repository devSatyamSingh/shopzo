import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shopzo/view/address/add_address_screen.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/button_context.dart';
import '../../routes/route_name.dart';
import '../../utils/utils.dart';

class SavedAddressModel {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String type;
  final String name;
  final String address;
  final String phone;
  final bool isDefault;

  const SavedAddressModel({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.type,
    required this.name,
    required this.address,
    required this.phone,
    this.isDefault = false,
  });
}

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  int _selectedIndex = 0;
  bool _isLoadingLocation = false;
  List<SavedAddressModel> _addresses = [
    SavedAddressModel(
      icon: Icons.home_rounded,
      iconColor: ColorConstant.primaryColor,
      iconBgColor: ColorConstant.primaryLight,
      type: 'Home',
      name: 'Arjun Malhotra',
      address:
      '402, Skyline Residency, 12th Main Road, Indiranagar, Bengaluru, Karnataka - 560038',
      phone: '+91 98765 43210',
      isDefault: true,
    ),
    SavedAddressModel(
      icon: Icons.work_rounded,
      iconColor: ColorConstant.orangeColor,
      iconBgColor: ColorConstant.orangeLight,
      type: 'Work',
      name: 'Arjun Malhotra',
      address: 'Tech Park Towers, Block C, 5th Floor, Whitefield, Bengaluru, Karnataka - 560066',
      phone: '+91 98765 43210',
    ),
  ];

  // ---------------- USE CURRENT LOCATION ----------------
  Future<void> _onUseCurrentLocation() async {
    // Check permissions
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    setState(() => _isLoadingLocation = true);

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Reverse geocode to get address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        AppUtils.error(context, 'Could not fetch address for your location.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      final place = placemarks.first;

      // Build full address
      final addressParts = [
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).toList();

      final fullAddress = addressParts.join(', ');

      // Create new address from current location
      final currentLocationAddress = SavedAddressModel(
        icon: Icons.my_location_rounded,
        iconColor: ColorConstant.primaryColor,
        iconBgColor: ColorConstant.primaryLight,
        type: 'Current Location',
        name: 'My Location',
        address: fullAddress.isNotEmpty ? fullAddress : 'Current Location',
        phone: '',
        isDefault: false,
      );

      // Add to list and select it
      setState(() {
        _addresses.insert(0, currentLocationAddress);
        _selectedIndex = 0;
        _isLoadingLocation = false;
      });

      // Show success message
      AppUtils.success(context, 'Current location added successfully!');

    } catch (e) {
      setState(() => _isLoadingLocation = false);
      AppUtils.error(context, 'Could not detect your location. Please try again.');
    }
  }

  /// Handle location permissions
  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppUtils.error(context, 'Please turn on device location (GPS) to continue.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppUtils.error(context, 'Location permission is required to detect your address.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppUtils.error(
        context,
        'Location permission is permanently denied. Enable it from app settings.',
      );
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  void _onAddNewAddress() {
    Navigator.pushNamed(context, RouteName.addEditAddress);
  }

  void _onEdit(int index) {
    // Navigate to AddAddressScreen in edit mode
  }

  void _onDelete(int index) {
    // Show confirm dialog, then remove from list
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${_addresses[index].type}" address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextContext(
              text: 'Cancel',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorConstant.bodyTextColor,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _addresses.removeAt(index);
                if (_selectedIndex >= _addresses.length) {
                  _selectedIndex = _addresses.length - 1;
                }
              });
              Navigator.pop(context);
            },
            child: TextContext(
              text: 'Delete',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorConstant.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  void _onDeliverHere() {
    final selectedAddress = _addresses[_selectedIndex];
    Navigator.pop(context, selectedAddress);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        title: const Text('Select Address'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
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
                                        ? 'Detecting your location...'
                                        : 'Use Current Location',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _isLoadingLocation
                                        ? ColorConstant.placeholderColor
                                        : ColorConstant.primaryColor,
                                  ),
                                  TextContext(
                                    text: _isLoadingLocation
                                        ? 'Please wait while we find your location'
                                        : 'Detect your location automatically',
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
                          text: 'Saved Addresses',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.headlineTextColor,
                        ),
                        TextContext(
                          text: '${_addresses.length} addresses',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorConstant.labelTextColor,
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.015),

                    // ---------------- ADDRESS CARDS ----------------
                    ...List.generate(_addresses.length, (index) {
                      final address = _addresses[index];
                      final isSelected = index == _selectedIndex;

                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.018),
                        child: _SavedAddressCard(
                          address: address,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedIndex = index),
                          onEdit: () => _onEdit(index),
                          onDelete: () => _onDelete(index),
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
                              text: 'Add New Address',
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
                text: 'Deliver Here',
                onTap: _onDeliverHere,
                color: ColorConstant.primaryColor,
                icon: Icons.keyboard_double_arrow_right_rounded,
                iconColor: ColorConstant.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- SAVED ADDRESS CARD ----------------
class _SavedAddressCard extends StatelessWidget {
  final SavedAddressModel address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavedAddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

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
                    color: address.iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(address.icon, size: 16, color: address.iconColor),
                ),
                const SizedBox(width: 10),
                TextContext(
                  text: address.type,
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
                      'DEFAULT',
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
              text: address.name,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorConstant.headlineTextColor,
            ),
            SizedBox(height: size.height * 0.004),
            TextContext(
              text: address.address,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: ColorConstant.labelTextColor,
            ),
            SizedBox(height: size.height * 0.01),
            if (address.phone.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.call_rounded, size: 14, color: ColorConstant.labelTextColor),
                  const SizedBox(width: 6),
                  TextContext(
                    text: address.phone,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorConstant.labelTextColor,
                  ),
                ],
              ),

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
                        text: 'Edit',
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
                        text: 'Delete',
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
        ),
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