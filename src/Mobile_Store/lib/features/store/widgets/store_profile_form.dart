import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/dialogs/permission_dialog.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../../../shared/widgets/inputs/app_header.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';

import '../models/operating_hour.dart';
import '../models/store_profile.dart';
import '../screens/map_picker_screen.dart';

import 'store_image_header.dart';
import 'store_payment_section.dart';
import 'operating_hours_picker.dart';
import 'store_basic_info_section.dart';
import 'store_settings_section.dart';

class StoreProfileForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isSubmitting;
  final String buttonText;
  final bool showAppBar;

  const StoreProfileForm({
    super.key,
    this.initialData,
    required this.onSubmit,
    this.isSubmitting = false,
    required this.buttonText,
    this.showAppBar = true,
  });

  @override
  State<StoreProfileForm> createState() => _StoreProfileFormState();
}

class _StoreProfileFormState extends State<StoreProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descController;
  
  late TextEditingController _logoUrlController;
  late TextEditingController _coverUrlController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountNumberController;
  late TextEditingController _bankAccountNameController;
  late TextEditingController _depositThresholdController;

  String _coverUrl = '';
  String _logoUrl = '';

  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;
  bool _isOpen = true;
  List<OperatingHour> _operatingHours = [];
  
  int _depositPercent = 0; 
  final List<int> _depositOptions = [0, 10, 20, 30, 40, 50];
  final Color primaryColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final data = widget.initialData ?? {};
    _nameController = TextEditingController(text: data['name']?.toString() ?? '');
    _phoneController = TextEditingController(text: data['phone']?.toString() ?? '');
    _addressController = TextEditingController(text: data['address']?.toString() ?? '');
    _descController = TextEditingController(text: data['description']?.toString() ?? '');
    
    _logoUrl = data['logoUrl']?.toString() ?? '';
    _coverUrl = data['coverImageUrl']?.toString() ?? '';
    _logoUrlController = TextEditingController(text: _logoUrl);
    _coverUrlController = TextEditingController(text: _coverUrl);

    _bankNameController = TextEditingController(text: data['bankName']?.toString() ?? '');
    _bankAccountNumberController = TextEditingController(text: data['bankAccountNumber']?.toString() ?? '');
    _bankAccountNameController = TextEditingController(text: data['bankAccountName']?.toString() ?? '');
    
    _latitude = double.tryParse(data['latitude']?.toString() ?? '');
    _longitude = double.tryParse(data['longitude']?.toString() ?? '');
    _isOpen = data['isOpen'] ?? false;
    
    _depositPercent = data['depositPercent'] ?? 0;
    if (!_depositOptions.contains(_depositPercent)) {
      _depositPercent = 0;
    }
    final initialThreshold = data['depositThreshold']?.toString() ?? '0';
    _depositThresholdController = TextEditingController(
      text: initialThreshold.endsWith('.0') ? initialThreshold.replaceAll('.0', '') : initialThreshold
    );

    _initOperatingHours(data['operatingHours']);
  }

  void _initOperatingHours(dynamic apiHours) {
    _operatingHours = List.generate(7, (index) => OperatingHour(
      dayOfWeek: index, openTime: "08:30", closeTime: "20:30", isActive: false 
    ));

    if (apiHours != null && apiHours is List) {
      for (var h in apiHours) {
        int dayIndex = h['dayOfWeek'] ?? -1;
        if (dayIndex >= 0 && dayIndex <= 6) {
          _operatingHours[dayIndex].openTime = h['openTime'] ?? "08:30";
          _operatingHours[dayIndex].closeTime = h['closeTime'] ?? "20:30";
          _operatingHours[dayIndex].isActive = h['isActive'] ?? true; 
        }
      }
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    if (color == Colors.red || color == Colors.orange) {
       SnackBarHelper.showError(context, message);
    } else {
       SnackBarHelper.showSuccess(context, message);
    }
  }
  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Dịch vụ vị trí đang tắt. Vui lòng bật GPS.';

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        bool isAgreed = await PermissionDialog.showCustomPrompt(
          context: context, icon: Icons.location_on_rounded, title: 'Định vị cửa hàng',
          description: 'Ứng dụng cần quyền vị trí để tự động lấy tọa độ GPS của bạn.',
          confirmText: 'Bật vị trí',
        );

        if (isAgreed) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) throw 'Từ chối quyền vị trí.';
        } else {
          return; 
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showSettingsAdviceDialog(); 
        return; 
      }
    
      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      String addressText = "";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          List<String> addressParts = [place.street ?? "", place.subAdministrativeArea ?? "", place.administrativeArea ?? ""]..removeWhere((e) => e.isEmpty);
          addressText = addressParts.join(", ");
        }
      } catch (e) {
        debugPrint("Lỗi dịch địa chỉ: $e");
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        if (addressText.isNotEmpty) _addressController.text = addressText;
      });
      _showSnack('Đã lấy vị trí thành công!', Colors.green);
      
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
    } finally {
      if(mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _showSettingsAdviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
        title: Text('Cần quyền vị trí', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
        content: Text('Vui lòng vào Cài đặt và cấp quyền.', style: AppTextStyles.bodyText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Đóng')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); 
            },
            child: const Text('Mở Cài đặt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker() async {
    setState(() => _isGettingLocation = true);

    double? tempLat = _latitude;
    double? tempLng = _longitude;
    final addressText = _addressController.text.trim();

    if (tempLat == null && tempLng == null && addressText.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(addressText);
        if (locations.isNotEmpty) {
          tempLat = locations.first.latitude;
          tempLng = locations.first.longitude;
        }
      } catch (e) {
        try {
          Position pos = await Geolocator.getCurrentPosition();
          tempLat = pos.latitude;
          tempLng = pos.longitude;
        } catch (_) {}
      }
    }

    setState(() => _isGettingLocation = false);

    if (!mounted) return;

    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLat: tempLat,
          initialLng: tempLng,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _isGettingLocation = true;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(result.latitude, result.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          List<String> addressParts = [
            place.street ?? "", place.subLocality ?? "", place.locality ?? "",
            place.subAdministrativeArea ?? "", place.administrativeArea ?? ""
          ]..removeWhere((e) => e.isEmpty);

          final finalAddress = addressParts.toSet().join(", ");

          setState(() => _addressController.text = finalAddress);
          _showSnack('Đã cập nhật tọa độ!', Colors.green);
        } else {
          _showSnack('Đã lưu tọa độ!', Colors.orange);
        }
      } catch (e) {
        _showSnack('Đã lưu tọa độ!', Colors.orange);
      } finally {
        if (mounted) setState(() => _isGettingLocation = false);
      }
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    final activeHours = _operatingHours.where((h) => h.isActive).toList();

    final profileData = StoreProfile(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      description: _descController.text.trim(),
      logoUrl: _logoUrlController.text.trim(),
      coverImageUrl: _coverUrlController.text.trim(),
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
      isOpen: _isOpen,
      depositPercent: _depositPercent, 
      depositThreshold: double.tryParse(_depositThresholdController.text.trim()) ?? 0.0,
      operatingHours: activeHours,
      bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
      bankAccountNumber: _bankAccountNumberController.text.trim().isEmpty ? null : _bankAccountNumberController.text.trim(),
      bankAccountName: _bankAccountNameController.text.trim().isEmpty ? null : _bankAccountNameController.text.trim(),
    );
    
    widget.onSubmit(profileData.toJson()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar ? const AppHeader(title: "Thông tin") : null,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreImageHeader(
                coverUrl: _coverUrl, logoUrl: _logoUrl,
                onCoverUploaded: (newUrl) => setState(() { _coverUrl = newUrl; _coverUrlController.text = newUrl; }),
                onLogoUploaded: (newUrl) => setState(() { _logoUrl = newUrl; _logoUrlController.text = newUrl; }),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoreBasicInfoSection(
                      nameController: _nameController,
                      addressController: _addressController,
                      phoneController: _phoneController,
                      isGettingLocation: _isGettingLocation,
                      latitude: _latitude,
                      longitude: _longitude,
                      onOpenMap: _openMapPicker,
                      onGetGPS: _getCurrentLocation,
                      onAddressChanged: (v) {
                        if (_latitude != null) setState(() { _latitude = null; _longitude = null; });
                      },
                    ),

                    const SizedBox(height: 12),
                    StoreSettingsSection(
                      isOpen: _isOpen,
                      onToggleOpen: (val) => setState(() => _isOpen = val),
                      depositPercent: _depositPercent,
                      depositOptions: _depositOptions,
                      onDepositPercentChanged: (val) { if (val != null) setState(() => _depositPercent = val); },
                      depositThresholdController: _depositThresholdController,
                      descController: _descController,
                      primaryColor: primaryColor,
                    ),
                    
                    const SizedBox(height: 16),
                    OperatingHoursPicker(operatingHours: _operatingHours, primaryColor: primaryColor),
                    const SizedBox(height: 12),
                    const Divider(height: 1, thickness: 1, color: AppColors.surface),
                    const SizedBox(height: 15),

                    StorePaymentSection(
                      bankNameController: _bankNameController,
                      bankAccountNumberController: _bankAccountNumberController,
                      bankAccountNameController: _bankAccountNameController,
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 20),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero, leading: Icon(Icons.link, color: primaryColor),
                        title: Text("Cập nhật Link Ảnh thủ công", style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.w600)),
                        children: [
                          AppTextField(controller: _logoUrlController, icon: Icons.image_outlined, hint: "Link Avatar URL", onChanged: (val) => setState(() => _logoUrl = val)),
                          const SizedBox(height: 12),
                          AppTextField(controller: _coverUrlController, icon: Icons.wallpaper_outlined, hint: "Link Cover URL", onChanged: (val) => setState(() => _coverUrl = val)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    AppPrimaryButton(
                      text: widget.buttonText,
                      isLoading: widget.isSubmitting,
                      onPressed: _submitForm,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose(); _phoneController.dispose(); _addressController.dispose();
    _descController.dispose(); _logoUrlController.dispose(); _coverUrlController.dispose();
    _bankNameController.dispose(); _bankAccountNumberController.dispose(); _bankAccountNameController.dispose();
    _depositThresholdController.dispose();
    super.dispose();
  }
}