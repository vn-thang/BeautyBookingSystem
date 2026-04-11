import 'package:flutter/material.dart';
import 'package:mobile_store/features/dashboard/widgets/pending_banner.dart';
import 'package:mobile_store/features/support/screens/contact_support_screen.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/dashboard_service.dart';
import '../../store/screens/update_profile_screen.dart';
import '../../booking/screens/booking_management_screen.dart';
import '../models/store_dashboard_model.dart';
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
      if (newFilter != 'custom') {
        _startDate = null;
        _endDate = null;
      }
    });
    _fetchDashboardData();
  }

  void _onDateChanged(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedFilter = 'custom';
    });
    _fetchDashboardData(); 
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    
    if (_errorMessage != null && _dashboardData == null) {
      return _buildErrorState();
    }
    
    if (_dashboardData == null) {
      return Center(
        child: Text(
          "Không có dữ liệu",
          style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
        ),
      );
    }

    final data = _dashboardData!;
    final status = data.status.toLowerCase();

    if (status == 'incomplete') {
      _redirectToUpdateProfile();
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (status == 'locked') {
      return _buildLockedState();
    }

    final isPending = status == 'pending';
    final isLowBalance = data.isWalletLowBalance;
    final isAccountRestricted = isPending || isLowBalance; 

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            DashboardHeader(header: data.header),
            
            // Xử lý hiển thị Banner
            if (isLowBalance)
              DashboardWarningBanner(
                type: WarningType.lowBalance, 
                minimumBalance: data.minimumBalance,
              )
            else if (isPending) 
              const DashboardWarningBanner(type: WarningType.pending),
              
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
              child: Opacity(
                opacity: _isLoading ? 0.6 : 1.0,
                child: Column(
                  children: [
                    // Làm mờ và khóa touch
                    Opacity(
                      opacity: isAccountRestricted ? 0.4 : 1.0,
                      child: AbsorbPointer(
                        absorbing: isAccountRestricted, 
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
                            const SizedBox(height: AppSpacing.lg),
                            CommissionCard(comm: data.commission),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    BookingsCard(
                      counts: data.bookingCounts,
                      onViewAllBookings: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const BookingManagementScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimens.paddingLarge),
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
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, color: AppColors.error, size: 80),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Tài khoản bị khóa",
              style: AppTextStyles.heading1.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Tài khoản của bạn đã bị tạm khóa do vi phạm chính sách hoặc theo yêu cầu của hệ thống. Vui lòng liên hệ hỗ trợ.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
            ),
            const SizedBox(height: AppDimens.paddingLarge),
            AppPrimaryButton(
              text: "Liên hệ hỗ trợ",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactSupportScreen(), 
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 50),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage!, 
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.error, 
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppOutlineButton(
              text: "Thử lại",
              onTap: _fetchDashboardData,
            )
          ],
        ),
      ),
    );
  }
}