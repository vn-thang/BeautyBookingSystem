// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import '../../auth/services/auth_service.dart';
// import '../../auth/screens/login_screen.dart';
// import '../../../shared/widgets/permission_dialog.dart';
// import 'package:permission_handler/permission_handler.dart';

// class StoreProfileForm extends StatefulWidget {
//   final Map<String, dynamic>? initialData;
//   final Function(Map<String, dynamic>) onSubmit;
//   final bool isSubmitting;
//   final String buttonText;
//   final bool showAppBar;

//   const StoreProfileForm({
//     super.key,
//     this.initialData,
//     required this.onSubmit,
//     this.isSubmitting = false,
//     required this.buttonText,
//     this.showAppBar = true,
//   });

//   @override
//   State<StoreProfileForm> createState() => _StoreProfileFormState();
// }

// class _StoreProfileFormState extends State<StoreProfileForm> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   late TextEditingController _nameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _addressController;
//   late TextEditingController _descController;
//   late TextEditingController _logoUrlController;
//   late TextEditingController _coverUrlController;

//   // State biến
//   double? _latitude;
//   double? _longitude;
//   bool _isGettingLocation = false;
//   bool _isOpen = true;
//   List<Map<String, dynamic>> _operatingHours = [];

//   final Color primaryColor = const Color(0xFFD84B6B);

//   @override
//   void initState() {
//     super.initState();
//     final data = widget.initialData ?? {};

//     _nameController = TextEditingController(text: data['name']?.toString() ?? '');
//     _phoneController = TextEditingController(text: data['phone']?.toString() ?? '');
//     _addressController = TextEditingController(text: data['address']?.toString() ?? '');
//     _descController = TextEditingController(text: data['description']?.toString() ?? '');
//     _logoUrlController = TextEditingController(text: data['logoUrl']?.toString() ?? '');
//     _coverUrlController = TextEditingController(text: data['coverImageUrl']?.toString() ?? '');
    
//     // Tọa độ
//     if (data['latitude'] != null && data['latitude'] != 0) {
//       _latitude = (data['latitude'] is String) ? double.tryParse(data['latitude']) : data['latitude'];
//     }
//     if (data['longitude'] != null && data['longitude'] != 0) {
//       _longitude = (data['longitude'] is String) ? double.tryParse(data['longitude']) : data['longitude'];
//     }

//     _isOpen = data['isOpen'] ?? true;
//     _initOperatingHours(data['operatingHours']);
//   }

//   void _initOperatingHours(dynamic apiHours) {
//     List<Map<String, dynamic>> defaultHours = List.generate(7, (index) => {
//       "dayOfWeek": index,
//       "isActive": false,
//       "openTime": "08:30",
//       "closeTime": "20:30"
//     });

//     if (apiHours == null && widget.initialData == null) {
//       for (var h in defaultHours) { h['isActive'] = true; }
//     } 
//     else if (apiHours != null) {
//       for (var item in (apiHours as List)) {
//         int day = item['dayOfWeek'];
//         int index = defaultHours.indexWhere((h) => h['dayOfWeek'] == day);
//         if (index != -1) {
//           defaultHours[index]['isActive'] = true;
//           defaultHours[index]['openTime'] = item['openTime'];
//           defaultHours[index]['closeTime'] = item['closeTime'];
//         }
//       }
//     }
//     _operatingHours = defaultHours;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _descController.dispose();
//     _logoUrlController.dispose();
//     _coverUrlController.dispose();
//     super.dispose();
//   }

//   Future<void> _getCurrentLocation() async {
//     setState(() => _isGettingLocation = true);
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) throw 'Dịch vụ vị trí đang tắt. Vui lòng bật GPS.';

//       LocationPermission permission = await Geolocator.checkPermission();
      
//       // ==============================================================
//       // KHÚC SỬA MỚI: CHÈN BẢNG GIẢ VÀO ĐÂY
//       // ==============================================================
//       if (permission == LocationPermission.denied) {
//         if (!mounted) return;
//         // 1. Hiện "Bảng Giả"
//         bool isAgreed = await PermissionDialog.showCustomPrompt(
//           context: context,
//           icon: Icons.location_on_rounded,
//           title: 'Định vị cửa hàng',
//           description: 'Ứng dụng cần quyền vị trí để tự động lấy tọa độ GPS của bạn một cách chính xác nhất.',
//           confirmText: 'Bật vị trí',
//         );

