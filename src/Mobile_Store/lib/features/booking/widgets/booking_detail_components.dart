import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/store_booking_model.dart';

// 1. Thẻ chứa dùng chung (Thay cho _CardContainer)
class CustomCardContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomCardContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// 2. Dòng thông tin (Thay cho _InfoRow)
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}

// 3. Banner Trạng Thái
class BookingStatusBanner extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const BookingStatusBanner({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String statusText;
    switch (detail.status.toLowerCase()) {
      case 'pending': bgColor = Colors.orange; statusText = 'Đang chờ duyệt'; break;
      case 'confirmed': bgColor = Colors.blue; statusText = 'Đã xác nhận'; break;
      case 'completed': bgColor = Colors.green; statusText = 'Đã hoàn thành'; break;
      case 'cancelled': bgColor = Colors.red; statusText = 'Đã hủy (${detail.cancelReason ?? 'Không rõ'})'; break;
      default: bgColor = Colors.grey; statusText = 'Không rõ';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: bgColor)
      ),
      child: Text(
        'Trạng thái: $statusText',
        style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// 4. Section Khách hàng
class CustomerSection extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const CustomerSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return CustomCardContainer(
      title: 'Thông tin khách hàng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(icon: Icons.person_outline, label: 'Khách hàng', value: detail.customerName),
          const SizedBox(height: 8),
          InfoRow(icon: Icons.phone_outlined, label: 'Số điện thoại', value: detail.customerPhone),
          if (detail.customerNote != null && detail.customerNote!.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
            InfoRow(icon: Icons.edit_note, label: 'Ghi chú', value: detail.customerNote!),
          ]
        ],
      ),
    );
  }
}

// 5. Section Dịch vụ
class ServicesSection extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const ServicesSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy', 'vi_VN');

    return CustomCardContainer(
      title: 'Dịch vụ đã chọn (${detail.services.length})',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: detail.services.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final service = detail.services[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.spa_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '${service.startTime} - ${service.endTime} • ${dateFormat.format(service.appointmentDate)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nhân viên: ${service.staffName ?? "Chưa phân công"}',
                      style: TextStyle(
                        color: service.staffName == null ? Colors.orange : Colors.blue, 
                        fontSize: 13, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(service.price),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDE4660)),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 6. Section Thanh Toán
class PaymentSection extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const PaymentSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    const primaryColor = Color(0xFFDE4660);

    return CustomCardContainer(
      title: 'Chi tiết thanh toán',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tạm tính', style: TextStyle(color: Colors.grey)),
              Text(currencyFormat.format(detail.totalPrice), style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Khuyến mãi', style: TextStyle(color: Colors.grey)),
              Text('- ${currencyFormat.format(detail.discountAmount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(currencyFormat.format(detail.finalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}