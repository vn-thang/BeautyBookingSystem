import 'package:flutter/material.dart';
import 'package:mobile_store/shared/models/bank_model.dart';
import 'package:mobile_store/shared/widgets/bank_selection_bottom_sheet.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StorePaymentSection extends StatelessWidget {
  final TextEditingController bankNameController;
  final TextEditingController bankAccountNumberController;
  final TextEditingController bankAccountNameController;
  final Color primaryColor; 

  const StorePaymentSection({
    super.key,
    required this.bankNameController,
    required this.bankAccountNumberController,
    required this.bankAccountNameController,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Thông tin thanh toán & rút tiền", 
          style: AppTextStyles.bodyText.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        GestureDetector(
          onTap: () async {
            final BankModel? selectedBank = await BankSelectionBottomSheet.show(context);
            if (selectedBank != null) {
              bankNameController.text = selectedBank.shortName;
            }
          },
          child: AbsorbPointer( 
            child: AppTextField(
              controller: bankNameController,
              hint: "Tên ngân hàng (Nhấn để chọn)",
              icon: Icons.account_balance_outlined,
            ),
          ),
        ),
        const SizedBox(height: 16), 
        
        AppTextField(
          controller: bankAccountNumberController,
          icon: Icons.numbers_outlined,
          hint: "Số tài khoản",
          keyboardType: TextInputType.phone, 
        ),
        const SizedBox(height: 16),
        
        AppTextField(
          controller: bankAccountNameController,
          icon: Icons.person_outline,
          hint: "Tên chủ tài khoản (In hoa không dấu)",
        ),
        
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            "* Lưu ý: Vui lòng điền đầy đủ cả 3 thông tin trên để có thể tạo lệnh rút tiền về ngân hàng.",
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}