//         // 2. Nếu user bấm "Bật vị trí" ở bảng giả -> Gọi bảng thật
//         if (isAgreed) {
//           permission = await Geolocator.requestPermission();
//           if (permission == LocationPermission.denied) {
//             throw 'Bạn đã từ chối quyền truy cập vị trí.';
//           }
//         } else {
//           // 3. Nếu user bấm "Để sau" -> Dừng lại, không báo lỗi đỏ, chỉ thoát hàm
//           return; 
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         if (!mounted) return;
//         _showSettingsAdviceDialog(); // Hiện bảng hướng dẫn mở Cài đặt
//         return; 
//       }
//       // ==============================================================

//       // Nếu đã qua ải xin quyền, tiến hành lấy GPS thực tế
//       Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
//       String addressText = "";
//       try {
//         List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//         if (placemarks.isNotEmpty) {
//           Placemark place = placemarks.first;
//           List<String> addressParts = [place.street ?? "", place.subAdministrativeArea ?? "", place.administrativeArea ?? ""]..removeWhere((e) => e.isEmpty);
//           addressText = addressParts.join(", ");
//         }
//       } catch (e) {
//         debugPrint("Lỗi dịch địa chỉ: $e");
//       }

//       setState(() {
//         _latitude = position.latitude;
//         _longitude = position.longitude;
//         if (addressText.isNotEmpty) _addressController.text = addressText;
//       });
//       _showSnack('Đã lấy vị trí thành công!', Colors.green);
      
//     } catch (e) {
//       _showSnack(e.toString(), Colors.red);
//     } finally {
//       if(mounted) setState(() => _isGettingLocation = false);
//     }
//   }

//   // ==============================================================
//   // THÊM HÀM NÀY ĐỂ XỬ LÝ KHI USER LỠ CHẶN VĨNH VIỄN
//   // ==============================================================
//   void _showSettingsAdviceDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Cần quyền vị trí'),
//         content: const Text('Bạn đã từ chối quyền vị trí vĩnh viễn trước đó. Để sử dụng tính năng này, vui lòng vào Cài đặt và cấp quyền lại.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings(); // Mở thẳng vào màn hình Cài đặt của app
//             },
//             child: const Text('Mở Cài đặt', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _verifyLocation() async {
//     final address = _addressController.text.trim();
//     if (address.isEmpty) return _showSnack('Vui lòng nhập địa chỉ trước!', Colors.orange);

//     setState(() => _isGettingLocation = true);
//     try {
//       List<Location> locations = await locationFromAddress(address);
//       if (locations.isNotEmpty) {
//         setState(() {
//           _latitude = locations.first.latitude;
//           _longitude = locations.first.longitude;
//         });
//         _showSnack('Đã xác minh vị trí thành công!', Colors.green);
//       }
//     } catch (e) {
//       _showSnack('Không tìm ra tọa độ. Đang lấy GPS...', Colors.blue);
//       await _getCurrentLocation();
//     } finally {
//       if(mounted) setState(() => _isGettingLocation = false);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     if(!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
//   }

//   // --- LOGIC SUBMIT ---
//   void _submitForm() {
//     if (!_formKey.currentState!.validate()) return;
    
//     final activeHours = _operatingHours
//         .where((day) => day['isActive'] == true)
//         .map((day) => {"dayOfWeek": day['dayOfWeek'], "openTime": day['openTime'], "closeTime": day['closeTime']})
//         .toList();

//     final formData = {
//       "name": _nameController.text.trim(),
//       "address": _addressController.text.trim(),
//       "phone": _phoneController.text.trim(),
//       "description": _descController.text.trim(),
//       "logoUrl": _logoUrlController.text.trim(),
//       "coverImageUrl": _coverUrlController.text.trim(),
//       "latitude": _latitude ?? 0.0,
//       "longitude": _longitude ?? 0.0,
//       "isOpen": _isOpen,
//       "operatingHours": activeHours,
//     };

//     widget.onSubmit(formData);
//   }

//   void _handleLogout() {
//     showDialog(
//       context: context,
//       barrierDismissible: false, 
//       builder: (dialogContext) {
//         bool isLoggingOut = false;

//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return AlertDialog(
//               title: const Text("Đăng xuất"),
//               content: const Text("Bạn có chắc chắn muốn thoát tài khoản?"),
//               actions: [
//                 TextButton(
//                   onPressed: isLoggingOut ? null : () => Navigator.pop(dialogContext), 
//                   child: const Text("Hủy")
//                 ),
//                 TextButton(
//                   onPressed: isLoggingOut ? null : () async {
//                     setStateDialog(() => isLoggingOut = true);

//                     await AuthService.logout();

//                     if (!context.mounted) return;

//                     Navigator.pop(dialogContext);

