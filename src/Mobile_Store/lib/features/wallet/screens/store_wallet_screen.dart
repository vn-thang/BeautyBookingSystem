import 'package:flutter/material.dart';
import 'package:mobile_store/features/wallet/screens/store_withdraw_screen.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart'; 
import 'dart:async'; 
import '../../../core/theme/app_colors.dart';
import '../models/wallet_transaction_model.dart';
import '../services/store_wallet_api.dart';
import '../widgets/topup_dialog.dart';
import '../widgets/wallet_warning_banner.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_transaction_history.dart';
import '../widgets/transaction_receipt_sheet.dart'; 

class StoreWalletScreen extends StatefulWidget {
  const StoreWalletScreen({super.key});

  @override
  State<StoreWalletScreen> createState() => _StoreWalletScreenState();
}

class _StoreWalletScreenState extends State<StoreWalletScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  WalletBalanceModel? _walletInfo;
  WalletDashboardModel? _dashboardInfo; 
  List<WalletTransactionModel> _transactions = [];

  int? _currentMonth;
  int? _currentYear;
  int? _currentType;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinkListener();
    _fetchWalletData();
  }

  void _initDeepLinkListener() {
    _appLinks = AppLinks();
    
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        if (uri.scheme == 'beautybooking' && uri.host == 'payment-result') {
          final isSuccess = uri.queryParameters['success'] == 'true';
          
          if (isSuccess) {
            final amount = uri.queryParameters['amount'] ?? '';
            _showSnackBar('Nạp thành công $amount VNĐ!');
            _fetchWalletData(); 
          } else {
            final message = uri.queryParameters['message'] ?? 'Giao dịch thất bại';
            _showSnackBar('❌ $message', isError: true);
          }
        }
      }
    }, onError: (err) {
      debugPrint("Lỗi Deep Link: $err");
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel(); 
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchWalletData();
    }
  }

  Future<void> _fetchWalletData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        StoreWalletApi.getBalance(),
        StoreWalletApi.getDashboard(month: _currentMonth, year: _currentYear),
        StoreWalletApi.getTransactions(month: _currentMonth, year: _currentYear, type: _currentType),
      ]);
      
      if (!mounted) return;

      setState(() {
        _walletInfo = results[0] as WalletBalanceModel;
        _dashboardInfo = results[1] as WalletDashboardModel;
        _transactions = results[2] as List<WalletTransactionModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _onFilterChanged(int? month, int? year, int? type) {
    setState(() {
      _currentMonth = month;
      _currentYear = year;
      _currentType = type;
    });
    _fetchWalletData();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      SnackBarHelper.showError(context, message);
    } else {
      SnackBarHelper.showSuccess(context, message);
    }
  }

  Future<void> _processTopUp() async {
    final amount = await WalletDialogs.showTopUpDialog(context);
    
    if (!mounted) return;

    if (amount != null && amount >= 10000) { 
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );

        final paymentUrl = await StoreWalletApi.requestTopUp(amount);
        
        if (!mounted) return;
        Navigator.pop(context); 

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          final Uri url = Uri.parse(paymentUrl);
          
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            if (!mounted) return; 
            _showSnackBar('Không thể mở cổng thanh toán VNPay', isError: true);
          }
        } else {
          _showSnackBar('Lấy link thanh toán thất bại.', isError: true);
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  Future<void> _processWithdraw() async {
    if (_dashboardInfo == null) {
      _showSnackBar('Đang tải thông tin ví, vui lòng đợi...', isError: true);
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreWithdrawScreen(
          dashboard: _dashboardInfo!, 
        ),
      ),
    );

    if (result == true) {
      _fetchWalletData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Ví hệ thống & Hoa hồng'),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchWalletData,
        child: _isLoading || _walletInfo == null || _dashboardInfo == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (_walletInfo!.isLockedByDebt) 
                      WalletWarningBanner(minimumBalance: _walletInfo!.minimumBalance),
                    
                    WalletBalanceCard(
                      dashboard: _dashboardInfo!, 
                      onTopUpPressed: _processTopUp,
                      onWithdrawPressed: _processWithdraw, 
                    ),
                    
                    WalletTransactionHistory(
                      transactions: _transactions,
                      onFilterChanged: _onFilterChanged,
                      onTransactionTap: (tx) => TransactionReceiptSheet.show(context, tx),
                      selectedMonth: _currentMonth,
                      selectedYear: _currentYear,
                      selectedType: _currentType,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}