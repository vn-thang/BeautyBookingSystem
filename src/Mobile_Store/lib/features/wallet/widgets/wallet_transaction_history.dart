import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_filter_dropdown.dart';
import '../models/wallet_transaction_model.dart';

class WalletTransactionHistory extends StatelessWidget {
  final List<WalletTransactionModel> transactions;
  final Function(int? month, int? year, int? type) onFilterChanged;
  final Function(WalletTransactionModel tx) onTransactionTap; 
  
  final int? selectedMonth;
  final int? selectedYear;
  final int? selectedType;

  const WalletTransactionHistory({
    super.key, 
    required this.transactions,
    required this.onFilterChanged,
    required this.onTransactionTap, 
    this.selectedMonth,
    this.selectedYear,
    this.selectedType,
  });

  final List<Map<String, dynamic>> _transactionTypes = const [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Nạp tiền', 'value': 1},
    {'label': 'Hoa hồng', 'value': 2},
    {'label': 'Phí duy trì', 'value': 3},
    {'label': 'Hoàn tiền', 'value': 4},    
    {'label': 'Rút tiền', 'value': 5},     
    {'label': 'Hoàn tiền rút', 'value': 6},
    {'label': 'Nhận tiền cọc', 'value': 7},
    {'label': 'Thu hồi cọc', 'value': 8}
  ];

  List<int> _generateYears() {
    int currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index); 
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    String normStatus = status.toLowerCase();

