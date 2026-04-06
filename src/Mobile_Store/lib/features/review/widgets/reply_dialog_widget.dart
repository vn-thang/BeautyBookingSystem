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
      title: Text('Phản hồi đánh giá', style: AppTextStyles.heading1.copyWith(fontSize: 18)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: 500,
        style: AppTextStyles.bodyText,
        decoration: InputDecoration(
          hintText: 'Nhập nội dung trả lời...',
          hintStyle: AppTextStyles.labelSmall,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            borderSide: const BorderSide(color: AppColors.textSub, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5), 
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          width: 100,
          height: 40,
          child: AppPrimaryButton(
            text: 'GỬI',
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;
              Navigator.pop(context, _controller.text.trim());
            },
          ),
        ),
      ],
    );
  }
}