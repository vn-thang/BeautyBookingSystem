import 'package:flutter/material.dart';
import '../models/operating_hour.dart';

class OperatingHoursPicker extends StatefulWidget {
  final List<OperatingHour> operatingHours;
  final Color primaryColor;

  const OperatingHoursPicker({
    super.key,
    required this.operatingHours,
    required this.primaryColor,
  });

  @override
  State<OperatingHoursPicker> createState() => _OperatingHoursPickerState();
}

class _OperatingHoursPickerState extends State<OperatingHoursPicker> {
  final List<String> _days = [
    "Chủ nhật",
    "Thứ 2",
    "Thứ 3",
    "Thứ 4",
    "Thứ 5",
    "Thứ 6",
    "Thứ 7"
  ];

  Future<void> _pickTime(OperatingHour day, bool isOpeningTime) async {
    final timeString = isOpeningTime ? day.openTime : day.closeTime;
    final parts = timeString.split(':');

    TimeOfDay initialTime = (parts.length == 2)
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isOpeningTime ? 'Chọn giờ mở cửa' : 'Chọn giờ đóng cửa',
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        if (isOpeningTime) {
          day.openTime = formattedTime;
        } else {
          day.closeTime = formattedTime;
        }

        final openParts = day.openTime.split(':');
        final closeParts = day.closeTime.split(':');
        
        if (openParts.length == 2 && closeParts.length == 2) {
           final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
           final closeMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

           if (openMinutes >= closeMinutes) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Lưu ý: Giờ đóng cửa đang sớm hơn hoặc bằng giờ mở cửa!"),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                )
              );
           }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Icon(Icons.calendar_month_outlined, color: widget.primaryColor),
        title: const Text("Chi tiết giờ hoạt động (7 ngày)",
            style: TextStyle(fontSize: 15, color: Colors.black87)),
        children: List.generate(widget.operatingHours.length, (index) {
          final day = widget.operatingHours[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
            child: Row(
              children: [
                Checkbox(
                  value: day.isActive,
                  activeColor: widget.primaryColor,
                  onChanged: (val) => setState(() => day.isActive = val ?? false),
                ),
                SizedBox(
                    width: 70,
                    child: Text(_days[day.dayOfWeek],
                        style: const TextStyle(fontSize: 13))),
                if (day.isActive) ...[
                  Expanded(
                      child: _buildTimeBox(
                          day.openTime, () => _pickTime(day, true))),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text("-", style: TextStyle(color: Colors.grey))),
                  Expanded(
                      child: _buildTimeBox(
                          day.closeTime, () => _pickTime(day, false))),
                ] else
                  const Expanded(
                      child: Text(" Nghỉ",
                          style: TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                              fontSize: 13))),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 4. Widget con
  Widget _buildTimeBox(String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.center,
        child: Text(time, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}