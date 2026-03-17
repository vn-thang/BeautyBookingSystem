// import 'package:flutter/material.dart';
// import '../models/customer_profile_model.dart';
// import '../services/customer_api.dart';
// import '../widgets/customer_info_card.dart';
// import '../widgets/customer_stats_row.dart';
// import '../widgets/service_history_card.dart';

// class CustomerDetailScreen extends StatefulWidget {
//   final int storeId;
//   final int customerId;

//   const CustomerDetailScreen({
//     super.key,
//     required this.storeId,
//     required this.customerId,
//   });

//   @override
//   State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
// }

// class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
//   CustomerProfileModel? _profile;
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCustomerProfile();
//   }

//   Future<void> _fetchCustomerProfile() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final data = await CustomerApi.getCustomerProfile(widget.storeId, widget.customerId);
//       setState(() {
//         _profile = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Hồ sơ Khách hàng'),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
//             const SizedBox(height: 16),
//             Text(_errorMessage!, textAlign: TextAlign.center),
//             TextButton(
//               onPressed: _fetchCustomerProfile,
//               child: const Text('Thử lại'),
//             )
//           ],
//         ),
//       );
//     }

//     if (_profile == null) {
//       return const Center(child: Text('Không tìm thấy dữ liệu khách hàng.'));
//     }

//     return RefreshIndicator(
//       onRefresh: _fetchCustomerProfile,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. Khối thông tin cơ bản
//             CustomerInfoCard(profile: _profile!),
//             const SizedBox(height: 20),
            
//             // 2. Khối thống kê
//             CustomerStatsRow(profile: _profile!),
//             const SizedBox(height: 24),
            
//             // Tiêu đề Lịch sử
//             const Text(
//               'Lịch sử Dịch vụ',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             // 3. Danh sách Lịch sử (Dùng ListView.builder với shrinkWrap để nằm trong ScrollView)
//             _profile!.serviceHistories.isEmpty
//                 ? _buildEmptyHistory()
//                 : ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: _profile!.serviceHistories.length,
//                     itemBuilder: (context, index) {
//                       return ServiceHistoryCard(
//                         history: _profile!.serviceHistories[index],
//                       );
//                     },
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyHistory() {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       alignment: Alignment.center,
//       child: Column(
//         children: [
//           Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade400),
//           const SizedBox(height: 12),
//           Text(
//             'Khách hàng chưa sử dụng dịch vụ nào.',
//             style: TextStyle(color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_detail_screen.dart';
import '../models/customer_profile_model.dart';
import '../services/customer_api.dart';
import '../widgets/customer_info_card.dart';
import '../widgets/customer_stats_row.dart';
import '../widgets/service_history_card.dart';
import '../../../core/theme/app_colors.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int storeId;
  final int customerId;

  const CustomerDetailScreen({
    super.key,
    required this.storeId,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  CustomerProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCustomerProfile();
  }

  Future<void> _fetchCustomerProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await CustomerApi.getCustomerProfile(widget.storeId, widget.customerId);
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Đồng bộ màu nền xám nhạt
      appBar: AppBar(
        title: const Text(
          'Hồ sơ Khách hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary)
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _errorMessage!, 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchCustomerProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(child: Text('Không tìm thấy dữ liệu khách hàng.'));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchCustomerProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            const SizedBox(height: 8), 

            CustomerInfoCard(profile: _profile!),
            const SizedBox(height: 20),
            
            CustomerStatsRow(profile: _profile!),
            const SizedBox(height: 28),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history_edu, 
                    color: AppColors.primary, 
                    size: 20
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lịch sử Dịch vụ',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Danh sách Lịch sử
           _profile!.serviceHistories.isEmpty
    ? _buildEmptyHistory()
    : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _profile!.serviceHistories.length,
        itemBuilder: (context, index) {
          // Lấy ra dữ liệu của 1 thẻ lịch sử ở vị trí hiện tại
          final historyItem = _profile!.serviceHistories[index]; 

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Material(
              color: Colors.transparent, // Giữ nền trong suốt để thẻ Card hiển thị đúng màu
              child: InkWell(
                borderRadius: BorderRadius.circular(12), // Bo góc cho hiệu ứng bấm giống với thẻ Card
                onTap: () {
                  // XỬ LÝ SỰ KIỆN BẤM: Chuyển trang và truyền ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(
                        bookingId: historyItem.bookingId, // Truyền ID đơn hàng sang
                      ),
                    ),
                  );
                },
                child: ServiceHistoryCard(
                  history: historyItem,
                ),
              ),
            ),
          );
        },
      ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Khách hàng chưa sử dụng\ndịch vụ nào tại tiệm.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600, 
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}