import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart'; 

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; 
  final PreferredSizeWidget? bottom; 

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.appBarTitle, 
      ),
      backgroundColor: AppColors.primary, 
      foregroundColor: Colors.white,      
      elevation: 0,                       
      centerTitle: true,                 
      
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
  }
}