import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 26, 
    fontWeight: FontWeight.w700, 
    color: AppColors.textMain,
    letterSpacing: -0.5, 
  );

  static final TextStyle appBarTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2, 
  );

  static final TextStyle bodyText = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMain,
    height: 1.5, 
  );

  static final TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500, 
    color: AppColors.textSub,
    letterSpacing: 0.3,
  );
}