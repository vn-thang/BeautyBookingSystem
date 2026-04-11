import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_bill_preview_screen.dart';
import 'package:mobile_store/features/payment/services/store_payment_api.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../../../shared/widgets/inputs/app_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';

import '../models/store_booking_model.dart';
import '../services/store_booking_api.dart';
import '../widgets/assign_staff_bottom_sheet.dart';
import '../widgets/booking_detail_components.dart';
import '../widgets/booking_action_dialogs.dart'; 
import '../widgets/booking_detail_bottom_actions.dart'; 

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
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge))
      ),
      builder: (context) => AssignStaffBottomSheet(
        booking: booking,
        onSuccess: _loadData, 
      ),
    );
  }

  Future<void> _confirmBookingDirectly(int bookingId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      await StoreBookingApi.assignStaff(bookingId, []);
      
      if (!mounted) return;
      Navigator.pop(context); 
      
      SnackBarHelper.showSuccess(context, 'Xác nhận đơn thành công!');
      _loadData();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      SnackBarHelper.showError(context, e.toString());
    }
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
        SnackBarHelper.showSuccess(context, '🎉 Đã thu tiền và hoàn tất dịch vụ thành công!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, e.toString());
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
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      await StoreBookingApi.updateStatus(widget.bookingId, status, cancelReason: cancelReason);
      
      if (!mounted) return;
      Navigator.pop(context); 
      _loadData(); 
      
      SnackBarHelper.showSuccess(context, 'Cập nhật trạng thái thành công!');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      SnackBarHelper.showError(context, e.toString());
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => CancelBookingDialog(
        onConfirmCancel: (reason) => _updateStatus('Cancelled', cancelReason: reason),
      ),
    );
  }
  void _showNoShowDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Xác nhận vắng mặt', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)
        ),
        content: const Text(
          'Bạn có chắc chắn khách hàng này không đến? Đơn này sẽ bị hủy và hệ thống sẽ ghi nhận lịch sử vi phạm của khách.',
          style: TextStyle(color: AppColors.textSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BỎ QUA', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await StoreBookingApi.markNoShow(bookingId: widget.bookingId);
                
                if (mounted) {
                  SnackBarHelper.showSuccess(context, 'Đã ghi nhận khách vắng mặt thành công!');
                  _loadData(); 
                }
              } catch (e) {
                if (mounted) SnackBarHelper.showError(context, e.toString());
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCompleteAndPayDialog(StoreBookingDetailModel detail) {
    showDialog(
      context: context,
      builder: (context) => CompleteAndPayDialog(
        detail: detail,
        onConfirm: () {
          final paymentId = detail.paymentId; 
          if (paymentId != null) {
            _handleCheckoutAndComplete(paymentId);
          } else {
            SnackBarHelper.showError(context, 'Không tìm thấy mã thanh toán của đơn này!');
          }
        },
      ),
    );
  }

  Future<void> _exportBill() async {
    setState(() => _isLoading = true);
    try {
      final billData = await StoreBookingApi.getBillDetail(widget.bookingId);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingBillPreviewScreen(bill: billData),
        ),
      );

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(context, 'Lỗi tải hóa đơn: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreBookingDetailModel>(
      future: _detailFuture,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppHeader(title: 'Đang tải...'),
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const AppHeader(title: 'Lỗi'),
            body: Center(child: Text('Lỗi: ${snapshot.error}')),
          );
        }
        
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppHeader(title: 'Lỗi'),
            body: Center(child: Text('Không tìm thấy dữ liệu.')),
          );
        }

        final detail = snapshot.data!;
        final isCompleted = detail.status == 'Completed';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppHeader(
            title: 'Chi tiết đơn #${widget.bookingId}',
            actions: [
              if (isCompleted)
                IconButton(
                  icon: const Icon(Icons.print, color: AppColors.white),
                  tooltip: 'In hóa đơn',
                  onPressed: _exportBill,
                ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _loadData(),
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimens.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookingStatusBanner(detail: detail),
                            const SizedBox(height: AppSpacing.lg),
                            CustomerSection(detail: detail),
                            const SizedBox(height: AppSpacing.lg),
                            ServicesSection(detail: detail),
                            const SizedBox(height: AppSpacing.lg),
                            PaymentSection(detail: detail),
                          ],
                        ),
                      ),
                    ),
                  ),
                  BookingDetailBottomActions(
                    detail: detail,
                    onCancelPressed: _showCancelDialog,
                    onAssignStaffPressed: () => _openAssignStaffSheet(detail),
                    onConfirmPressed: () => _confirmBookingDirectly(detail.id), 
                    onCompletePressed: () => _showCompleteAndPayDialog(detail),
                    onNoShowPressed: _showNoShowDialog, 
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: AppColors.textMain.withValues(alpha: 0.2), 
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
            ],
          ),
        );
      },
    );
  }
}