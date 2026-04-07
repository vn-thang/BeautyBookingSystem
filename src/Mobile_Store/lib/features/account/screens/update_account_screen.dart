import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../services/account_service.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/locked_text_field.dart'; 
import '../../../shared/widgets/inputs/app_image_picker.dart';   
import '../../../shared/widgets/feedback/app_error_box.dart';

class AccountUpdateProfileScreen extends StatefulWidget {
  const AccountUpdateProfileScreen({super.key});

  @override
  State<AccountUpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<AccountUpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); 
  final _phoneCtrl = TextEditingController(); 
  
  bool _isFetching = true; 
  bool _isUpdating = false; 
  String? _errorMessage;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await AccountService.getProfile();
    
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final user = result.data!;
      setState(() {
        _fullNameCtrl.text = user.fullName;
        _emailCtrl.text = user.email ?? 'Chưa cập nhật';
        _phoneCtrl.text = user.phone;
        _avatarUrl = user.avatarUrl;
        _isFetching = false; 
      });
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Không thể tải thông tin';
        _isFetching = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    final result = await AccountService.updateProfile(
      fullName: _fullNameCtrl.text.trim(),
      avatarUrl: _avatarUrl,
    );

    if (!mounted) return;
    setState(() => _isUpdating = false);

    if (result.isSuccess) {
      SnackBarHelper.showSuccess(context, 'Cập nhật thành công!');
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: const AppHeader(title: 'Tài khoản của tôi'),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: AppImagePicker(
                        folderName: 'avatars',
                        isCircle: true,        
                        width: 120,            
                        height: 120,
                        initialImageUrl: _avatarUrl,
                        onImageUploaded: (url) {
                          setState(() {
                            _avatarUrl = url;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_errorMessage != null) ...[
                      AppErrorBox(errorMessage: _errorMessage!),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    AppTextField(
                      label: 'Họ và Tên (*)',
                      hint: 'Nhập họ và tên',
                      icon: Icons.person_outline,
                      controller: _fullNameCtrl,
                      validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập họ tên'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    LockedTextField(
                      label: 'Số điện thoại',
                      controller: _phoneCtrl, 
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    LockedTextField(
                      label: 'Email',
                      controller: _emailCtrl, 
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 30),

                    AppPrimaryButton(
                      text: 'LƯU THAY ĐỔI',
                      isLoading: _isUpdating,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}