import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_buttons.dart'; 
import '../../../shared/widgets/app_error_box.dart';
import '../../../shared/widgets/app_image_picker.dart';
import '../../../core/utils/form_validators.dart';
import '../services/account_service.dart';
import '../../../core/theme/app_colors.dart';

class AccountUpdateProfileScreen extends StatefulWidget {
  const AccountUpdateProfileScreen({super.key});

  @override
  State<AccountUpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<AccountUpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); 
  final _phoneCtrl = TextEditingController(); 
  
  bool _isFetching = true; // Trạng thái đang tải dữ liệu cũ
  bool _isUpdating = false; // Trạng thái đang bấm nút lưu
  String? _errorMessage;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Gọi hàm lấy dữ liệu ngay khi mở màn hình
  }
  Future<void> _loadProfile() async {
    final result = await AccountService.getProfile();
    
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final user = result.data!;
      // QUAN TRỌNG: Gán dữ liệu từ API vào các Controller để nó hiện lên màn hình
      setState(() {
        _fullNameCtrl.text = user.fullName;
        _emailCtrl.text = user.email ?? 'Chưa cập nhật';
        _phoneCtrl.text = user.phone;
        _avatarUrl = user.avatarUrl;
        _isFetching = false; // Tắt vòng xoay loading
      });
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Không thể tải thông tin';
        _isFetching = false;
      });
    }
  }

  // --- Widget cho ô bị khóa (Email, SĐT) ---
  Widget _buildReadOnlyField({required String label, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // Dùng controller để dữ liệu tự cập nhật khi load xong
          enabled: false,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100], // Sửa thành xám nhạt cho tinh tế hơn
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSub),
            suffixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textSub),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  // --- HÀM UPDATE: Gửi dữ liệu mới lên server ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    final result = await AccountService.updateProfile(
      fullName: _fullNameCtrl.text.trim(),
      avatarUrl: _avatarUrl,
    );

    if (!mounted) return;
    setState(() => _isUpdating = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
      );
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white, // Đổi màu nền thành trắng tinh
      appBar: AppBar(
        title: const Text(
          'Tài khoản của tôi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        backgroundColor: AppColors.primary, // Đổ màu nền đỏ/hồng
        foregroundColor: AppColors.background, // Chữ trắng
        elevation: 0,
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) // Sửa màu loading
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                   Center(
                      child: AppImagePicker(
                        folderName: 'avatars', // Tạo thư mục avatars trên mây
                        isCircle: true,        // Bật chế độ bo tròn thành hình Avatar
                        width: 120,            // Chỉnh kích thước to/nhỏ tùy ý bạn
                        height: 120,
                        initialImageUrl: _avatarUrl, // Hiện avatar cũ (nếu có)
                        onImageUploaded: (url) {
                          // Khi up lên Cloudinary thành công, nó sẽ ném link vào đây
                          setState(() {
                            _avatarUrl = url; // Lưu lại để lát gửi về API C#
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_errorMessage != null) ...[
                      AppErrorBox(errorMessage: _errorMessage!),
                      const SizedBox(height: 20),
                    ],

                    // Ô nhập họ tên (Cho phép sửa)
                    AppTextField(
                      label: 'Họ và Tên (*)',
                      hint: 'Nhập họ và tên',
                      icon: Icons.person_outline,
                      controller: _fullNameCtrl,
                      validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập họ tên'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Ô số điện thoại (Chỉ xem)
                    _buildReadOnlyField(
                      label: 'Số điện thoại',
                      controller: _phoneCtrl, 
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Ô email (Chỉ xem)
                    _buildReadOnlyField(
                      label: 'Email',
                      controller: _emailCtrl, 
                      icon: Icons.email_outlined,
                    ),
                    
                    const SizedBox(height: 30),

                    // Nút cập nhật
                    AppGradientButton(
                      text: 'LƯU THAY ĐỔI',
                      isLoading: _isUpdating,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                  ],
                ),
              ),
            ),
    );
  }
}