import 'package:flutter/material.dart';
import '../models/customer_profile_model.dart';

class CustomerInfoCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const CustomerInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      profile.phone,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 36,
      backgroundColor: Colors.blue.shade50,
      backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
          ? NetworkImage(profile.avatarUrl!)
          : null,
      child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
          ? Text(
              profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.blue.shade700),
            )
          : null,
    );
  }
}