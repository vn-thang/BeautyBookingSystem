import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_detail_screen.dart';
import '../services/store_payment_api.dart';
import '../models/store_payment_model.dart';
import '../widgets/payment_item_card.dart';
import '../widgets/payment_dialogs.dart';
import '../../../core/theme/app_colors.dart';

class StorePaymentScreen extends StatefulWidget {
  const StorePaymentScreen({super.key});

  @override
  State<StorePaymentScreen> createState() => _StorePaymentScreenState();
}

class _StorePaymentScreenState extends State<StorePaymentScreen> {
  bool _isLoading = true;
  List<StorePaymentModel> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);
    try {
      final data = await StorePaymentApi.getPayments();
      setState(() {
        _payments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  Future<void> _handleConfirm(StorePaymentModel payment, String transactionId) async {
    try {
      await StorePaymentApi.confirmPayment(payment.id, transactionId: transactionId);
      _showSnackBar('Xác nhận thanh toán thành công!');
      _fetchPayments();
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  Future<void> _handleRefund(StorePaymentModel payment) async {
    try {
      await StorePaymentApi.refundPayment(payment.id);
      _showSnackBar('Hoàn tiền thành công!');
      _fetchPayments();
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  Future<void> _processConfirmPayment(StorePaymentModel payment) async {
    final bStatus = payment.bookingStatus.toLowerCase();
    
    if (bStatus == 'pending') {
      _showSnackBar('Lỗi: Đơn này chưa được duyệt! Vui lòng duyệt đơn trước.', isError: true);
      return;
    }
    if (bStatus == 'cancelled') {
      _showSnackBar('Lỗi: Đơn này đã bị hủy, không thể thu tiền!', isError: true);
      return;
    }

    final transId = await PaymentDialogs.showConfirmDialog(context, payment);
    if (transId != null) {
      _handleConfirm(payment, transId);
    }
  }

  Future<void> _processRefundPayment(StorePaymentModel payment) async {
    final isConfirmed = await PaymentDialogs.showRefundDialog(context, payment);
    if (isConfirmed) {
      _handleRefund(payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingList = _payments.where((p) => p.status.toLowerCase() == 'pending').toList();
    final successList = _payments.where((p) => p.status.toLowerCase() == 'success').toList();
    final refundedList = _payments.where((p) => p.status.toLowerCase() == 'refunded').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100, 
        appBar: AppBar(
          title: const Text('Sổ Thu Chi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.white70, 
            indicatorColor: Colors.white, 
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Chờ thu'),  
              Tab(text: 'Đã thu'), 
              Tab(text: 'Đã hoàn')
            ],
          ),
        ),
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              children: [
                _buildListView(pendingList, isPending: true),
                _buildListView(successList, isSuccess: true),
                _buildListView(refundedList),
              ],
            ),
      ),
    );
  }

  Widget _buildListView(List<StorePaymentModel> items, {bool isPending = false, bool isSuccess = false}) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Không có giao dịch nào', style: TextStyle(color: Colors.grey, fontSize: 16))
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final payment = items[index];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
              
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(
                        bookingId: payment.bookingId, 
                      ),
                    ),
                  ).then((_) {
                    _fetchPayments(); 
                  });
                },
                child: PaymentItemCard(
                  payment: payment,
                  isPending: isPending,
                  isSuccess: isSuccess,
                  onConfirm: () => _processConfirmPayment(payment), 
                  onRefund: () => _processRefundPayment(payment),  
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}