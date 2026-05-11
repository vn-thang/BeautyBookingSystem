import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class ReplyDialogWidget extends StatefulWidget {
  final String? initialReply;

  const ReplyDialogWidget({super.key, this.initialReply});

  @override
  State<ReplyDialogWidget> createState() => _ReplyDialogWidgetState();
}

class _ReplyDialogWidgetState extends State<ReplyDialogWidget> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialReply ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
      
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(24),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phản hồi đánh giá', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            'Khách hàng sẽ nhận được thông báo khi bạn trả lời.', 
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, 
        child: TextField(
          controller: _controller,
          maxLines: 4,
          maxLength: 500,
          style: AppTextStyles.bodyText,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung trả lời...',
            hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub.withValues(alpha: 0.7)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA), 
            contentPadding: const EdgeInsets.all(16), 
            
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1), 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5), 
            ),
          ),
        ),
      ),
      
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                  backgroundColor: AppColors.surface, 
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('HỦY', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: AppPrimaryButton(
                  text: 'GỬI',
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) {
                      
                      return;
                    }
                    Navigator.pop(context, _controller.text.trim());
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}