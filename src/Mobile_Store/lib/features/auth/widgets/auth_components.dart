import 'dart:ui';
import 'package:flutter/material.dart';

// ==========================================
// 1. NỀN GRADIENT VÀ KHUNG KÍNH (GLASSMORPHISM)
// ==========================================
class AuthGlassBackground extends StatelessWidget {
  final Widget child;

  const AuthGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6FD8), Color(0xFFFF9A8B), Color(0xFF5EFCE8)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15), // Dùng .withOpacity(0.15) nếu Flutter SDK cũ
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. KHUNG BÁO LỖI (ERROR BOX)
// ==========================================
class AuthErrorBox extends StatelessWidget {
  final String errorMessage;

  const AuthErrorBox({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. NÚT BẤM CHÍNH (GRADIENT BUTTON)
// ==========================================
class AuthGradientButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthGradientButton({
    super.key,
    required this.text,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: isLoading
                ? [Colors.grey, Colors.grey.shade400]
                : [const Color(0xFFFF7EB3), const Color(0xFFFF758C)],
          ),
          boxShadow: isLoading ? [] : [
            BoxShadow(
              color: Colors.pinkAccent.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}

// ==========================================
// 4. NÚT BẤM VIỀN (OUTLINE BUTTON)
// ==========================================
class AuthOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AuthOutlineButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}