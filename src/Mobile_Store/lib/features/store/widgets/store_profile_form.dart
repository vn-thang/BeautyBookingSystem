import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_store/features/store/widgets/store_image_header.dart';
import 'package:mobile_store/shared/widgets/permission_dialog.dart';
import '../models/operating_hour.dart';
import '../models/store_profile.dart';
import 'location_verification.dart';
import 'operating_hours_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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

  String _coverUrl = '';
  String _logoUrl = '';

  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;
  bool _isOpen = true;
  List<OperatingHour> _operatingHours = [];

  final Color primaryColor = const Color(0xFFD84B6B);

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
    
    _latitude = double.tryParse(data['latitude']?.toString() ?? '');
    _longitude = double.tryParse(data['longitude']?.toString() ?? '');
    _isOpen = data['isOpen'] ?? false;
    _initOperatingHours(data['operatingHours']);
  }
void _initOperatingHours(dynamic apiHours) {
    _operatingHours = List.generate(7, (index) => OperatingHour(
      dayOfWeek: index, 
      openTime: "08:30", 
      closeTime: "20:30", 
      isActive: false 
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
          context: context,
          icon: Icons.location_on_rounded,
          title: 'Định vị cửa hàng',
          description: 'Ứng dụng cần quyền vị trí để tự động lấy tọa độ GPS của bạn một cách chính xác nhất.',
          confirmText: 'Bật vị trí',
        );

        if (isAgreed) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw 'Bạn đã từ chối quyền truy cập vị trí.';
          }
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
        title: const Text('Cần quyền vị trí'),
        content: const Text('Bạn đã từ chối quyền vị trí vĩnh viễn trước đó. Để sử dụng tính năng này, vui lòng vào Cài đặt và cấp quyền lại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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

  Future<void> _verifyLocation() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return _showSnack('Vui lòng nhập địa chỉ trước!', Colors.orange);

    setState(() => _isGettingLocation = true);
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
        _showSnack('Đã xác minh vị trí thành công!', Colors.green);
      }
    } catch (e) {
      _showSnack('Không tìm ra tọa độ. Đang lấy GPS...', Colors.blue);
      await _getCurrentLocation();
    } finally {
      if(mounted) setState(() => _isGettingLocation = false);
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
      operatingHours: activeHours,
    );
    
    final dataToSend = profileData.toJson();
    widget.onSubmit(dataToSend); 
  }

  Widget _buildFlatTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPhone = false, bool isRequired = true, Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      onChanged: onChanged,
      validator: isRequired ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54, fontSize: 15),
        prefixIcon: Icon(icon, color: primaryColor),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 1.5)),
        errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar 
        ? AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text("Thông tin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ) 
        : null,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              StoreImageHeader(
                coverUrl: _coverUrl,
                logoUrl: _logoUrl,
                onCoverUploaded: (newUrl) {
                  setState(() {
                    _coverUrl = newUrl;
                    _coverUrlController.text = newUrl; 
                  });
                },
                onLogoUploaded: (newUrl) {
                  setState(() {
                    _logoUrl = newUrl;
                    _logoUrlController.text = newUrl; 
                  });
                },
              ),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thông tin chung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),
                    
                    _buildFlatTextField(controller: _nameController, icon: Icons.store_mall_directory_outlined, hint: "Tên cửa hàng"),
                    
                    _buildFlatTextField(
                      controller: _addressController, 
                      icon: Icons.location_on_outlined, 
                      hint: "Địa chỉ chi tiết",
                      onChanged: (v) {
                        if (_latitude != null) {
                          setState(() {
                            _latitude = null;
                            _longitude = null;
                          });
                        }
                      }
                    ),
                    const SizedBox(height: 16),

                    LocationVerification(
                      isGettingLocation: _isGettingLocation,
                      latitude: _latitude,
                      longitude: _longitude,
                      onVerifyAddress: _verifyLocation,
                      onGetGPS: _getCurrentLocation,
                    ),

                    _buildFlatTextField(controller: _phoneController, icon: Icons.phone_outlined, hint: "Số điện thoại", isPhone: true),
                    
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.meeting_room_outlined, color: primaryColor),
                      title: const Text("Đóng cửa/Mở cửa", style: TextStyle(fontSize: 15, color: Colors.black87)),
                      trailing: Switch(
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.green,
                        value: _isOpen,
                        onChanged: (val) => setState(() => _isOpen = val),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                    OperatingHoursPicker(operatingHours: _operatingHours, primaryColor: primaryColor),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.description_outlined, color: primaryColor),
                        const SizedBox(width: 15),
                        const Text("Giới thiệu cửa hàng", style: TextStyle(fontSize: 15, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Normal", style: TextStyle(color: Colors.black54)),
                                Icon(Icons.arrow_drop_down, color: Colors.black54),
                                Text("Sans Serif", style: TextStyle(color: Colors.black54)),
                                Icon(Icons.arrow_drop_down, color: Colors.black54),
                                Text("12 pt", style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                          TextFormField(
                            controller: _descController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: "Nhập mô tả...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        leading: Icon(Icons.link, color: primaryColor),
                        title: const Text("Cập nhật Link Ảnh thủ công", style: TextStyle(fontSize: 14, color: Colors.black54)),
                        children: [
                          _buildFlatTextField(
                            controller: _logoUrlController, 
                            icon: Icons.image_outlined, 
                            hint: "Link Avatar URL", 
                            isRequired: false,
                            onChanged: (val) {
                              setState(() {
                                _logoUrl = val; 
                              });
                            }
                          ),
                          _buildFlatTextField(
                            controller: _coverUrlController, 
                            icon: Icons.wallpaper_outlined, 
                            hint: "Link Cover URL", 
                            isRequired: false,
                            onChanged: (val) {
                              setState(() {
                                _coverUrl = val; 
                              });
                            }
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: widget.isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: widget.isSubmitting
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(widget.buttonText, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
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
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _logoUrlController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }
}