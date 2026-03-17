import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer_list_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerListModel customer;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(customer.phone, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đã đến: ${customer.totalVisits} lần', 
                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500, fontSize: 13)),
                        Text(currencyFormat.format(customer.totalSpent), 
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue.shade50,
      backgroundImage: (customer.avatarUrl != null && customer.avatarUrl!.isNotEmpty)
          ? NetworkImage(customer.avatarUrl!)
          : null,
      child: (customer.avatarUrl == null || customer.avatarUrl!.isEmpty)
          ? Text(
              customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade700),
            )
          : null,
    );
  }
}