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
    {'label': 'Tất cả loại', 'value': null},
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 130, 
                  child: AppFilterDropdown<int?>(
                    hint: 'Tháng',
                    value: selectedMonth, 
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Tất cả tháng')),
                      ...List.generate(12, (index) => DropdownMenuItem<int?>(
                            value: index + 1, 
                            child: Text('Tháng ${index + 1}')
                          )),
                    ],
                    onChanged: (val) {
                      onFilterChanged(val, selectedYear, selectedType);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                SizedBox(
                  width: 120,
                  child: AppFilterDropdown<int?>(
                    hint: 'Năm',
                    value: selectedYear, 
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Tất cả năm')),
                      ..._generateYears().map((year) {
                        return DropdownMenuItem<int?>(
                          value: year, 
                          child: Text('Năm $year')
                        );
                      }),
                    ],
                    onChanged: (val) {
                      onFilterChanged(selectedMonth, val, selectedType);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                SizedBox(
                  width: 140,
                  child: AppFilterDropdown<int?>(
                    hint: 'Loại GD',
                    value: selectedType, 
                    items: _transactionTypes.map((type) {
                      return DropdownMenuItem<int?>(
                        value: type['value'] as int?, 
                        child: Text(type['label'] as String)
                      );
                    }).toList(),
                    onChanged: (val) {
                      onFilterChanged(selectedMonth, selectedYear, val);
                    },
                  ),
                ),
              ],
            ),
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
                
                Color txColor;
                IconData txIcon;
                
                if (isPending) {
                  txColor = AppColors.warning;
                  txIcon = Icons.access_time_filled;
                } else if (isFailed) {
                  txColor = AppColors.error;
                  txIcon = Icons.cancel;
                } else {
                  txColor = AppColors.success;
                  txIcon = tx.isAddition ? Icons.arrow_downward : Icons.arrow_upward; 
                }

                final isAdd = tx.isAddition;
                final sign = isAdd ? '+' : '-'; 

                String cleanDescription = tx.description.replaceAll(RegExp(r'\[Biên lai:.*?\]'), '').trim();

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), 
                  onTap: () => onTransactionTap(tx), 
                  leading: CircleAvatar(
                    backgroundColor: txColor.withValues(alpha: 0.1),
                    child: Icon(txIcon, color: txColor, size: 20),
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
                      const SizedBox(height: 2),
                      Text(
                        tx.createdAt != null ? '${tx.createdAt!.day}/${tx.createdAt!.month}/${tx.createdAt!.year} ${tx.createdAt!.hour}:${tx.createdAt!.minute.toString().padLeft(2, '0')} • Số dư: ${Formatters.formatCurrency(tx.balanceAfter)}' : '',
                        style: AppTextStyles.labelSmall,
                      ),
                      _buildStatusBadge(tx.status),
                    ],
                  ),
                  trailing: Text(
                    '$sign${Formatters.formatCurrency(tx.amount.abs())}',
                    style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 15, color: txColor),
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