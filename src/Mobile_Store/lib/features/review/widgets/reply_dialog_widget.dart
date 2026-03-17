import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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
      title: const Text('Phản hồi đánh giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: 'Nhập nội dung trả lời...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 2), 
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) return;
            Navigator.pop(context, _controller.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, 
            foregroundColor: Colors.white, 
          ),
          child: const Text('Gửi'),
        ),
      ],
    );
  }
}