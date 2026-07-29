import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../model/address_model.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../res/textfiled_context.dart';
import '../../utils/utils.dart';
import '../../viewmodel/address/address_viewmodel.dart';

/// Shopzo — Add / Edit Address screen.
/// Pass `editAddress` to open in edit mode (prefilled, PUT on save).
/// Leave it null for add mode (POST on save).
///
/// Requires: google_maps_flutter, geolocator, geocoding packages +
/// a valid Maps API key authorized for this app's package + SHA-1
/// (Android) / bundle id (iOS), plus location permissions declared
/// in AndroidManifest.xml / Info.plist (see bottom of file for both).
class AddAddressScreen extends StatefulWidget {
  final AddressModel? editAddress;

  const AddAddressScreen({super.key, this.editAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  GoogleMapController? _mapController;

  // fallback location used only until real GPS location is found
  static const LatLng _fallbackPosition = LatLng(28.6139, 77.2090); // Delhi/NCR

  LatLng _mapCenter = _fallbackPosition;
  bool _locatingUser = true; // true while first GPS fix is being fetched
  bool _resolvingAddress = false; // true while reverse-geocoding is running

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addressController =
  TextEditingController(text: 'Locating you...');
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();

  String _selectedState = 'Uttar Pradesh';
  String _areaChipText = 'Locating you...';
  int _saveAsIndex = 0; // 0 = Home, 1 = Work, 2 = Other — UI label only for now,
  // the API doesn't have a Home/Work/Other field yet (only SHIPPING/BILLING).
  bool _setAsDefault = true;
  bool _saving = false;

  bool get _isEditMode => widget.editAddress != null;

  static const List<String> _states = [
    'Uttar Pradesh',
    'Delhi',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'West Bengal',
  ];

  static const List<Map<String, dynamic>> _saveAsOptions = [
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Work', 'icon': Icons.work_rounded},
    {'label': 'Other', 'icon': Icons.label_rounded},
  ];

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      _prefillFromExisting(widget.editAddress!);
    } else {
      _detectCurrentLocation();
    }
  }

  void _prefillFromExisting(AddressModel address) {
    _houseController.text = address.line1;
    _landmarkController.text = address.line2 ?? '';
    _cityController.text = address.city;
    _pincodeController.text = address.postalCode;
    if (_states.contains(address.state)) {
      _selectedState = address.state;
    }
    _setAsDefault = address.isDefault;
    _addressController.text = address.fullAddress;
    _areaChipText = address.fullAddress;
    _locatingUser = false;
  }

  // ============================================================
  // LOCATION
  // ============================================================

