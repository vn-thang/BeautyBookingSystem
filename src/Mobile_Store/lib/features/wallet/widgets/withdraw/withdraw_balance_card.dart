import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class WithdrawBalanceCard extends StatelessWidget {
  final double availableBalance;

  const WithdrawBalanceCard({super.key, required this.availableBalance});

  @override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3), 
          blurRadius: 10, 
          offset: const Offset(0, 5)
        )
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        const Text(
          'SỐ DƯ KHẢ DỤNG', 
          style: TextStyle(
            color: Colors.white70, 
            fontSize: 13, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          )
        ),
        const SizedBox(height: 4),
        const Text(
          'Có thể rút ngay về tài khoản ngân hàng', 
          style: TextStyle(
            color: Colors.white54, 
            fontSize: 11
          )
        ),
        
        const SizedBox(height: 16), 
        
        Text(
          Formatters.formatCurrency(availableBalance),
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 28, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
}