//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (context) => const LoginScreen()),
//                       (route) => false, 
//                     );
//                   }, 
//                   child: isLoggingOut 
//                       ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
//                       : const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             );
//           }
//         );
//       }
//     );
//   }

//   // --- PHẦN VẼ GIAO DIỆN ---
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text("Thông tin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12.0, top: 10, bottom: 10),
//             child: InkWell(
//               onTap: _handleLogout,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, color: primaryColor, size: 16),
//                     const SizedBox(width: 4),
//                     Text("Đăng xuất", style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildImageStack(),
              
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Thông tin chung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
//                     const SizedBox(height: 10),
                    
//                     _buildFlatTextField(controller: _nameController, icon: Icons.store_mall_directory_outlined, hint: "Tên cửa hàng"),
                    
//                     // Địa chỉ + Nút Check GPS mini bên cạnh
//                    // 1. Ô nhập địa chỉ
//                     _buildFlatTextField(
//                       controller: _addressController, 
//                       icon: Icons.location_on_outlined, 
//                       hint: "Địa chỉ chi tiết",
//                       onChanged: (v) {
//                         // Nếu người dùng sửa địa chỉ, xóa tọa độ cũ bắt xác minh lại
//                         if (_latitude != null) {
//                           setState(() {
//                             _latitude = null;
//                             _longitude = null;
//                           });
//                         }
//                       }
//                     ),
//                     const SizedBox(height: 16),

//                     // 2. Nút bấm Xác minh vị trí từ địa chỉ đã nhập
//                     SizedBox(
//                       width: double.infinity,
//                       height: 48,
//                       child: ElevatedButton.icon(
//                         onPressed: _isGettingLocation ? null : _verifyLocation,
//                         icon: _isGettingLocation 
//                             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : Icon(_latitude != null ? Icons.check_circle : Icons.map),
//                         label: Text(
//                           _latitude != null ? "Đã xác minh vị trí" : "Xác minh từ địa chỉ",
//                           style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _latitude != null ? Colors.green : Colors.blue,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),

//                     // 3. Nút lấy GPS hiện tại
//                     Center(
//                       child: TextButton.icon(
//                         onPressed: _isGettingLocation ? null : _getCurrentLocation,
//                         icon: const Icon(Icons.my_location, size: 18),
//                         label: const Text("Hoặc lấy vị trí GPS hiện tại"),
//                         style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
//                       ),
//                     ),

//                     // 4. Hiển thị tọa độ mờ bên dưới nếu đã có
//                     if (_latitude != null && _longitude != null)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 12.0),
//                         child: Center(
//                           child: Text(
//                             "📍 Lat: $_latitude, Lng: $_longitude",
//                             style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
//                           ),
//                         ),
//                       ),

//                     _buildFlatTextField(controller: _phoneController, icon: Icons.phone_outlined, hint: "Số điện thoại", isPhone: true),
                    
//                     // Switch Đóng / Mở cửa
//                     ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       leading: Icon(Icons.meeting_room_outlined, color: primaryColor),
//                       title: const Text("Đóng cửa/Mở cửa", style: TextStyle(fontSize: 15, color: Colors.black87)),
//                       trailing: Switch(
//                         activeThumbColor: Colors.white,
//                         activeTrackColor: Colors.green,
//                         value: _isOpen,
//                         onChanged: (val) => setState(() => _isOpen = val),
//                       ),
//                     ),
//                     const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

//                     // Nút mở rộng quản lý 7 ngày
//                     Theme(
//                       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         tilePadding: EdgeInsets.zero,
//                         leading: Icon(Icons.calendar_month_outlined, color: primaryColor),
//                         title: const Text("Chi tiết giờ hoạt động (7 ngày)", style: TextStyle(fontSize: 15, color: Colors.black87)),
//                         children: [_buildOperatingHoursSection()],
//                       ),
//                     ),
//                     const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

//                     // Giới thiệu cửa hàng
//                     const SizedBox(height: 15),
//                     Row(
//                       children: [
//                         Icon(Icons.description_outlined, color: primaryColor),
//                         const SizedBox(width: 15),
//                         const Text("Giới thiệu cửa hàng", style: TextStyle(fontSize: 15, color: Colors.black87)),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Container(
//                       decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                             decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
//                             child: const Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("Normal", style: TextStyle(color: Colors.black54)),
//                                 Icon(Icons.arrow_drop_down, color: Colors.black54),
//                                 Text("Sans Serif", style: TextStyle(color: Colors.black54)),
//                                 Icon(Icons.arrow_drop_down, color: Colors.black54),
//                                 Text("12 pt", style: TextStyle(color: Colors.black54)),
//                               ],
//                             ),
//                           ),
//                           TextFormField(
//                             controller: _descController,
//                             maxLines: 4,
//                             decoration: const InputDecoration(
//                               hintText: "Nhập mô tả...",
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.all(12),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 20),
//                     Theme(
//                       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         tilePadding: EdgeInsets.zero,
//                         leading: Icon(Icons.link, color: primaryColor),
//                         title: const Text("Cập nhật Link Ảnh thủ công", style: TextStyle(fontSize: 14, color: Colors.black54)),
//                         children: [
//                           _buildFlatTextField(controller: _logoUrlController, icon: Icons.image_outlined, hint: "Link Avatar URL", isRequired: false),
//                           _buildFlatTextField(controller: _coverUrlController, icon: Icons.wallpaper_outlined, hint: "Link Cover URL", isRequired: false),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 30),
                    
