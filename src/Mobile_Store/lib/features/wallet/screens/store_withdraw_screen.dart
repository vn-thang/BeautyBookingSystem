// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // THÊM IMPORT NÀY
// import 'package:mobile_store/features/store/screens/update_profile_screen.dart';
// import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
// import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
// import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
// import 'package:mobile_store/shared/widgets/inputs/app_text_field.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_dimens.dart';
// import '../../../core/theme/app_spacing.dart';
// import '../../../core/theme/app_text_styles.dart';
// import '../models/wallet_transaction_model.dart';
// import '../services/store_wallet_api.dart'; 
// import '../widgets/withdraw/withdraw_balance_card.dart';
// import '../widgets/withdraw/withdraw_input_section.dart';
// import '../widgets/withdraw/bank_info_section.dart';

// class StoreWithdrawScreen extends StatefulWidget {
//   final WalletDashboardModel dashboard; 

//   const StoreWithdrawScreen({super.key, required this.dashboard});

//   @override
//   State<StoreWithdrawScreen> createState() => _StoreWithdrawScreenState();
// }

// class _StoreWithdrawScreenState extends State<StoreWithdrawScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   String? _errorText;
//   bool _isLoadingSubmit = false; 

//   String? _bankName;
//   String? _accountNumber;
//   String? _accountName;

//   @override
//   void initState() {
//     super.initState();
//     _bankName = widget.dashboard.bankName;
//     _accountNumber = widget.dashboard.bankAccountNumber;
//     _accountName = widget.dashboard.bankAccountName;
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   void _handleWithdrawAll() {
//     setState(() {
//       _amountController.text = widget.dashboard.currentBalance.toInt().toString();
//       _errorText = null;
//     });
//   }

//   Future<void> _validateAndRequestOtp() async {
//     if (_bankName == null || _bankName!.isEmpty || _accountNumber == null || _accountNumber!.isEmpty) {
//       SnackBarHelper.showError(context, 'Vui lòng thiết lập tài khoản ngân hàng trước khi rút tiền!');
//       return;
//     }

//     final amountText = _amountController.text.trim();
//     if (amountText.isEmpty) {
//       setState(() => _errorText = 'Vui lòng nhập số tiền');
//       return;
//     }

//     final amount = double.tryParse(amountText);
//     if (amount == null || amount < 100000) {
//       setState(() => _errorText = 'Số tiền rút tối thiểu là 100.000đ');
//       return;
//     }

//     if (amount > widget.dashboard.currentBalance) {
//       setState(() => _errorText = 'Số dư ví không đủ');
//       return;
//     }

//     final phoneStr = widget.dashboard.ownerPhone; 

//     if (phoneStr == null || phoneStr.isEmpty) {
//       SnackBarHelper.showError(context, 'Tài khoản chưa có số điện thoại để nhận OTP.');
//       return;
//     }

//     setState(() {
//       _errorText = null;
//       _isLoadingSubmit = true;
//     });

//     await _verifyPhoneForWithdrawal(phoneStr, amount);
//   }

//   Future<void> _verifyPhoneForWithdrawal(String phoneStr, double amount) async {
//     try {
//       await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: phoneStr,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _processWithdrawal(credential, amount);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           setState(() => _isLoadingSubmit = false);
//           SnackBarHelper.showError(context, e.message ?? 'Gửi mã xác thực thất bại.');
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           setState(() => _isLoadingSubmit = false);
//           _showOtpDialogForWithdrawal(verificationId, phoneStr, amount);
//         },
//         codeAutoRetrievalTimeout: (_) {},
//       );
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoadingSubmit = false);
//       SnackBarHelper.showError(context, 'Lỗi hệ thống: $e');
//     }
//   }

