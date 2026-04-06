import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/inputs/app_filter_dropdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class RevenueTimeFilterDropdown extends StatefulWidget {
  final Function(DateTime? startDate, DateTime? endDate, String label) onFilterApplied;
  final String? inlineLabel;
  final String initialValue; 

  const RevenueTimeFilterDropdown({
    super.key, 
    required this.onFilterApplied,
    this.inlineLabel = 'Thời gian: ',
    this.initialValue = '30 ngày qua', 
  });

  @override
  State<RevenueTimeFilterDropdown> createState() => _RevenueTimeFilterDropdownState();
}

class _RevenueTimeFilterDropdownState extends State<RevenueTimeFilterDropdown> {
  late String _selectedValue; 
  
  final List<String> _fixedOptions = [
    'Hôm nay',
    '7 ngày qua',
    '30 ngày qua',
    'Năm nay',
    'Tất cả', 
    'Tùy chỉnh...'
  ];

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _handleOptionSelected(String? value) async {
    if (value == null) return;

    if (value == 'Tùy chỉnh...') {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
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

      if (picked != null) {
        final label = '${Formatters.formatDateOnly(picked.start)} - ${Formatters.formatDateOnly(picked.end)}';
        setState(() {
          _selectedValue = label;
        });
        widget.onFilterApplied(picked.start, picked.end, label);
      }
    } else {
      setState(() {
        _selectedValue = value;
      });

      final now = DateTime.now();
      DateTime? start;
      DateTime? end = now;

      switch (value) {
        case 'Hôm nay':
          start = DateTime(now.year, now.month, now.day);
          break;
        case '7 ngày qua':
          start = now.subtract(const Duration(days: 7));
          break;
        case '30 ngày qua':
          start = now.subtract(const Duration(days: 30));
          break;
        case 'Năm nay':
          start = DateTime(now.year, 1, 1);
          break;
        case 'Tất cả':
          start = null; 
          end = null;
          break;
        default:
          start = now.subtract(const Duration(days: 30));
      }
      widget.onFilterApplied(start, end, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> displayOptions = List.from(_fixedOptions);
    if (!displayOptions.contains(_selectedValue)) {
      displayOptions.insert(0, _selectedValue); 
    }

    return AppFilterDropdown<String>(
      inlineLabel: widget.inlineLabel,
      hint: 'Chọn thời gian',
      value: _selectedValue,
      items: displayOptions.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: AppTextStyles.bodyText.copyWith(
              color: option == 'Tùy chỉnh...' ? AppColors.primary : AppColors.textMain,
              fontWeight: option == _selectedValue ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
      onChanged: _handleOptionSelected,
    );
  }
}