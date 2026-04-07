import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/inputs/app_text_field.dart'; 
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
  bool _isSubmitting = false; 

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
    if (isError) {
      SnackBarHelper.showError(context, msg);
    } else {
      SnackBarHelper.showSuccess(context, msg);
    }
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            onSurface: AppColors.textMain,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDate! : _endDate!),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
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

    setState(() => _isSubmitting = true);

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
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildDatePickerTile(String title, DateTime date, bool isStart) {
    return Expanded(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: AppTextStyles.labelSmall),
        subtitle: Text(
          Formatters.formatDateTime(date), 
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold, 
            color: (isEdit && isStart) ? AppColors.textSub : AppColors.textMain
          )
        ),
        onTap: () => _pickDateTime(isStart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.91, 
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
          left: AppDimens.paddingLarge, 
          right: AppDimens.paddingLarge, 
          top: AppDimens.paddingLarge
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Text(isEdit ? 'Sửa Khuyến Mãi' : 'Tạo Khuyến Mãi', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
                const SizedBox(height: AppSpacing.lg),
                
                AbsorbPointer(
                  absorbing: isEdit, 
                  child: AppTextField(
                    controller: _codeCtrl, 
                    label: 'Mã Voucher', 
                    hint: 'VD: TET2026', 
                    icon: Icons.local_offer_outlined,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                if (!isEdit) ...[
                  Text('Loại giảm', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.surface, width: 1.5),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _discountType,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSub),
                        items: [
                          DropdownMenuItem(value: 0, child: Text('Giảm theo số tiền (VNĐ)', style: AppTextStyles.bodyText)),
                          DropdownMenuItem(value: 1, child: Text('Giảm theo Phần trăm (%)', style: AppTextStyles.bodyText)),
                        ],
                        onChanged: (val) => setState(() => _discountType = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _discountValueCtrl, 
                          label: 'Mức giảm', 
                          hint: 'Nhập số...', 
                          icon: Icons.money_off_csred_outlined, 
                          keyboardType: TextInputType.number
                        )
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          controller: _maxDiscountCtrl, 
                          label: 'Giảm tối đa', 
                          hint: '(VNĐ)', 
                          icon: Icons.price_check_outlined, 
                          keyboardType: TextInputType.number
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  AppTextField(
                    controller: _minOrderCtrl, 
                    label: 'Đơn tối thiểu (VNĐ)', 
                    hint: 'Bắt buộc...', 
                    icon: Icons.shopping_cart_checkout_outlined, 
                    keyboardType: TextInputType.number
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                AppTextField(
                  controller: _usageLimitCtrl, 
                  label: 'Số lượng phát hành', 
                  hint: 'Nhập số lượng...', 
                  icon: Icons.numbers_outlined, 
                  keyboardType: TextInputType.number
                ),
                const SizedBox(height: AppSpacing.sm),

                Row(
                  children: [
                    _buildDatePickerTile('Bắt đầu từ', _startDate!, true),
                    _buildDatePickerTile('Kết thúc vào', _endDate!, false),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                AppPrimaryButton(
                  text: 'LƯU VOUCHER',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppDimens.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}