    if (normStatus == 'pending' || normStatus == '0') {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      text = 'Chờ duyệt';
    } else if (normStatus == 'failed' || normStatus == 'cancelled' || normStatus == '2' || normStatus == '3') {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
      text = 'Thất bại';
    } else {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      text = 'Thành công';
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lịch sử giao dịch', style: AppTextStyles.heading1.copyWith(fontSize: 18)),
              if (selectedMonth != null || selectedYear != null || selectedType != null)
                TextButton(
                  onPressed: () {
                    onFilterChanged(null, null, null);
                  },
                  child: Text('Xóa lọc', style: AppTextStyles.bodyText.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 🎯 Đã bỏ SingleChildScrollView ngang đi vì không cần thiết nữa
          Row(
              children: [
                // 🎯 1. Bọc Expanded cho Dropdown Tháng
                Expanded(
                  child: AppFilterDropdown<int?>(
                    hint: 'Tháng',
                    value: selectedMonth, 
                    
                    // 🎯 GIAO DIỆN HIỂN THỊ TRÊN NÚT (CĂN CHỈNH ĐẸP MẮT)
                    selectedItemBuilder: (BuildContext context) {
                      // Tạo danh sách nhãn giống hệt với items bên dưới
                      final labels = ['Tháng', ...List.generate(12, (index) => 'Tháng ${index + 1}')];
                      return labels.map((label) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList();
                    },

                    // 🎯 GIAO DIỆN KHI MENU XỔ XUỐNG
                    items: [
                      DropdownMenuItem<int?>(
                        value: null, 
                        child: Text('Tháng', style: AppTextStyles.bodyText)
                      ),
                      ...List.generate(12, (index) => DropdownMenuItem<int?>(
                            value: index + 1, 
                            child: Text('Tháng ${index + 1}', style: AppTextStyles.bodyText)
                          )),
                    ],
                    onChanged: (val) {
                      onFilterChanged(val, selectedYear, selectedType);
                    },
                  ),
                ),
                
                const SizedBox(width: AppSpacing.sm), // Giữ lại khoảng cách giữa các khối

                // 🎯 2. Bọc Expanded cho Dropdown Năm
                Expanded(
                  child: AppFilterDropdown<int?>(
                    hint: 'Năm',
                    value: selectedYear, 
                    
                    // 🎯 GIAO DIỆN HIỂN THỊ TRÊN NÚT (CĂN CHỈNH ĐẸP MẮT)
                    selectedItemBuilder: (BuildContext context) {
                      // Tạo danh sách nhãn năm
                      final labels = ['Năm', ..._generateYears().map((y) => 'Năm $y')];
                      return labels.map((label) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList();
                    },

                    // 🎯 GIAO DIỆN KHI MENU XỔ XUỐNG
                    items: [
                      DropdownMenuItem<int?>(
                        value: null, 
                        child: Text('Năm', style: AppTextStyles.bodyText)
                      ),
                      ..._generateYears().map((year) {
                        return DropdownMenuItem<int?>(
                          value: year, 
                          child: Text('Năm $year', style: AppTextStyles.bodyText)
                        );
                      }),
                    ],
                    onChanged: (val) {
                      onFilterChanged(selectedMonth, val, selectedType);
                    },
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),

Expanded(
  child: AppFilterDropdown<int?>(
    hint: 'Loại GD',
    value: selectedType,
    alignment: Alignment.centerRight, // 🎯 Neo vào mép phải
    menuWidth: 220, // 🎯 ÉP MENU RỘNG 220px (Nó sẽ tự tràn sang trái vì neo phải)

    selectedItemBuilder: (BuildContext context) {
      return _transactionTypes.map((type) {
        return Container(
          alignment: Alignment.centerLeft,
          child: Text(
            type['label'] as String,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        );
      }).toList();
    },

    items: _transactionTypes.map((type) {
      return DropdownMenuItem<int?>(
        value: type['value'] as int?, 
        child: Text(
          type['label'] as String,
          style: AppTextStyles.bodyText,
          maxLines: 1,
          // 🎯 Không cần SizedBox ở đây nữa, menuWidth đã lo rồi
        ),
      );
    }).toList(),
    onChanged: (val) => onFilterChanged(selectedMonth, selectedYear, val),
  ),
),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLarge * 2),
              child: Center(child: Text('Không tìm thấy giao dịch nào', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surface), // Đổi màu divider
             itemBuilder: (context, index) {
                final tx = transactions[index];
                
                final String normStatus = tx.status.toLowerCase();
                final bool isPending = normStatus == 'pending' || normStatus == '0';
                final bool isFailed = normStatus == 'failed' || normStatus == 'cancelled' || normStatus == '2' || normStatus == '3';
                
                final isAdd = tx.isAddition;
                final sign = isAdd ? '+' : '-'; 

                // 1. MÀU CỦA TRẠNG THÁI (Dành cho Icon bên trái)
                Color statusColor;
                IconData txIcon;
                
                if (isPending) {
                  statusColor = AppColors.warning;
                  txIcon = Icons.access_time_filled;
                } else if (isFailed) {
                  statusColor = AppColors.error;
                  txIcon = Icons.cancel;
                } else {
                 statusColor = isAdd ? AppColors.success : AppColors.error;
                  txIcon = isAdd ? Icons.arrow_downward : Icons.arrow_upward; 
                }

                // 2. MÀU CỦA SỐ TIỀN (+ Xanh, - Đỏ)
                Color amountColor = isAdd ? AppColors.success : AppColors.error;

                String cleanDescription = tx.description.replaceAll(RegExp(r'\[Biên lai:.*?\]'), '').trim();

               return ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), 
  onTap: () => onTransactionTap(tx), 
  leading: CircleAvatar(
    backgroundColor: statusColor.withValues(alpha: 0.1),
    child: Icon(txIcon, color: statusColor, size: 20),
  ),
  title: Text(
    cleanDescription, 
    style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600), 
    maxLines: 2, 
    overflow: TextOverflow.ellipsis
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 4), // Khoảng cách giữa title và subtitle
      
      // 1. Hiển thị ngày tháng chuẩn giờ VN
      if (tx.createdAt != null)
        Text(
          Formatters.formatDateTime(tx.createdAt), 
          style: AppTextStyles.labelSmall,
        ),
      
      const SizedBox(height: 2), // Khoảng cách nhỏ để dễ nhìn
      
      // 2. Đưa số dư xuống dòng dưới
      Text(
        'Số dư: ${Formatters.formatCurrency(tx.balanceAfter)}',
        style: AppTextStyles.labelSmall,
      ),
      
      const SizedBox(height: 4), // Khoảng cách trước badge
      _buildStatusBadge(tx.status),
    ],
  ),
  trailing: Text(
    '$sign${Formatters.formatCurrency(tx.amount.abs())}',
    style: AppTextStyles.bodyText.copyWith(
      fontWeight: FontWeight.bold, 
      fontSize: 15, 
      color: amountColor
    ),
  ),
);
              },
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}