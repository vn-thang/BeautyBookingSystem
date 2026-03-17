import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/store_booking_model.dart';
import '../services/store_booking_api.dart';

class AssignStaffBottomSheet extends StatefulWidget {
  final StoreBookingDetailModel booking;
  final VoidCallback onSuccess;

  const AssignStaffBottomSheet({super.key, required this.booking, required this.onSuccess});

  @override
  State<AssignStaffBottomSheet> createState() => _AssignStaffBottomSheetState();
}

class _AssignStaffBottomSheetState extends State<AssignStaffBottomSheet> {
  final Color primaryColor = const Color(0xFFDE4660);
  
  bool _isLoading = true;
  String? _errorMessage;

  // Lưu danh sách nhân viên rảnh cho TỪNG dịch vụ (Key: bookingDetailId)
  final Map<int, List<AvailableStaffModel>> _availableStaffMap = {};
  
  // Lưu lựa chọn nhân viên của người dùng (Key: bookingDetailId, Value: staffId)
  final Map<int, int> _selectedStaffMap = {};

  @override
  void initState() {
    super.initState();
    _fetchAvailableStaffs();
  }

  // Khởi tạo: Quét tìm nhân viên rảnh cho tất cả dịch vụ trong đơn
  Future<void> _fetchAvailableStaffs() async {
    try {
      for (var service in widget.booking.services) {
        final staffs = await StoreBookingApi.getAvailableStaffs(
          date: service.appointmentDate,
          startTime: service.startTime,
          endTime: service.endTime,
        );
        _availableStaffMap[service.bookingDetailId] = staffs;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _submitAssignment() async {
    // Kiểm tra xem đã chọn đủ nhân viên cho tất cả dịch vụ chưa
    if (_selectedStaffMap.length < widget.booking.services.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng phân công nhân viên cho tất cả dịch vụ!'), backgroundColor: Colors.orange)
      );
      return;
    }

    // Chuyển đổi dữ liệu sang định dạng API cần
    final assignments = _selectedStaffMap.entries.map((e) => {
      "bookingDetailId": e.key,
      "staffId": e.value
    }).toList();

    // Hiển thị loading mờ toàn màn hình để tránh bấm đúp
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await StoreBookingApi.assignStaff(widget.booking.id, assignments);
      
      if (!mounted) return;
      Navigator.pop(context); // Đóng Loading Dialog
      Navigator.pop(context); // Đóng Bottom Sheet
      
      widget.onSuccess(); // Reload lại màn hình chi tiết
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duyệt đơn & Gán nhân viên thành công!'), backgroundColor: Colors.green)
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Đóng Loading Dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      // Đặt max height để có thể cuộn nếu danh sách dịch vụ quá dài
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phân công nhân viên', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Giao diện Loading / Lỗi / Danh sách
          Expanded(child: _buildBody()),

          if (!_isLoading && _errorMessage == null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitAssignment,
                child: const Text('XÁC NHẬN VÀ DUYỆT ĐƠN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }
    if (_errorMessage != null) {
      return Center(child: Text('Lỗi: $_errorMessage', style: const TextStyle(color: Colors.red)));
    }

    final dateFormat = DateFormat('dd/MM/yyyy', 'vi_VN');

    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.booking.services.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final service = widget.booking.services[index];
        final staffs = _availableStaffMap[service.bookingDetailId] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '⏰ ${service.startTime} - ${service.endTime} • ${dateFormat.format(service.appointmentDate)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            
            // Dropdown chọn nhân viên
            if (staffs.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Không có nhân viên nào rảnh khung giờ này!', style: TextStyle(color: Colors.red, fontSize: 13))),
                  ],
                ),
              )
            else
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Chọn nhân viên phụ trách',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                initialValue: _selectedStaffMap[service.bookingDetailId],
                items: staffs.map((staff) {
                  return DropdownMenuItem<int>(
                    value: staff.id,
                    child: Text('${staff.fullName} (${staff.position})'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStaffMap[service.bookingDetailId] = value;
                    });
                  }
                },
              ),
          ],
        );
      },
    );
  }
}