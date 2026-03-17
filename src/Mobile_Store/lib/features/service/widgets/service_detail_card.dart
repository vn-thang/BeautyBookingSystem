import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service_model.dart';
import '../../../shared/widgets/shared_service_widgets.dart';

class ServiceDetailCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceDetailCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: service.isActive == false ? Colors.grey.shade200 : kPrimaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.cut, color: service.isActive == false ? Colors.grey : kPrimaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, 
                    color: service.isActive == false ? Colors.grey : Colors.black87,
                    decoration: service.isActive == false ? TextDecoration.lineThrough : null, 
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text('${service.durationMinutes} phút', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 30, width: 30,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20, color: Colors.black87), SizedBox(width: 8), Text('Chỉnh sửa')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa dịch vụ', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(service.price),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: service.isActive == false ? Colors.grey : kPrimaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}