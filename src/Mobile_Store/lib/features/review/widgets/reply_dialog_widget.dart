import 'package:flutter/material.dart';

class ReplyDialogWidget extends StatefulWidget {
  final String? initialReply;

  const ReplyDialogWidget({super.key, this.initialReply});

  @override
  State<ReplyDialogWidget> createState() => _ReplyDialogWidgetState();
}

class _ReplyDialogWidgetState extends State<ReplyDialogWidget> {
  late TextEditingController _controller;
  final Color primaryRed = const Color(0xFFDE4A62);

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
            borderSide: BorderSide(color: primaryRed, width: 2), // Viền đỏ khi đang gõ
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
            backgroundColor: primaryRed, // Nền nút màu đỏ
            foregroundColor: Colors.white, // Chữ màu trắng
          ),
          child: const Text('Gửi'),
        ),
      ],
    );
  }
}