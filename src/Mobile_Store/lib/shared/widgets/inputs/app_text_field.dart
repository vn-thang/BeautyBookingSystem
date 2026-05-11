import 'package:flutter/material.dart';
import 'package:mobile_store/core/theme/app_dimens.dart';
import 'package:mobile_store/core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final String? label; 
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator; 
  final bool isPassword;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final int maxLines; 

  const AppTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.label,
    this.isPassword = false,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscurePassword = true;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!, 
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.w700, 
              color: AppColors.textMain,
              fontSize: 14
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Đã xóa AnimatedContainer và dùng trực tiếp TextFormField
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isPassword ? _obscurePassword : false,
          validator: widget.validator,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w500, 
          ),
          cursorColor: AppColors.primary, 
          
          decoration: InputDecoration(
            isDense: true,
            // 1. Cho phép tô màu nền trực tiếp trong TextFormField
            filled: true,
            fillColor: _isFocused ? AppColors.white : const Color(0xFFF3F4F6),
            
            // 2. Viền lúc bình thường (chưa gõ)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            
            // 3. Viền lúc ĐANG GÕ (hiện viền màu primary)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            
            // 4. Viền lúc CÓ LỖI (hiện viền màu đỏ)
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            
            // 5. Viền lúc CÓ LỖI VÀ ĐANG GÕ
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            
            prefixIcon: Icon(
              widget.icon, 
              size: 20, 
              color: _isFocused ? AppColors.primary : AppColors.textSub 
            ),
            
            hintText: widget.hint,
            hintStyle: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSub.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400
            ),
            // Padding bên trong ô nhập, chỉnh rộng ra 1 chút cho đẹp
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            
            // 🎯 QUAN TRỌNG: Xóa height: 0.1 đi để chữ lỗi rớt thẳng xuống dưới
            errorStyle: AppTextStyles.labelSmall.copyWith(
              color: AppColors.error, 
              fontWeight: FontWeight.w500,
              height: 1.2, // Tăng khoảng cách dòng
            ),
            
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20, 
                      color: _isFocused ? AppColors.primary : AppColors.textSub,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
                errorMaxLines: 3,
          ),
        ),
      ],
    );
  }
}