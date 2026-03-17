import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../../../shared/widgets/shared_service_widgets.dart';

class FreeServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const FreeServiceTile({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = service.isActive;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            (service.imageUrl != null && service.imageUrl!.isNotEmpty) 
                ? service.imageUrl! 
                : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(service.name)}&background=random', 
            width: 50, height: 50, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey, size: 20)),
          ),
        ),
        title: Text(
          service.name, 
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isActive ? Colors.black87 : Colors.grey)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${service.price.toInt()} đ', style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
            if (!isActive) Text('Đang tạm ẩn', style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}