//                     // Nút Submit
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: widget.isSubmitting ? null : _submitForm,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: widget.isSubmitting
//                             ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : Text(widget.buttonText, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Khung chứa Ảnh Bìa và Ảnh Đại Diện (ĐÃ FIX LỖI CRASH GIAO DIỆN)
//   Widget _buildImageStack() {
//     return SizedBox(
//       height: 240,
//       child: Stack(
//         alignment: Alignment.topCenter, // Đặt gốc căn chỉnh cho Stack
//         clipBehavior: Clip.none, // Cho phép Avatar lồi ra ngoài viền của Stack nếu cần
//         children: [
//           // Cover Image
//           Container(
//             height: 180,
//             width: double.infinity,
//             color: Colors.grey.shade300,
//             child: _coverUrlController.text.isNotEmpty
//                 ? Image.network(_coverUrlController.text, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: Colors.grey))
//                 : const Icon(Icons.wallpaper, size: 50, color: Colors.grey),
//           ),
          
//           // Nút Thay ảnh bìa
//           Positioned(
//             top: 15,
//             right: 15,
//             child: OutlinedButton(
//               onPressed: () { /*  Gọi thư viện ImagePicker */ },
//               style: OutlinedButton.styleFrom(
//                 backgroundColor: Colors.black.withValues(alpha: 0.5),
//                 side: const BorderSide(color: Colors.white),
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//               ),
//               child: const Text("Thay ảnh bìa", style: TextStyle(color: Colors.white)),
//             ),
//           ),
          
//           // Avatar và nút thay đổi (Đã fix lỗi Column vô hạn)
//     // Avatar và nút thay đổi (Đã fix hoàn toàn lỗi Overflow và tự động căn giữa)
//           Positioned(
//             bottom: 0, // Căn bám sát đáy
//             left: 0,   // Thêm left: 0
//             right: 0,  // Thêm right: 0 để ép khung này dàn đều 2 bên (giúp Column tự căn giữa)
//             // ĐÃ XÓA: SizedBox(height: 120)
//             child: Column(
//               mainAxisSize: MainAxisSize.min, // Cho phép chiều cao tự động giãn nở theo nội dung bên trong
//               children: [
//                 CircleAvatar(
//                   radius: 45,
//                   backgroundColor: Colors.white,
//                   child: CircleAvatar(
//                     radius: 42,
//                     backgroundColor: Colors.grey.shade200,
//                     backgroundImage: _logoUrlController.text.isNotEmpty ? NetworkImage(_logoUrlController.text) : null,
//                     child: _logoUrlController.text.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
//                   ),
//                 ),
//                 const SizedBox(height: 4), // Khoảng cách nhỏ giữa avatar và nút
//                 OutlinedButton(
//                   onPressed: () { /*  Gọi thư viện ImagePicker */ },
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(80, 25),
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     side: const BorderSide(color: Colors.grey), // Đổi viền sang xám
//                     backgroundColor: Colors.white, // Nền trắng
//                   ),
//                   child: const Text("Thay ảnh", style: TextStyle(color: Colors.black87, fontSize: 12)),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFlatTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPhone = false, bool isRequired = true, Function(String)? onChanged}) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
//       onChanged: onChanged,
//       validator: isRequired ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.black54, fontSize: 15),
//         prefixIcon: Icon(icon, color: primaryColor),
//         prefixIconConstraints: const BoxConstraints(minWidth: 40),
//         contentPadding: const EdgeInsets.symmetric(vertical: 15),
//         enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEEEEEE))),
//         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 1.5)),
//         errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
//       ),
//     );
//   }