//   void _showOtpDialogForWithdrawal(String verificationId, String phoneStr, double amount) {
//     final otpController = TextEditingController();
//     bool isVerifying = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               title: Text(
//                 'Xác thực giao dịch',
//                 style: AppTextStyles.heading1.copyWith(fontSize: 20, color: AppColors.textMain),
//                 textAlign: TextAlign.center,
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Để bảo mật, mã OTP đã được gửi đến số $phoneStr',
//                     style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   AppTextField(
//                     hint: 'Nhập mã OTP 6 số',
//                     icon: Icons.security_outlined,
//                     controller: otpController,
//                     keyboardType: TextInputType.number,
//                   ),
//                   const SizedBox(height: 20),
//                   AppPrimaryButton(
//                     text: 'XÁC NHẬN RÚT TIỀN',
//                     isLoading: isVerifying,
//                     onPressed: () async {
//                       final code = otpController.text.trim();
//                       if (code.isEmpty || code.length < 6) {
//                         SnackBarHelper.showError(ctx, 'Vui lòng nhập đủ 6 số OTP');
//                         return;
//                       }

//                       setDialogState(() => isVerifying = true);
//                       try {
//                         final credential = PhoneAuthProvider.credential(
//                           verificationId: verificationId,
//                           smsCode: code,
//                         );
                        
//                         Navigator.pop(ctx); 
//                         await _processWithdrawal(credential, amount); 
                        
