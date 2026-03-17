import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/booking_list_tab.dart';
import '../../../core/theme/app_colors.dart';

class BookingManagementScreen extends StatefulWidget {
  final int initialIndex;
  const BookingManagementScreen({
    super.key,
    this.initialIndex = 0,
    });

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
 
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStart) { _startDate = date;
                }else { _endDate = date;}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // 5 Tabs
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Đơn đặt lịch', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabAlignment: TabAlignment.start, // Canh trái giống ảnh
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Đã duyệt'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- BỘ LỌC NGÀY THÁNG ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateFilterButton(
                      'Bắt đầu', 
                      _startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Chọn thời...', 
                      () => _pickDate(true)
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateFilterButton(
                      'Kết thúc', 
                      _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Chọn thời...', 
                      () => _pickDate(false)
                    ),
                  ),
                ],
              ),
            ),
            
            // --- DANH SÁCH THEO TAB ---
            const Expanded(
              child: TabBarView(
                children: [
                  BookingListTab(status: null),          // Tất cả
                  BookingListTab(status: 'Pending'),     // Chờ duyệt
                  BookingListTab(status: 'Confirmed'),   // Đã duyệt
                  BookingListTab(status: 'Completed'),   // Hoàn thành
                  BookingListTab(status: 'Cancelled'),   // Đã hủy
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 // Thay thế toàn bộ hàm cũ bằng hàm này
  Widget _buildDateFilterButton(String label, String value, VoidCallback onTap) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 12)), // Thu nhỏ font một chút
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), // Giảm padding ngang
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dùng Flexible thay vì Expanded để text tự động thu gọn nếu chật
                  Flexible(
                    child: Text(
                      // Đổi "Chọn thời..." thành "Chọn..." cho ngắn gọn
                      value.contains('Chọn thời') ? 'Chọn...' : value, 
                      style: TextStyle(color: AppColors.primary, fontSize: 12, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.primary), // Thu nhỏ icon một chút
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}