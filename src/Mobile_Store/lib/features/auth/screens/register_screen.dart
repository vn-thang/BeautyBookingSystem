import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart'; 
import '../widgets/auth_components.dart';
import '../services/auth_service.dart';
import '../../../core/utils/form_validators.dart';
import 'package:flutter/gestures.dart'; 
import 'package:url_launcher/url_launcher.dart'; // thư viện mở web
import '../../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _serverErrorMessage;
  bool _isAgreed = false; 
  late TapGestureRecognizer _termsRecognizer;


  @override
  void initState() {
    super.initState();
    // Khởi tạo đồ bắt sự kiện khi bấm vào chữ màu xanh
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTermsWebPage;
  }
  @override
  void dispose() {
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_serverErrorMessage != null) setState(() => _serverErrorMessage = null);
  }
Future<void> _openTermsWebPage() async {
    // TẠM THỜI ĐỂ LINK GOOGLE, BẠN THAY LINK NOTION CỦA BẠN VÀO ĐÂY NHÉ
    final Uri url = Uri.parse('https://google.com'); 
    
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      debugPrint('Không thể mở link: $url');
    }
  }
  Future<void> _handleRegister() async {
    _clearError();
    if (!_formKey.currentState!.validate()) return;

  // --- KIỂM TRA XEM ĐÃ TÍCH CHỌN ĐIỀU KHOẢN CHƯA ---
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với Chính sách & điều khoản để tiếp tục!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating, // Hiển thị đè lên trên cho đẹp
        ),
      );
      return; // Dừng lại, không gọi API
    }
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.registerPartner(
        _ownerNameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        setState(() => _serverErrorMessage = result.errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGlassBackground(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Đăng ký đối tác', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              const Text('Tạo tài khoản cửa hàng của bạn', style: TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 30),

             AppTextField(
  hint: 'Họ và tên chủ tiệm',
  icon: Icons.person_outline,
  controller: _ownerNameController,
  // SỬA DÒNG NÀY
  validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập họ tên'),
  onChanged: (_) => _clearError(),
),
              const SizedBox(height: 14),

            AppTextField(
  hint: 'Số điện thoại',
  icon: Icons.phone_outlined,
  controller: _phoneController,
  // SỬA DÒNG NÀY
  validator: FormValidators.phone,
  onChanged: (_) => _clearError(),
),
              const SizedBox(height: 14),

             AppTextField(
  hint: 'Email',
  icon: Icons.email_outlined,
  controller: _emailController,
  // SỬA DÒNG NÀY
  validator: FormValidators.email,
  onChanged: (_) => _clearError(),
),
              const SizedBox(height: 14),

             AppTextField(
  hint: 'Mật khẩu',
  icon: Icons.lock_outline,
  controller: _passwordController,
  isPassword: true,
  // SỬA DÒNG NÀY
  validator: (val) => FormValidators.password(val),
  onChanged: (_) => _clearError(),
),

const SizedBox(height: 14), // Thêm khoảng trống nhỏ trước Checkbox

              // --- GIAO DIỆN CHECKBOX ĐIỀU KHOẢN THÊM VÀO ĐÂY ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24, // Thu nhỏ kích thước hộp Checkbox cho gọn
                    width: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: Colors.blue, // Đổi màu xanh cho nổi bật
                      side: const BorderSide(color: Color(0xFF334155)), // Viền khi chưa tích
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // Khoảng cách giữa ô tích và chữ
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0), // Căn chữ cho ngang với ô tích
                      child: RichText(
                        text: TextSpan(
                          text: 'Tôi đã đọc và đồng ý với ',
                          // Style chữ này đồng bộ với chữ "Đã có tài khoản?" ở dưới
                          style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Chính sách & điều khoản',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: _termsRecognizer, // Bắn sự kiện click
                            ),
                            const TextSpan(text: ' dịch vụ của hệ thống.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_serverErrorMessage != null) AuthErrorBox(errorMessage: _serverErrorMessage!),

              const SizedBox(height: 25),
              AuthGradientButton(text: 'Đăng ký', isLoading: _isLoading, onPressed: _handleRegister),
              
              const SizedBox(height: 20),
              const Text('Đã có tài khoản?', style: TextStyle(color: Color(0xFF334155), fontSize: 13)),
              const SizedBox(height: 10),
              AuthOutlineButton(text: 'Đăng nhập ngay', onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}