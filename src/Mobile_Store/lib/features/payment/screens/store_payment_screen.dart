import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_detail_screen.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../services/store_payment_api.dart';
import '../models/store_payment_model.dart';
import '../widgets/payment_item_card.dart';
import '../widgets/payment_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';

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
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      SnackBarHelper.showError(context, message);
    } else {
      SnackBarHelper.showSuccess(context, message);
    }
  }

  Future<void> _handleConfirm(StorePaymentModel payment, String transactionId) async {
    try {
      await StorePaymentApi.confirmPayment(payment.id, transactionId: transactionId);
      _showSnackBar('Xác nhận thanh toán thành công!');
      _fetchPayments();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _handleRefund(StorePaymentModel payment) async {
    try {
      await StorePaymentApi.refundPayment(payment.id);
      _showSnackBar('Hoàn tiền thành công!');
      _fetchPayments();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
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
        backgroundColor: AppColors.background, 
        appBar: AppHeader(
          title: 'Sổ Thu Chi',
          bottom: TabBar(
            labelColor: AppColors.white, 
            unselectedLabelColor: AppColors.white.withValues(alpha: 0.7), 
            indicatorColor: AppColors.white, 
            indicatorWeight: 3,
            labelStyle: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Chờ thu'),  
              Tab(text: 'Đã thu'), 
              Tab(text: 'Đã hoàn')
            ],
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
      return Center(
        child: Text('Không có giao dịch nào', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontSize: 16))
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final payment = items[index];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.paddingSmall),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
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