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

        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isFocused ? AppColors.white : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(
              color: _isFocused ? AppColors.primary : Colors.transparent, 
              width: 1.5,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: TextFormField(
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
              border: InputBorder.none, 
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              
              prefixIcon: Icon(
                widget.icon, 
                size: 22, 
                color: _isFocused ? AppColors.primary : AppColors.textSub 
              ),
              
              hintText: widget.hint,
              hintStyle: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSub.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              
              errorStyle: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error, 
                height: 0.1 
              ),
              
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 22, 
                        color: _isFocused ? AppColors.primary : AppColors.textSub,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}