  /// Runs once on screen open (add mode only): checks permission, grabs
  /// a GPS fix, moves the map there, and reverse-geocodes it into an
  /// address.
  Future<void> _detectCurrentLocation() async {
    setState(() => _locatingUser = true);

    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      setState(() {
        _locatingUser = false;
        _areaChipText = 'Location permission denied';
        _addressController.text = 'Search or move the map to set your address';
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final target = LatLng(position.latitude, position.longitude);

      setState(() => _mapCenter = target);

      // camera might not be ready yet if map is still initializing —
      // guard with null check, onMapCreated also re-checks _mapCenter
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));

      await _reverseGeocode(target);
    } catch (e) {
      AppUtils.error(context, 'Could not detect your location. Please search manually.');
    } finally {
      if (mounted) setState(() => _locatingUser = false);
    }
  }

  /// Handles the full permission flow: service enabled? permission
  /// granted? asks if denied; sends to Settings if permanently denied.
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

  /// Converts a LatLng into a readable address and fills in the form.
  Future<void> _reverseGeocode(LatLng target) async {
    setState(() => _resolvingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(target.latitude, target.longitude);
      if (placemarks.isEmpty) return;

      final place = placemarks.first;
      final line = [
        if (place.subLocality?.isNotEmpty == true) place.subLocality,
        if (place.locality?.isNotEmpty == true) place.locality,
        if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea,
        if (place.postalCode?.isNotEmpty == true) place.postalCode,
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      if (!mounted) return;
      setState(() {
        _addressController.text = line.isNotEmpty ? line : 'Unknown location';
        _areaChipText = line.isNotEmpty ? line : 'Unknown location';
        _cityController.text = place.locality ?? _cityController.text;
        _pincodeController.text = place.postalCode ?? _pincodeController.text;
        if (place.administrativeArea != null &&
            _states.contains(place.administrativeArea)) {
          _selectedState = place.administrativeArea!;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _addressController.text = 'Could not fetch address for this location';
        _areaChipText = 'Could not fetch address';
      });
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // if GPS already resolved before the map finished initializing,
    // snap the camera there immediately
    if (_mapCenter != _fallbackPosition) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(_mapCenter, 16));
    }
  }

  void _onCameraMove(CameraPosition position) {
    // just track the latest center; heavy work happens on idle
    _mapCenter = position.target;
  }

  void _onCameraIdle() {
    if (!_isEditMode) _reverseGeocode(_mapCenter);
  }

  void _onUseMyLocation() {
    _detectCurrentLocation();
  }

  // ============================================================
  // SAVE (create or update, depending on mode)
  // ============================================================

  Future<void> _onSaveAddress() async {
    if (_houseController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty) {
      AppUtils.error(context, 'Please fill all required fields.');
      return;
    }

    final viewModel = context.read<AddressViewModel>();

    final request = AddressRequestModel(
      line1: _houseController.text.trim(),
      line2: _landmarkController.text.trim().isNotEmpty
          ? _landmarkController.text.trim()
          : (_apartmentController.text.trim().isNotEmpty
          ? _apartmentController.text.trim()
          : null),
      city: _cityController.text.trim(),
      state: _selectedState,
      postalCode: _pincodeController.text.trim(),
      type: 'SHIPPING',
      isDefault: _setAsDefault,
    );

    setState(() => _saving = true);

    final success = _isEditMode
        ? await viewModel.updateAddress(widget.editAddress!.id, request)
        : await viewModel.addAddress(request);

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      AppUtils.success(context, _isEditMode ? 'Address updated' : 'Address saved');
      Navigator.pop(context, true);
    } else {
      AppUtils.error(
        context,
        viewModel.errorMessage ?? 'Failed to save address. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addressController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mapHeight = size.height * 0.34;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: Column(
        children: [
          // ---------------- MAP AREA ----------------
          SizedBox(
            height: mapHeight,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter,
                    zoom: 15.5,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),

                // ---- fixed center pin (map pans underneath it) ----
                IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0, -0.15),
                    child: Icon(Icons.location_on_rounded,
                        size: 38, color: ColorConstant.primaryColor),
                  ),
                ),

                // ---- initial GPS-locating overlay (add mode only) ----
                if (_locatingUser)
                  Container(
                    color: ColorConstant.blackColor.withOpacity(.15),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: ColorConstant.whiteColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorConstant.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Finding your location...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ColorConstant.headlineTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ---- back button + search bar ----
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.012,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: ColorConstant.whiteColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorConstant.blackColor.withOpacity(.15),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.arrow_back_rounded,
                                    size: 18, color: ColorConstant.headlineTextColor),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: ColorConstant.whiteColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorConstant.blackColor.withOpacity(.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search_rounded,
                                        size: 18, color: ColorConstant.placeholderColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: ColorConstant.headlineTextColor,
                                        ),
                                        decoration: InputDecoration(
                                          isCollapsed: true,
                                          border: InputBorder.none,
                                          hintText: 'Search for area, street name...',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12.5,
                                            color: ColorConstant.placeholderColor,
                                          ),
                                        ),
                                        onSubmitted: (query) async {
                                          if (query.trim().isEmpty) return;
                                          try {
                                            final results = await locationFromAddress(query);
                                            if (results.isEmpty) return;
                                            final loc = results.first;
                                            final target = LatLng(loc.latitude, loc.longitude);
                                            await _mapController?.animateCamera(
                                              CameraUpdate.newLatLngZoom(target, 16),
                                            );
                                          } catch (_) {
                                            if (mounted) {
                                              AppUtils.error(context, 'Location not found.');
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.012),

                        // ---- current area chip ----
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: ColorConstant.whiteColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ColorConstant.blackColor.withOpacity(.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: ColorConstant.primaryColor),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _areaChipText,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstant.headlineTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (_resolvingAddress)
                                SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.6,
                                    color: ColorConstant.primaryColor,
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () => _reverseGeocode(_mapCenter),
                                  child: Icon(Icons.refresh_rounded,
                                      size: 14, color: ColorConstant.labelTextColor),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- my location button ----
                Positioned(
                  right: size.width * 0.04,
                  bottom: size.height * 0.02,
                  child: GestureDetector(
                    onTap: _onUseMyLocation,
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: ColorConstant.whiteColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ColorConstant.blackColor.withOpacity(.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _locatingUser
                          ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorConstant.primaryColor,
                        ),
                      )
                          : Icon(Icons.my_location_rounded,
                          size: 19, color: ColorConstant.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------------- CONFIRM LOCATION FORM ----------------
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorConstant.scaffoldBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.06,
                  size.height * 0.022,
                  size.width * 0.06,
                  size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: EdgeInsets.only(bottom: size.height * 0.018),
                        decoration: BoxDecoration(
                          color: ColorConstant.borderColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    TextContext(
                      text: _isEditMode ? 'Edit Address' : 'Confirm Your Location',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.headlineTextColor,
                    ),

                    SizedBox(height: size.height * 0.016),

                    CustomTextField(
                      controller: _addressController,
                      readOnly: true,
                      prefixIcon: Icon(Icons.location_on_rounded,
                          size: 18, color: ColorConstant.primaryColor),
                    ),

                    SizedBox(height: size.height * 0.02),

                    _FieldLabel(text: 'House/Flat/Block No.'),
                    CustomTextField(
                      controller: _houseController,
                      hintText: 'e.g. Flat 402, Block B',
                    ),

                    SizedBox(height: size.height * 0.016),

                    _FieldLabel(text: 'Apartment/Building Name'),
                    CustomTextField(
                      controller: _apartmentController,
                      hintText: 'e.g. Sunshine Apartments',
                    ),

                    SizedBox(height: size.height * 0.016),

                    _FieldLabel(text: 'Landmark (Optional)'),
                    CustomTextField(
                      controller: _landmarkController,
                      hintText: 'e.g. Near Metro Station',
                    ),

                    SizedBox(height: size.height * 0.016),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'City'),
                              CustomTextField(controller: _cityController),
                            ],
                          ),
                        ),
                        SizedBox(width: size.width * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Pincode'),
                              CustomTextField(
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.016),

                    _FieldLabel(text: 'State'),
                    _StateDropdown(
                      value: _selectedState,
                      items: _states,
                      onChanged: (value) => setState(() => _selectedState = value!),
                    ),

                    SizedBox(height: size.height * 0.02),

                    _FieldLabel(text: 'Save address as'),
                    SizedBox(height: size.height * 0.01),
                    Row(
                      children: List.generate(_saveAsOptions.length, (index) {
                        final selected = index == _saveAsIndex;
                        final option = _saveAsOptions[index];
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index != _saveAsOptions.length - 1 ? size.width * 0.02 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _saveAsIndex = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? ColorConstant.primaryColor
                                      : ColorConstant.whiteColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: selected
                                      ? null
                                      : Border.all(color: ColorConstant.borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      option['icon'] as IconData,
                                      size: 15,
                                      color: selected ? Colors.white : ColorConstant.bodyTextColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      option['label'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : ColorConstant.bodyTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // 👉 receiver name/phone fields kept in the UI, just not
                    // sent to the API yet — backend doesn't accept them on
                    // /addresses currently. Wire these into
                    // AddressRequestModel + AddressModel once it does.
                    _FieldLabel(text: "Receiver's Name"),
                    CustomTextField(
                      controller: _receiverNameController,
                      hintText: 'e.g. John Doe',
                    ),

                    SizedBox(height: size.height * 0.016),

                    _FieldLabel(text: "Receiver's Phone Number"),
                    CustomTextField(
                      controller: _receiverPhoneController,
                      hintText: 'Mobile Number',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      prefixIcon: Icon(Icons.call_rounded,
                          size: 17, color: ColorConstant.placeholderColor),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // ---------------- SET AS DEFAULT ----------------
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextContext(
                                text: 'Set as default address',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.headlineTextColor,
                              ),
                              TextContext(
                                text: 'Use this for all future orders',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: ColorConstant.labelTextColor,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _setAsDefault,
                          onChanged: (value) => setState(() => _setAsDefault = value),
                          activeColor: Colors.white,
                          activeTrackColor: ColorConstant.primaryColor,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: ColorConstant.borderColor,
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.025),

                    CustomButton(
                      text: _isEditMode ? 'Update Address' : 'Save Address',
                      onTap: _onSaveAddress,
                      loading: _saving,
                      color: ColorConstant.primaryColor,
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- FIELD LABEL ----------------
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextContext(
        text: text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ColorConstant.bodyTextColor,
      ),
    );
  }
}

/// ---------------- STATE DROPDOWN ----------------
class _StateDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StateDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorConstant.fieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColorConstant.headlineTextColor),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorConstant.headlineTextColor,
          ),
          items: items
              .map((state) => DropdownMenuItem(value: state, child: Text(state)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/*
============================================================
SETUP CHECKLIST — add these outside this file
============================================================

1) pubspec.yaml
   dependencies:
     google_maps_flutter: ^2.9.0
     geolocator: ^13.0.0
     geocoding: ^3.0.0

2) android/app/src/main/AndroidManifest.xml
   Inside <manifest>, ABOVE <application>:
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
     <uses-permission android:name="android.permission.INTERNET"/>

   Inside <application>:
     <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY"/>

   android/app/build.gradle -> defaultConfig:
     minSdkVersion 20   // (or minSdk = 20 in .kts)

3) ios/Runner/Info.plist — add:
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>Shopzo needs your location to detect your delivery address.</string>

   ios/Runner/AppDelegate.swift — add near the top of application(didFinishLaunchingWithOptions:):
     GMSServices.provideAPIKey("YOUR_API_KEY")

4) Google Cloud Console (console.cloud.google.com/apis/credentials):
   - Enable "Maps SDK for Android" (and "Maps SDK for iOS" if targeting iOS)
   - Enable "Geocoding API" (needed for the geocoding package's reverse/forward lookups)
   - Under your API key's Application restrictions, add your package name
     + SHA-1 fingerprint (get it via `cd android && ./gradlew signingReport`)
   - Wait a few minutes after saving, then fully stop and re-run the app
     (hot reload/restart will NOT pick up native config changes)
============================================================
*/