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
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => AssignStaffBottomSheet(
        booking: booking,
        onSuccess: _loadData, 
      ),
    );
  }

  Future<void> _handleCheckoutAndComplete(int paymentId) async {
    setState(() => _isLoading = true); 
    try {
      await StorePaymentApi.confirmPayment(
        paymentId, 
       
        transactionId: 'CASH_${DateTime.now().millisecondsSinceEpoch}', 
      );

      await _updateStatus('Completed'); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Đã thu tiền và hoàn tất dịch vụ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        
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
      Navigator.pop(context); 
      _loadData(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thành công!'), backgroundColor: Colors.green)
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
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
                
                Navigator.pop(context);
                
                final paymentId = detail.paymentId; 
                if (paymentId != null) {
                
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
                  autofocus: true, 
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
              onPressed: () => Navigator.pop(context), 
              child: const Text('ĐÓNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
               
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context); 
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
                  _buildBottomActionButtons(detail),
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

  Widget _buildBottomActionButtons(StoreBookingDetailModel detail) {
     if (detail.status.toLowerCase() == 'pending') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
        child: Row(
          children: [
         
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, 
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
             
                onPressed: _showCancelDialog,
                child: const Text('TỪ CHỐI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
         
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
    
    return const SizedBox.shrink();
  }
}