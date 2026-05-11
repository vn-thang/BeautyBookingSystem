import 'package:flutter/material.dart';

class CircleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? count; 
  final Color bgColor;
  final Color iconColor;

  const CircleActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, 
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Container(
          width: 48, 
          height: 48,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8), 
        
        Text(
          label, 
          textAlign: TextAlign.center, 
          style: const TextStyle(
            fontSize: 11, 
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        
        if (count != null) ...[
          const SizedBox(height: 4), 
          Text(
            '($count)', 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 11, 
              color: iconColor,
              fontWeight: FontWeight.w800, 
            ),
          ),
        ],
      ],
    );
  }
}