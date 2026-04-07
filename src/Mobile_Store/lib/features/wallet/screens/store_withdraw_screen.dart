import 'package:flutter/material.dart';
import 'package:mobile_store/features/store/screens/update_profile_screen.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';

import '../models/wallet_transaction_model.dart';
import '../services/store_wallet_api.dart'; 
import '../widgets/withdraw/withdraw_balance_card.dart';
import '../widgets/withdraw/withdraw_input_section.dart';
import '../widgets/withdraw/bank_info_section.dart';

class StoreWithdrawScreen extends StatefulWidget {
  final WalletDashboardModel dashboard; 

  const StoreWithdrawScreen({super.key, required this.dashboard});

  @override
  State<StoreWithdrawScreen> createState() => _StoreWithdrawScreenState();
}

class _StoreWithdrawScreenState extends State<StoreWithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _errorText;
  bool _isLoadingSubmit = false; 

  String? _bankName;
  String? _accountNumber;
  String? _accountName;

  @override
  void initState() {
    super.initState();
    _bankName = widget.dashboard.bankName;
    _accountNumber = widget.dashboard.bankAccountNumber;
    _accountName = widget.dashboard.bankAccountName;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleWithdrawAll() {
    setState(() {
      _amountController.text = widget.dashboard.currentBalance.toInt().toString();
      _errorText = null;
    });
  }

  Future<void> _validateAndSubmit() async {
    if (_bankName == null || _bankName!.isEmpty || _accountNumber == null || _accountNumber!.isEmpty) {
      SnackBarHelper.showError(context, 'Vui lòng thiết lập tài khoản ngân hàng trước khi rút tiền!');
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _errorText = 'Vui lòng nhập số tiền');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 100000) {
      setState(() => _errorText = 'Số tiền rút tối thiểu là 100.000đ');
      return;
    }

    if (amount > widget.dashboard.currentBalance) {
      setState(() => _errorText = 'Số dư ví không đủ');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoadingSubmit = true;
    });

    try {
      await StoreWalletApi.requestWithdraw(amount);
      
      if (!mounted) return;
      setState(() => _isLoadingSubmit = false);
      
      SnackBarHelper.showSuccess(context, 'Tạo lệnh rút tiền thành công! Đang chờ duyệt.');
      
      Navigator.pop(context, true); 
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSubmit = false);
      SnackBarHelper.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

 Future<void> _navigateToSetupBank() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
    );
    if (mounted) {
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Rút tiền'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Column(
                children: [
                  WithdrawBalanceCard(
                    availableBalance: widget.dashboard.currentBalance,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  WithdrawInputSection(
                    amountController: _amountController,
                    onWithdrawAll: _handleWithdrawAll,
                    errorText: _errorText,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  BankInfoSection(
                    bankName: _bankName,
                    accountNumber: _accountNumber,
                    accountName: _accountName,
                    onSetupPressed: _navigateToSetupBank,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(color: AppColors.textMain.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: AppPrimaryButton(
                text: 'XÁC NHẬN RÚT TIỀN',
                isLoading: _isLoadingSubmit,
                onPressed: _validateAndSubmit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}