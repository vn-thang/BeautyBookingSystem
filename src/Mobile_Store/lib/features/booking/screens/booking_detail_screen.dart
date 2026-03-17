// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mobile_store/features/payment/services/store_payment_api.dart';
// import '../models/store_booking_model.dart';
// import '../services/store_booking_api.dart';
// import '../widgets/assign_staff_bottom_sheet.dart';

// class BookingDetailScreen extends StatefulWidget {
//   final int bookingId;
  

//   const BookingDetailScreen({super.key, required this.bookingId});

//   @override
//   State<BookingDetailScreen> createState() => _BookingDetailScreenState();
// }

// class _BookingDetailScreenState extends State<BookingDetailScreen> {
//   late Future<StoreBookingDetailModel> _detailFuture;
//   final Color primaryColor = const Color(0xFFDE4660);
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() {
//     setState(() {
//       _detailFuture = StoreBookingApi.getBookingDetail(widget.bookingId);
//     });
//   }

//   // --- CÁC HÀM XỬ LÝ NÚT BẤM (API) ---

//   void _openAssignStaffSheet(StoreBookingDetailModel booking) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // Cho phép bottom sheet kéo dài lên trên
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => AssignStaffBottomSheet(
//         booking: booking,
//         onSuccess: _loadData, // Sau khi gán xong thì gọi load lại data để màn hình update
//       ),
//     );
//   }

//   Future<void> _handleCheckoutAndComplete(int paymentId) async {
//     setState(() => _isLoading = true); // Hiện vòng xoay loading trên toàn màn hình

//     try {
//       // 1. GỌI API THU TIỀN TRƯỚC
//       // (Thay bằng class API thực tế của bạn, vd: StorePaymentApi)
//       await StorePaymentApi.confirmPayment(
//         paymentId, 
//         // Nếu có truyền transactionId thì điền, không thì truyền rỗng hoặc null tùy thiết kế API của bạn
//         transactionId: 'CASH_${DateTime.now().millisecondsSinceEpoch}', 
//       );

//       // 2. GỌI API HOÀN THÀNH BOOKING SAU
//       // (Truyền chữ 'Completed' theo đúng Enum Backend C# của bạn)
//       await _updateStatus('Completed'); 

//       // 3. THÔNG BÁO THÀNH CÔNG
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('🎉 Đã thu tiền và hoàn tất dịch vụ thành công!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Load lại chi tiết hoặc pop về màn hình trước
//         // Navigator.pop(context, true); 
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _updateStatus(String status, {String? cancelReason}) async {
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );

//       await StoreBookingApi.updateStatus(widget.bookingId, status, cancelReason: cancelReason);
      
//       if (!mounted) return;
//       Navigator.pop(context); // Đóng loading
//       _loadData(); // Tải lại dữ liệu mới
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Cập nhật trạng thái thành công!'), backgroundColor: Colors.green)
//       );
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context); // Đóng loading
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
//       );
//     }
//   }

//   void _showCompleteAndPayDialog(StoreBookingDetailModel detail) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text('Xác nhận hoàn thành', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Khách hàng đã sử dụng xong dịch vụ này?'),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.payments_outlined, color: Colors.orange),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         // Cập nhật giá trị hiển thị nếu cần
//                         'Số tiền cần thu: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(detail.totalPrice)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text('Lưu ý: Xác nhận hoàn thành sẽ đồng thời ghi nhận bạn đã thu đủ số tiền trên (tiền mặt).', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               onPressed: () {
//                 // Đóng dialog ngay lập tức
//                 Navigator.pop(context);
                
//                 // KIỂM TRA QUAN TRỌNG: Lấy PaymentId từ detail
//                 // Lưu ý: Đảm bảo model `detail` của bạn có trường paymentId trả về từ API nhé!
//                 final paymentId = detail.paymentId; 
//                 if (paymentId != null) {
//                   // Bắt đầu chuỗi gọi API
//                   _handleCheckoutAndComplete(paymentId);
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Lỗi: Không tìm thấy mã thanh toán của đơn này!')),
//                   );
//                 }
//               },
//               child: const Text('THANH TOÁN & HOÀN TẤT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showCancelDialog() {
//     final TextEditingController reasonController = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           scrollable: true,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text('Lý do hủy đơn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
//           content: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Vui lòng nhập lý do từ chối/hủy đơn này để thông báo cho khách hàng:', 
//                   style: TextStyle(fontSize: 14, color: Colors.black87)
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: reasonController,
//                   maxLines: 3,
//                   autofocus: true, // Tự động bật bàn phím khi mở popup
//                   decoration: InputDecoration(
//                     hintText: 'VD: Cửa hàng mất điện đột xuất, Không sắp xếp được thợ...',
//                     hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8), 
//                       borderSide: const BorderSide(color: Colors.red)
//                     ),
//                     contentPadding: const EdgeInsets.all(12),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Vui lòng không để trống lý do';
//                     }
//                     if (value.trim().length < 5) {
//                       return 'Lý do quá ngắn';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context), // Đóng Popup
//               child: const Text('ĐÓNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               onPressed: () {
//                 // Kiểm tra xem đã nhập lý do hợp lệ chưa
//                 if (formKey.currentState!.validate()) {
//                   Navigator.pop(context); // Đóng Popup
//                   // Gọi API cập nhật trạng thái với lý do vừa nhập
//                   _updateStatus('Cancelled', cancelReason: reasonController.text.trim());
//                 }
//               },
//               child: const Text('XÁC NHẬN HỦY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // --- UI BUILDING ---

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: Text('Chi tiết đơn #${widget.bookingId}',
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//         centerTitle: true,
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       // Dùng Stack để có thể chồng lớp Loading lên trên giao diện chính
//       body: Stack(
//         children: [
//           // Lớp 1: Giao diện chính (FutureBuilder)
//           FutureBuilder<StoreBookingDetailModel>(
//             future: _detailFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator(color: primaryColor));
//               }
//               if (snapshot.hasError) {
//                 return Center(child: Text('Lỗi: ${snapshot.error}'));
//               }
//               if (!snapshot.hasData) {
//                 return const Center(child: Text('Không tìm thấy dữ liệu.'));
//               }

//               final detail = snapshot.data!;
//               return Column(
//                 children: [
//                   Expanded(
//                     child: RefreshIndicator(
//                       onRefresh: () async => _loadData(),
//                       color: primaryColor,
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildStatusBanner(detail),
//                             const SizedBox(height: 16),
//                             _buildCustomerSection(detail),
//                             const SizedBox(height: 16),
//                             _buildServicesSection(detail),
//                             const SizedBox(height: 16),
//                             _buildPaymentSection(detail),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   _buildBottomActionButtons(detail),
//                 ],
//               );
//             },
//           ),

//           // Lớp 2: Lớp phủ chặn tương tác khi đang xử lý (Xử lý lỗi unused_field _isLoading)
//           if (_isLoading)
//             Container(
//               color: Colors.black.withValues(alpha: 0.3), // Làm mờ màn hình
//               child: Center(
//                 child: CircularProgressIndicator(color: primaryColor),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // --- WIDGETS CON (CLEAN CODE) ---

//   Widget _buildStatusBanner(StoreBookingDetailModel detail) {
//     Color bgColor;
//     String statusText;
//     switch (detail.status.toLowerCase()) {
//       case 'pending': bgColor = Colors.orange; statusText = 'Đang chờ duyệt'; break;
//       case 'confirmed': bgColor = Colors.blue; statusText = 'Đã xác nhận'; break;
//       case 'completed': bgColor = Colors.green; statusText = 'Đã hoàn thành'; break;
//       case 'cancelled': bgColor = Colors.red; statusText = 'Đã hủy (${detail.cancelReason ?? 'Không rõ'})'; break;
//       default: bgColor = Colors.grey; statusText = 'Không rõ';
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: bgColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: bgColor)),
//       child: Text(
//         'Trạng thái: $statusText',
//         style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 15),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildCustomerSection(StoreBookingDetailModel detail) {
//     return _CardContainer(
//       title: 'Thông tin khách hàng',
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _InfoRow(icon: Icons.person_outline, label: 'Khách hàng', value: detail.customerName),
//           const SizedBox(height: 8),
//           _InfoRow(icon: Icons.phone_outlined, label: 'Số điện thoại', value: detail.customerPhone),
//           if (detail.customerNote != null && detail.customerNote!.isNotEmpty) ...[
//             const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
//             _InfoRow(icon: Icons.edit_note, label: 'Ghi chú', value: detail.customerNote!),
//           ]
//         ],
//       ),
//     );
//   }

//   Widget _buildServicesSection(StoreBookingDetailModel detail) {
//     final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
//     final dateFormat = DateFormat('dd/MM/yyyy', 'vi_VN');

//     return _CardContainer(
//       title: 'Dịch vụ đã chọn (${detail.services.length})',
//       child: ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: detail.services.length,
//         separatorBuilder: (context, index) => const Divider(height: 24),
//         itemBuilder: (context, index) {
//           final service = detail.services[index];
//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 50, height: 50,
//                 decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
//                 child: const Icon(Icons.spa_outlined, color: Colors.grey),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(service.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${service.startTime} - ${service.endTime} • ${dateFormat.format(service.appointmentDate)}',
//                       style: const TextStyle(color: Colors.grey, fontSize: 13),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Nhân viên: ${service.staffName ?? "Chưa phân công"}',
//                       style: TextStyle(
//                         color: service.staffName == null ? Colors.orange : Colors.blue, 
//                         fontSize: 13, 
//                         fontWeight: FontWeight.w500
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 currencyFormat.format(service.price),
//                 style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDE4660)),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPaymentSection(StoreBookingDetailModel detail) {
//     final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
//     return _CardContainer(
//       title: 'Chi tiết thanh toán',
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Tổng tạm tính', style: TextStyle(color: Colors.grey)),
//               Text(currencyFormat.format(detail.totalPrice), style: const TextStyle(fontWeight: FontWeight.w500)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Khuyến mãi', style: TextStyle(color: Colors.grey)),
//               Text('- ${currencyFormat.format(detail.discountAmount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
//             ],
//           ),
//           const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               Text(currencyFormat.format(detail.finalPrice), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Thanh nút bấm cố định ở dưới đáy tùy theo trạng thái
//   Widget _buildBottomActionButtons(StoreBookingDetailModel detail) {
//     if (detail.status.toLowerCase() == 'pending') {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
//         child: Row(
//           children: [
//             // Nút Từ chối / Hủy đơn
//             Expanded(
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.red, 
//                   side: const BorderSide(color: Colors.red),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 // Tạm thời hardcode lý do hủy, lát mình có thể nâng cấp lên thành 1 popup nhập lý do
//                 onPressed: _showCancelDialog,
//                 child: const Text('TỪ CHỐI', style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Nút Duyệt & Gán nhân viên
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 onPressed: () => _openAssignStaffSheet(detail),
//                 child: const Text('DUYỆT & GÁN NV', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
    
//     if (detail.status.toLowerCase() == 'confirmed') {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
//         child: Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 onPressed: _showCancelDialog,
//                 child: const Text('HỦY ĐƠN', style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 onPressed: () => _showCompleteAndPayDialog(detail),
//                 child: const Text('HOÀN THÀNH', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
    
//     return const SizedBox.shrink(); // Các trạng thái khác (Cancelled, Completed) thì không hiện nút
//   }
// }

// // --- CÁC WIDGET DÙNG CHUNG TRONG FILE ---

// class _CardContainer extends StatelessWidget {
//   final String title;
//   final Widget child;
//   const _CardContainer({required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _InfoRow({required this.icon, required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: Colors.grey),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
//               const SizedBox(height: 2),
//               Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store/features/payment/services/store_payment_api.dart';
import '../models/store_booking_model.dart';
import '../services/store_booking_api.dart';
import '../widgets/assign_staff_bottom_sheet.dart';
import '../widgets/booking_detail_components.dart';
import '../../../core/theme/app_colors.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Future<StoreBookingDetailModel> _detailFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _detailFuture = StoreBookingApi.getBookingDetail(widget.bookingId);
    });
  }

 void _openAssignStaffSheet(StoreBookingDetailModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép bottom sheet kéo dài lên trên
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => AssignStaffBottomSheet(
        booking: booking,
        onSuccess: _loadData, // Sau khi gán xong thì gọi load lại data để màn hình update
      ),
    );
  }

  Future<void> _handleCheckoutAndComplete(int paymentId) async {
    setState(() => _isLoading = true); // Hiện vòng xoay loading trên toàn màn hình

    try {
      // 1. GỌI API THU TIỀN TRƯỚC
      // (Thay bằng class API thực tế của bạn, vd: StorePaymentApi)
      await StorePaymentApi.confirmPayment(
        paymentId, 
        // Nếu có truyền transactionId thì điền, không thì truyền rỗng hoặc null tùy thiết kế API của bạn
        transactionId: 'CASH_${DateTime.now().millisecondsSinceEpoch}', 
      );

      // 2. GỌI API HOÀN THÀNH BOOKING SAU
      // (Truyền chữ 'Completed' theo đúng Enum Backend C# của bạn)
      await _updateStatus('Completed'); 

      // 3. THÔNG BÁO THÀNH CÔNG
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Đã thu tiền và hoàn tất dịch vụ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Load lại chi tiết hoặc pop về màn hình trước
        // Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status, {String? cancelReason}) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await StoreBookingApi.updateStatus(widget.bookingId, status, cancelReason: cancelReason);
      
      if (!mounted) return;
      Navigator.pop(context); // Đóng loading
      _loadData(); // Tải lại dữ liệu mới
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thành công!'), backgroundColor: Colors.green)
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Đóng loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.primary)
      );
    }
  }

  void _showCompleteAndPayDialog(StoreBookingDetailModel detail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận hoàn thành', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Khách hàng đã sử dụng xong dịch vụ này?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        // Cập nhật giá trị hiển thị nếu cần
                        'Số tiền cần thu: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(detail.totalPrice)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Lưu ý: Xác nhận hoàn thành sẽ đồng thời ghi nhận bạn đã thu đủ số tiền trên (tiền mặt).', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                // Đóng dialog ngay lập tức
                Navigator.pop(context);
                
                // KIỂM TRA QUAN TRỌNG: Lấy PaymentId từ detail
                // Lưu ý: Đảm bảo model `detail` của bạn có trường paymentId trả về từ API nhé!
                final paymentId = detail.paymentId; 
                if (paymentId != null) {
                  // Bắt đầu chuỗi gọi API
                  _handleCheckoutAndComplete(paymentId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lỗi: Không tìm thấy mã thanh toán của đơn này!')),
                  );
                }
              },
              child: const Text('THANH TOÁN & HOÀN TẤT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog() {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Lý do hủy đơn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vui lòng nhập lý do từ chối/hủy đơn này để thông báo cho khách hàng:', 
                  style: TextStyle(fontSize: 14, color: Colors.black87)
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  autofocus: true, // Tự động bật bàn phím khi mở popup
                  decoration: InputDecoration(
                    hintText: 'VD: Cửa hàng mất điện đột xuất, Không sắp xếp được thợ...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), 
                      borderSide: const BorderSide(color: Colors.red)
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng không để trống lý do';
                    }
                    if (value.trim().length < 5) {
                      return 'Lý do quá ngắn';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Đóng Popup
              child: const Text('ĐÓNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Kiểm tra xem đã nhập lý do hợp lệ chưa
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context); // Đóng Popup
                  // Gọi API cập nhật trạng thái với lý do vừa nhập
                  _updateStatus('Cancelled', cancelReason: reasonController.text.trim());
                }
              },
              child: const Text('XÁC NHẬN HỦY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Chi tiết đơn #${widget.bookingId}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FutureBuilder<StoreBookingDetailModel>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: Text('Không tìm thấy dữ liệu.'));

              final detail = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _loadData(),
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // GỌI CÁC COMPONENT ĐÃ TÁCH - CODE SIÊU SẠCH!
                            BookingStatusBanner(detail: detail),
                            const SizedBox(height: 16),
                            CustomerSection(detail: detail),
                            const SizedBox(height: 16),
                            ServicesSection(detail: detail),
                            const SizedBox(height: 16),
                            PaymentSection(detail: detail),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomActionButtons(detail), // Phần này liên quan logic nên để lại trong file này
                ],
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  // Giữ lại hàm này vì nó chứa logic gọi các hàm nội bộ của Screen (Dialog, BottomSheet)
  Widget _buildBottomActionButtons(StoreBookingDetailModel detail) {
     if (detail.status.toLowerCase() == 'pending') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
        child: Row(
          children: [
            // Nút Từ chối / Hủy đơn
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, 
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                // Tạm thời hardcode lý do hủy, lát mình có thể nâng cấp lên thành 1 popup nhập lý do
                onPressed: _showCancelDialog,
                child: const Text('TỪ CHỐI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            // Nút Duyệt & Gán nhân viên
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _openAssignStaffSheet(detail),
                child: const Text('DUYỆT & GÁN NV', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }
    
    if (detail.status.toLowerCase() == 'confirmed') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showCancelDialog,
                child: const Text('HỦY ĐƠN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showCompleteAndPayDialog(detail),
                child: const Text('HOÀN THÀNH', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink(); // Các trạng thái khác (Cancelled, Completed) thì không hiện nút
  }
}