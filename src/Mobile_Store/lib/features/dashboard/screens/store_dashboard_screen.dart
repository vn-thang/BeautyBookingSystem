import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/dashboard_service.dart';
import '../../store/screens/update_profile_screen.dart';
import '../../booking/screens/booking_management_screen.dart';
import '../models/store_dashboard_model.dart';
import '../widgets/pending_banner.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/detailed_stats_card.dart';
import '../widgets/commission_card.dart';
import '../widgets/bookings_card.dart';

class StoreDashboardScreen extends StatefulWidget {
  const StoreDashboardScreen({super.key});

  @override
  State<StoreDashboardScreen> createState() => _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  StoreDashboardModel? _dashboardData;
  
  // Khởi tạo mặc định là 'today' hoặc 'all' tùy bạn
  String _selectedFilter = 'today'; 
  DateTime? _startDate; 
  DateTime? _endDate;   

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await DashboardService.getDashboardData(
        timeFilter: _selectedFilter,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(String newFilter) {
    if (_selectedFilter == newFilter) return;
    setState(() {
      _selectedFilter = newFilter;
      // Nếu không phải chọn "tùy chỉnh", reset lại ngày
      if (newFilter != 'custom') {
        _startDate = null;
        _endDate = null;
      }
    });
    _fetchDashboardData();
  }

  // Đã sửa: Cho phép nhận 1 trong 2 ngày (có thể null)
  void _onDateChanged(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      // Tự động chuyển dropdown sang "Tùy chỉnh"
      _selectedFilter = 'custom';
    });
    _fetchDashboardData(); // Gọi API ngay khi đổi ngày
  }

  Future<void> _onRefresh() async {
    await _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _dashboardData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null && _dashboardData == null) {
      return _buildErrorState();
    }
    
    if (_dashboardData == null) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    final data = _dashboardData!;
    final status = data.status.toLowerCase();

    if (status == 'incomplete') {
      _redirectToUpdateProfile();
      return const Center(child: CircularProgressIndicator());
    }

    if (status == 'locked') {
      return _buildLockedState();
    }

    final isPending = status == 'pending';

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            DashboardHeader(header: data.header),
            if (isPending) const PendingBanner(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Opacity(
                opacity: _isLoading ? 0.6 : 1.0,
                child: Column(
                  children: [
                    Opacity(
                      opacity: isPending ? 0.4 : 1.0,
                      child: AbsorbPointer(
                        absorbing: isPending, 
                        child: Column(
                          children: [
                            DetailedStatsCard(
                              stats: data.statistics,
                              currentFilter: _selectedFilter,
                              startDate: _startDate, 
                              endDate: _endDate,     
                              onFilterChanged: _onFilterChanged,
                              onDateChanged: _onDateChanged, 
                            ),
                            const SizedBox(height: 16),
                            CommissionCard(comm: data.commission),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BookingsCard(
                      counts: data.bookingCounts,
                      onViewAllBookings: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const BookingManagementScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _redirectToUpdateProfile() {
    Future.microtask(() {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
      );
    });
  }

    Widget _buildLockedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, color: Colors.red, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Tài khoản bị khóa",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tài khoản của bạn đã bị tạm khóa do vi phạm chính sách hoặc theo yêu cầu của hệ thống. Vui lòng liên hệ hỗ trợ.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () { /* Link tới tổng đài hoặc chat */ },
              child: const Text("Liên hệ hỗ trợ"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDashboardData,
            child: const Text("Thử lại"),
          )
        ],
      ),
    );
  }
}