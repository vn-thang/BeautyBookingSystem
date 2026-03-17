import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ReviewFilterWidget extends StatelessWidget {
  final int? selectedRating;
  final bool? selectedHasReplied;
  final Function(int? rating, bool? hasReplied) onFilterChanged;

  const ReviewFilterWidget({
    super.key,
    required this.selectedRating,
    required this.selectedHasReplied,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
  
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                labelText: 'Số sao', 
                labelStyle: WidgetStateTextStyle.resolveWith((states) => 
                  states.contains(WidgetState.focused) ? TextStyle(color: AppColors.primary) : const TextStyle()
                ),
                border: const OutlineInputBorder(), 
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)), // Viền đỏ khi chọn
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
              ),
              initialValue: selectedRating,
              items: const [
                DropdownMenuItem(value: null, child: Text('Tất cả sao')),
                DropdownMenuItem(value: 5, child: Text('5 Sao ⭐')),
                DropdownMenuItem(value: 4, child: Text('4 Sao ⭐')),
                DropdownMenuItem(value: 3, child: Text('3 Sao ⭐')),
                DropdownMenuItem(value: 2, child: Text('2 Sao ⭐')),
                DropdownMenuItem(value: 1, child: Text('1 Sao ⭐')),
              ],
              onChanged: (val) => onFilterChanged(val, selectedHasReplied),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<bool?>(
              decoration: InputDecoration(
                labelText: 'Trạng thái', 
                labelStyle: WidgetStateTextStyle.resolveWith((states) => 
                  states.contains(WidgetState.focused) ? TextStyle(color: AppColors.primary) : const TextStyle()
                ),
                border: const OutlineInputBorder(), 
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
              ),
              initialValue: selectedHasReplied,
              items: const [
                DropdownMenuItem(value: null, child: Text('Tất cả')),
                DropdownMenuItem(value: false, child: Text('Chưa trả lời')),
                DropdownMenuItem(value: true, child: Text('Đã trả lời')),
              ],
              onChanged: (val) => onFilterChanged(selectedRating, val),
            ),
          ),
        ],
      ),
    );
  }
}