//                       } catch (e) {
//                         setDialogState(() => isVerifying = false);
//                         if (ctx.mounted) {
//                         SnackBarHelper.showError(ctx, 'Mã OTP không hợp lệ hoặc đã hết hạn.');
//                         }
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextButton(
//                     onPressed: isVerifying ? null : () => Navigator.pop(ctx),
//                     child: const Text('Hủy bỏ', style: TextStyle(color: AppColors.textSub)),
//                   ),
//                 ],
//               ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _processWithdrawal(PhoneAuthCredential credential, double amount) async {
//     try {
//       setState(() => _isLoadingSubmit = true);

//       await FirebaseAuth.instance.signInWithCredential(credential);
//       final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);

//       if (idToken == null) throw Exception("Không lấy được mã xác thực an toàn.");

//       await StoreWalletApi.requestWithdraw(amount, idToken);
      
//       if (!mounted) return;
      
//       SnackBarHelper.showSuccess(context, 'Yêu cầu rút tiền đã được gửi! Đang chờ Admin duyệt.');
//       Navigator.pop(context, true); 
      
//     } catch (e) {
//       if (!mounted) return;
//       SnackBarHelper.showError(context, e.toString().replaceAll('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => _isLoadingSubmit = false);
//     }
//   }

//   Future<void> _navigateToSetupBank() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
//     );
//     if (mounted) {
//       Navigator.pop(context); 
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: const AppHeader(title: 'Rút tiền'),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(AppDimens.paddingLarge),
//               child: Column(
//                 children: [
//                   WithdrawBalanceCard(
//                     availableBalance: widget.dashboard.currentBalance,
//                   ),
//                   const SizedBox(height: AppSpacing.lg),
                  
//                   WithdrawInputSection(
//                     amountController: _amountController,
//                     onWithdrawAll: _handleWithdrawAll,
//                     errorText: _errorText,
//                   ),
//                   const SizedBox(height: AppSpacing.lg),
                  
//                   BankInfoSection(
//                     bankName: _bankName,
//                     accountNumber: _accountNumber,
//                     accountName: _accountName,
//                     onSetupPressed: _navigateToSetupBank,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(AppDimens.paddingLarge),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               boxShadow: [
//                 BoxShadow(color: AppColors.textMain.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
//               ],
//             ),
//             child: SafeArea(
//               child: AppPrimaryButton(
//                 text: 'YÊU CẦU RÚT TIỀN',
//                 isLoading: _isLoadingSubmit,
//                 onPressed: _validateAndRequestOtp, 
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_store/features/store/screens/update_profile_screen.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import 'package:mobile_store/shared/widgets/inputs/app_text_field.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../models/wallet_transaction_model.dart';
import '../services/store_wallet_api.dart';

import '../widgets/withdraw/withdraw_balance_card.dart';
import '../widgets/withdraw/withdraw_input_section.dart';
import '../widgets/withdraw/bank_info_section.dart';

class StoreWithdrawScreen extends StatefulWidget {
  final WalletDashboardModel dashboard;

  const StoreWithdrawScreen({
    super.key,
    required this.dashboard,
  });

  @override
  State<StoreWithdrawScreen> createState() =>
      _StoreWithdrawScreenState();
}

class _StoreWithdrawScreenState
    extends State<StoreWithdrawScreen> {
  final TextEditingController _amountController =
      TextEditingController();

  String? _errorText;
  bool _isLoadingSubmit = false;

  String? _bankName;
  String? _accountNumber;
  String? _accountName;

  // Giữ lại tối thiểu 500k
  static const double _minimumRemainingBalance = 500000;

  double get _maxWithdrawable {
    final remain =
        widget.dashboard.currentBalance -
            _minimumRemainingBalance;

    return remain > 0 ? remain : 0;
  }

  @override
  void initState() {
    super.initState();

    _bankName = widget.dashboard.bankName;
    _accountNumber =
        widget.dashboard.bankAccountNumber;
    _accountName =
        widget.dashboard.bankAccountName;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleWithdrawAll() {
    if (_maxWithdrawable <= 0) {
      SnackBarHelper.showError(
        context,
        'Ví cần duy trì tối thiểu 500.000đ',
      );
      return;
    }

    setState(() {
      _amountController.text =
          _maxWithdrawable.toInt().toString();

      _errorText = null;
    });
  }

  Future<void> _validateAndRequestOtp() async {
    if (_bankName == null ||
        _bankName!.isEmpty ||
        _accountNumber == null ||
        _accountNumber!.isEmpty) {
      SnackBarHelper.showError(
        context,
        'Vui lòng thiết lập tài khoản ngân hàng trước khi rút tiền!',
      );
      return;
    }

    final amountText =
        _amountController.text.trim();

    if (amountText.isEmpty) {
      setState(() {
        _errorText = 'Vui lòng nhập số tiền';
      });
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null || amount < 100000) {
      setState(() {
        _errorText =
            'Số tiền rút tối thiểu là 100.000đ';
      });
      return;
    }

    if (amount > _maxWithdrawable) {
      setState(() {
        _errorText =
            'Bạn cần giữ lại tối thiểu 500.000đ trong ví';
      });
      return;
    }

    final phoneStr =
        widget.dashboard.ownerPhone;

    if (phoneStr == null ||
        phoneStr.isEmpty) {
      SnackBarHelper.showError(
        context,
        'Tài khoản chưa có số điện thoại để nhận OTP.',
      );
      return;
    }

    setState(() {
      _errorText = null;
      _isLoadingSubmit = true;
    });

    await _verifyPhoneForWithdrawal(
      phoneStr,
      amount,
    );
  }

  Future<void> _verifyPhoneForWithdrawal(
    String phoneStr,
    double amount,
  ) async {
    try {
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneStr,

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          await _processWithdrawal(
            credential,
            amount,
          );
        },

        verificationFailed:
            (FirebaseAuthException e) {
          setState(() {
            _isLoadingSubmit = false;
          });

          SnackBarHelper.showError(
            context,
            e.message ??
                'Gửi mã xác thực thất bại.',
          );
        },

        codeSent:
            (String verificationId,
                int? resendToken) {
          setState(() {
            _isLoadingSubmit = false;
          });

          _showOtpDialogForWithdrawal(
            verificationId,
            phoneStr,
            amount,
          );
        },

        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSubmit = false;
      });

      SnackBarHelper.showError(
        context,
        'Lỗi hệ thống: $e',
      );
    }
  }

  void _showOtpDialogForWithdrawal(
    String verificationId,
    String phoneStr,
    double amount,
  ) {
    final otpController =
        TextEditingController();

    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              title: Text(
                'Xác thực giao dịch',
                style:
                    AppTextStyles.heading1.copyWith(
                  fontSize: 20,
                  color: AppColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Để bảo mật, mã OTP đã được gửi đến số $phoneStr',
                      style: AppTextStyles.bodyText
                          .copyWith(
                        color: AppColors.textSub,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      hint: 'Nhập mã OTP 6 số',
                      icon:
                          Icons.security_outlined,
                      controller:
                          otpController,
                      keyboardType:
                          TextInputType.number,
                    ),

                    const SizedBox(height: 20),

                    AppPrimaryButton(
                      text:
                          'XÁC NHẬN RÚT TIỀN',
                      isLoading:
                          isVerifying,

                      onPressed: () async {
                        final code =
                            otpController.text
                                .trim();

                        if (code.isEmpty ||
                            code.length < 6) {
                          SnackBarHelper
                              .showError(
                            ctx,
                            'Vui lòng nhập đủ 6 số OTP',
                          );
                          return;
                        }

                        setDialogState(() {
                          isVerifying = true;
                        });

                        try {
                          final credential =
                              PhoneAuthProvider
                                  .credential(
                            verificationId:
                                verificationId,
                            smsCode: code,
                          );

                          Navigator.pop(ctx);

                          await _processWithdrawal(
                            credential,
                            amount,
                          );
                        } catch (e) {
                          setDialogState(() {
                            isVerifying = false;
                          });

                          if (ctx.mounted) {
                            SnackBarHelper
                                .showError(
                              ctx,
                              'Mã OTP không hợp lệ hoặc đã hết hạn.',
                            );
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed:
                          isVerifying
                              ? null
                              : () =>
                                  Navigator.pop(
                                    ctx,
                                  ),
                      child: const Text(
                        'Hủy bỏ',
                        style: TextStyle(
                          color:
                              AppColors.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _processWithdrawal(
    PhoneAuthCredential credential,
    double amount,
  ) async {
    try {
      setState(() {
        _isLoadingSubmit = true;
      });

      await FirebaseAuth.instance
          .signInWithCredential(
        credential,
      );

      final idToken =
          await FirebaseAuth.instance
              .currentUser
              ?.getIdToken(true);

      if (idToken == null) {
        throw Exception(
          "Không lấy được mã xác thực an toàn.",
        );
      }

      await StoreWalletApi.requestWithdraw(
        amount,
        idToken,
      );

      if (!mounted) return;

      SnackBarHelper.showSuccess(
        context,
        'Yêu cầu rút tiền đã được gửi! '
        'Hệ thống sẽ xử lý vào ngày 01-02 và 15-16 hàng tháng.',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      SnackBarHelper.showError(
        context,
        e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSubmit = false;
        });
      }
    }
  }

  Future<void> _navigateToSetupBank() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                const UpdateProfileScreen(),
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar:
          const AppHeader(
            title: 'Rút tiền',
          ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimens.paddingLarge,
              ),

              child: Column(
                children: [

                  // THÔNG BÁO
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color:
                          Colors.orange.shade50,

                      borderRadius:
                          BorderRadius.circular(
                            12,
                          ),

                      border: Border.all(
                        color:
                            Colors.orange.shade200,
                      ),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule,
                          color:
                              Colors.orange.shade700,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Hệ thống sẽ xử lý yêu cầu rút tiền vào ngày 01-02 và 15-16 hàng tháng.\n\n'
                            'Ví cần duy trì tối thiểu 500.000đ để đảm bảo đối soát và hoàn tiền.',

                            style: TextStyle(
                              color:
                                  Colors.orange
                                      .shade800,
                              fontWeight:
                                  FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  WithdrawBalanceCard(
                    availableBalance:
                        widget.dashboard
                            .currentBalance,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  WithdrawInputSection(
                    amountController:
                        _amountController,

                    onWithdrawAll:
                        _handleWithdrawAll,

                    errorText:
                        _errorText,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  BankInfoSection(
                    bankName:
                        _bankName,

                    accountNumber:
                        _accountNumber,

                    accountName:
                        _accountName,

                    onSetupPressed:
                        _navigateToSetupBank,
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(
              AppDimens.paddingLarge,
            ),

            decoration: BoxDecoration(
              color: AppColors.white,

              boxShadow: [
                BoxShadow(
                  color: AppColors.textMain
                      .withValues(alpha: 0.05),

                  blurRadius: 10,

                  offset: const Offset(
                    0,
                    -5,
                  ),
                )
              ],
            ),

            child: SafeArea(
              child: AppPrimaryButton(
                text:
                    'YÊU CẦU RÚT TIỀN',

                isLoading:
                    _isLoadingSubmit,

                onPressed:
                    _validateAndRequestOtp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}