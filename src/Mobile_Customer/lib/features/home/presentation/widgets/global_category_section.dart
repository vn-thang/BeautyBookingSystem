import 'package:flutter/material.dart';
import '../../domain/entities/global_category.dart';

class GlobalCategorySection extends StatelessWidget {
  final List<GlobalCategory> categories;

  const GlobalCategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(item.name[0]),
                ),
                const SizedBox(height: 6),
                Text(item.name),
              ],
            ),
          );
        },
      ),
    );
  }
}