//   Widget _buildOperatingHoursSection() {
//     const days = ["Chủ nhật", "Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7"];
//     return Column(
//       children: List.generate(_operatingHours.length, (index) {
//         final day = _operatingHours[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
//           child: Row(
//             children: [
//               Checkbox(
//                 value: day['isActive'],
//                 activeColor: primaryColor,
//                 onChanged: (val) => setState(() => day['isActive'] = val ?? false),
//               ),
//               SizedBox(width: 70, child: Text(days[day['dayOfWeek']], style: const TextStyle(fontSize: 13))),
//               if (day['isActive']) ...[
//                 Expanded(child: _buildTimeButton(day['openTime'], (time) => setState(() => day['openTime'] = time))),
//                 const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("-", style: TextStyle(color: Colors.grey))),
//                 Expanded(child: _buildTimeButton(day['closeTime'], (time) => setState(() => day['closeTime'] = time))),
//               ] else
//                 const Expanded(child: Text(" Nghỉ", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 13))),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildTimeButton(String timeString, Function(String) onTimeChanged) {
//     return InkWell(
//       onTap: () async {
//         final parts = timeString.split(':');
//         TimeOfDay initialTime = (parts.length == 2) ? TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])) : TimeOfDay.now();
//         final picked = await showTimePicker(context: context, initialTime: initialTime, helpText: 'Chọn giờ');
//         if (picked != null) {
//           onTimeChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
//         alignment: Alignment.center,
//         child: Text(timeString, style: const TextStyle(fontSize: 13)),
//       ),
//     );
//   }
// }

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
  
  // Vẫn giữ Controller để phục vụ cho ô nhập tay ở dưới cùng
  late TextEditingController _logoUrlController;
  late TextEditingController _coverUrlController;

  // Thêm 2 biến String để truyền vào StoreImageHeader
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
    
    // Khởi tạo cả String và Controller
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
    // 1. Luôn tạo sẵn cái khung 7 ngày mặc định trên giao diện (mặc định cho nghỉ hết)
    _operatingHours = List.generate(7, (index) => OperatingHour(
      dayOfWeek: index, 
      openTime: "08:30", 
      closeTime: "20:30", 
      isActive: false 
    ));

    // 2. Lấy dữ liệu từ DB (nếu có) đè lên cái khung 7 ngày đó
    if (apiHours != null && apiHours is List) {
      for (var h in apiHours) {
        int dayIndex = h['dayOfWeek'] ?? -1;
        // Nếu DB có lưu ngày này, cập nhật giờ và tự động bật tick xanh
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
      
      // ==============================================================
      // KHÚC SỬA MỚI: CHÈN BẢNG GIẢ VÀO ĐÂY
      // ==============================================================
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        // 1. Hiện "Bảng Giả"
        bool isAgreed = await PermissionDialog.showCustomPrompt(
          context: context,
          icon: Icons.location_on_rounded,
          title: 'Định vị cửa hàng',
          description: 'Ứng dụng cần quyền vị trí để tự động lấy tọa độ GPS của bạn một cách chính xác nhất.',
          confirmText: 'Bật vị trí',
        );

        // 2. Nếu user bấm "Bật vị trí" ở bảng giả -> Gọi bảng thật
        if (isAgreed) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw 'Bạn đã từ chối quyền truy cập vị trí.';
          }
        } else {
          // 3. Nếu user bấm "Để sau" -> Dừng lại, không báo lỗi đỏ, chỉ thoát hàm
          return; 
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showSettingsAdviceDialog(); // Hiện bảng hướng dẫn mở Cài đặt
        return; 
      }
      // ==============================================================

      // Nếu đã qua ải xin quyền, tiến hành lấy GPS thực tế
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

  // ==============================================================
  // THÊM HÀM NÀY ĐỂ XỬ LÝ KHI USER LỠ CHẶN VĨNH VIỄN
  // ==============================================================
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
              openAppSettings(); // Mở thẳng vào màn hình Cài đặt của app
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
    
    // Sử dụng toJson() để đồng bộ toàn bộ biến
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
              
              // Cập nhật lại cách gọi StoreImageHeader theo code mới
              StoreImageHeader(
                coverUrl: _coverUrl,
                logoUrl: _logoUrl,
                onCoverUploaded: (newUrl) {
                  setState(() {
                    _coverUrl = newUrl;
                    _coverUrlController.text = newUrl; // Đồng bộ xuống ô Text ở dưới
                  });
                },
                onLogoUploaded: (newUrl) {
                  setState(() {
                    _logoUrl = newUrl;
                    _logoUrlController.text = newUrl; // Đồng bộ xuống ô Text ở dưới
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
                                _logoUrl = val; // Đồng bộ ngược lên ảnh Logo ở Header
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
                                _coverUrl = val; // Đồng bộ ngược lên ảnh Cover ở Header
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