import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BankInfoSection extends StatelessWidget {
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final VoidCallback onSetupPressed;

  const BankInfoSection({
    super.key,
    this.bankName,
    this.accountNumber,
    this.accountName,
    required this.onSetupPressed,
  });

  bool get hasBankInfo => bankName != null && bankName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chuyển tiền đến', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          
          if (!hasBankInfo) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_outlined, color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  const Text('Bạn chưa thiết lập tài khoản ngân hàng để nhận tiền.', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onSetupPressed,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, elevation: 0),
                    child: const Text('Thiết lập ngay'),
                  )
                ],
              ),
            )
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
                    child: const Icon(Icons.account_balance, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bankName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(accountNumber ?? '', style: TextStyle(fontSize: 14, color: Colors.grey.shade700, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text((accountName ?? '').toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                    onPressed: onSetupPressed,
                    tooltip: 'Thay đổi tài khoản',
                  )
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}