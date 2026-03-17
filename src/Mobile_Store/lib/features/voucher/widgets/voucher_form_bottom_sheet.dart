import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voucher_model.dart';
import '../services/voucher_api.dart';

class VoucherFormBottomSheet extends StatefulWidget {
  final VoucherModel? voucher;
  final VoidCallback onSuccess;

  const VoucherFormBottomSheet({super.key, this.voucher, required this.onSuccess});

  @override
  State<VoucherFormBottomSheet> createState() => _VoucherFormBottomSheetState();
}

class _VoucherFormBottomSheetState extends State<VoucherFormBottomSheet> {
  final _codeCtrl = TextEditingController();
  final _discountValueCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _maxDiscountCtrl = TextEditingController();
  final _usageLimitCtrl = TextEditingController();
  
  int _discountType = 0; 
  DateTime? _startDate;
  DateTime? _endDate;
  final Color primaryColor = const Color(0xFFDE4660);

  bool get isEdit => widget.voucher != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final v = widget.voucher!;
      _codeCtrl.text = v.code;
      _discountType = v.discountType;
      _discountValueCtrl.text = v.discountValue.toStringAsFixed(0);
      _minOrderCtrl.text = v.minOrderValue.toStringAsFixed(0);
      _maxDiscountCtrl.text = v.maxDiscount.toStringAsFixed(0);
      _usageLimitCtrl.text = v.usageLimit.toString();
      _startDate = v.startDate;
      _endDate = v.endDate;
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _discountValueCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green)
    );
  }

  double _parseDouble(String value) => double.tryParse(value.trim()) ?? 0.0;
  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  Future<void> _pickDateTime(bool isStart) async {
    if (isEdit && isStart) {
      _showMessage('Không thể sửa thời gian bắt đầu khi cập nhật!', isError: true);
      return; 
    }

    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate! : _endDate!,
      firstDate: isEdit ? _endDate! : DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDate! : _endDate!),
    );
    if (time == null) return;

    setState(() {
      final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _submit() async {
    if (_codeCtrl.text.trim().isEmpty || _usageLimitCtrl.text.trim().isEmpty) {
      return _showMessage('Vui lòng điền mã khuyến mãi và số lượng!', isError: true);
    }
    if (!isEdit && _discountValueCtrl.text.trim().isEmpty) {
      return _showMessage('Vui lòng nhập mức giảm giá!', isError: true);
    }
    if (!_endDate!.isAfter(_startDate!)) {
      return _showMessage('Thời gian kết thúc phải lớn hơn thời gian bắt đầu!', isError: true);
    }

    try {
      if (isEdit) {
        await VoucherApi.updateVoucher(
          id: widget.voucher!.id,
          endDate: _endDate!,
          usageLimit: _parseInt(_usageLimitCtrl.text),
        );
      } else {
        await VoucherApi.createVoucher(
          code: _codeCtrl.text.trim(),
          serviceId: null, 
          discountType: _discountType,
          discountValue: _parseDouble(_discountValueCtrl.text),
          minOrderValue: _parseDouble(_minOrderCtrl.text),
          maxDiscount: _parseDouble(_maxDiscountCtrl.text),
          startDate: _startDate!,
          endDate: _endDate!,
          usageLimit: _parseInt(_usageLimitCtrl.text),
        );
      }

      if (!mounted) return;
      widget.onSuccess(); 
      Navigator.pop(context); 
      _showMessage(isEdit ? 'Cập nhật thành công!' : 'Tạo mới thành công!');
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool enabled = true, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDatePickerTile(String title, DateTime date, bool isStart) {
    return Expanded(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(date), 
          style: TextStyle(fontWeight: FontWeight.bold, color: (isEdit && isStart) ? Colors.grey : Colors.black)
        ),
        onTap: () => _pickDateTime(isStart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, 
        left: 24, right: 24, top: 24
      ),
      child: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Sửa Khuyến Mãi' : 'Tạo Khuyến Mãi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            _buildTextField(controller: _codeCtrl, label: 'Mã Voucher (VD: TET2026)', enabled: !isEdit),
            
            if (!isEdit) ...[
              DropdownButtonFormField<int>(
                initialValue: _discountType,
                decoration: InputDecoration(labelText: 'Loại giảm', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Giảm theo số tiền (VNĐ)')),
                  DropdownMenuItem(value: 1, child: Text('Giảm theo Phần trăm (%)')),
                ],
                onChanged: (val) => setState(() => _discountType = val!),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _discountValueCtrl, label: 'Mức giảm', type: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(controller: _maxDiscountCtrl, label: 'Giảm tối đa (VNĐ)', type: TextInputType.number)),
                ],
              ),
              
              _buildTextField(controller: _minOrderCtrl, label: 'Đơn tối thiểu (VNĐ)', type: TextInputType.number),
            ],

            _buildTextField(controller: _usageLimitCtrl, label: 'Số lượng phát hành', type: TextInputType.number),

            Row(
              children: [
                _buildDatePickerTile('Bắt đầu', _startDate!, true),
                _buildDatePickerTile('Kết thúc', _endDate!, false),
              ],
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text('LƯU VOUCHER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}