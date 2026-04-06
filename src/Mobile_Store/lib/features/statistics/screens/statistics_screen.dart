import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_store/features/statistics/widgets/revenue_filter_bottom_sheet.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart'; 
import 'package:mobile_store/features/customer/screens/customer_detail_screen.dart';
import 'package:mobile_store/shared/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/statistics_api.dart';
import '../models/revenue_chart_item_model.dart';
import '../models/top_performance_item_model.dart';
import '../models/review_statistics_model.dart';
import '../widgets/top_performance_card.dart';
import '../widgets/revenue_chart_card.dart';
import '../widgets/review_statistics_card.dart';
import '../../booking/screens/booking_management_screen.dart';

class StoreStatisticsScreen extends StatefulWidget {
  const StoreStatisticsScreen({super.key});

  @override
  State<StoreStatisticsScreen> createState() => _StoreStatisticsScreenState();
}

class _StoreStatisticsScreenState extends State<StoreStatisticsScreen> {
  late Future<List<RevenueChartItemModel>> _revenueFuture;
  late Future<List<TopPerformanceItemModel>> _topServicesFuture;
  late Future<List<TopPerformanceItemModel>> _topStaffsFuture;
  late Future<List<TopPerformanceItemModel>> _topCustomersFuture;
  late Future<ReviewStatisticsModel> _reviewFuture; 

  DateTime? _currentStartDate;
  DateTime? _currentEndDate;
  int _selectedDays = 30; 
  
  bool _isExporting = false; 

  @override
  void initState() {
    super.initState();
    _currentEndDate = DateTime.now();
    _currentStartDate = _currentEndDate!.subtract(const Duration(days: 30));
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _revenueFuture = StatisticsApi.getRevenueChart(startDate: _currentStartDate, endDate: _currentEndDate);
      _topServicesFuture = StatisticsApi.getTopServices(startDate: _currentStartDate, endDate: _currentEndDate);
      _topStaffsFuture = StatisticsApi.getTopStaffs(startDate: _currentStartDate, endDate: _currentEndDate);
      _topCustomersFuture = StatisticsApi.getTopCustomers(startDate: _currentStartDate, endDate: _currentEndDate);
      
      _reviewFuture = StatisticsApi.getReviewStatistics(startDate: _currentStartDate, endDate: _currentEndDate); 
    });
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                child: Text('Tùy chọn Báo cáo', style: AppTextStyles.heading1.copyWith(fontSize: 18)),
              ),
              ListTile(
                leading: const Icon(Icons.file_open_rounded, color: AppColors.primary),
                title: Text('Tải về và Mở xem ngay', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Lưu vào máy và mở bằng ứng dụng Excel', style: AppTextStyles.labelSmall),
                onTap: () {
                  Navigator.pop(context); 
                  _processExcel(isShare: false); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: AppColors.success),
                title: Text('Chia sẻ file...', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Gửi qua Zalo, Gmail, Drive...', style: AppTextStyles.labelSmall),
                onTap: () {
                  Navigator.pop(context); 
                  _processExcel(isShare: true); 
                },
              ),
              const SizedBox(height: AppDimens.paddingMedium),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processExcel({required bool isShare}) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final excelBytes = await StatisticsApi.exportRevenueExcel(
        startDate: _currentStartDate, 
        endDate: _currentEndDate
      );

      final appDocDir = await getApplicationDocumentsDirectory();
      
      final startStr = _currentStartDate != null ? '${_currentStartDate!.day}_${_currentStartDate!.month}' : 'TuDau';
      final endStr = _currentEndDate != null ? '${_currentEndDate!.day}_${_currentEndDate!.month}' : 'DenNay';
      final fileName = 'BaoCaoDoanhThu_${startStr}_đến_$endStr.xlsx';
      
      final file = File('${appDocDir.path}/$fileName');

      await file.writeAsBytes(excelBytes);

      if (isShare) {
        final xFile = XFile(file.path);

          await SharePlus.instance.share(
            ShareParams(
              files: [xFile], 
              text: 'Báo cáo doanh thu cửa hàng $startStr đến $endStr',
              subject: 'Báo cáo doanh thu',
            ),
          );
      } else {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done && mounted) {
           SnackBarHelper.showError(context, 'Không thể mở file. Máy bạn có thể chưa cài ứng dụng đọc Excel.');
        }
      }

    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Lỗi xử lý file: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppHeader(
        title: 'Thống Kê Cửa Hàng',
        actions: [
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download_rounded, color: AppColors.white),
                  tooltip: 'Tùy chọn Xuất file',
                  onPressed: _showExportMenu, 
                ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingSmall, vertical: 4),
                margin: const EdgeInsets.only(bottom: AppDimens.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                  boxShadow: [
                    BoxShadow(color: AppColors.textSub.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: RevenueTimeFilterDropdown(
                  initialValue: '30 ngày qua',
                  onFilterApplied: (startDate, endDate, label) {
                    setState(() {
                      _currentStartDate = startDate;
                      _currentEndDate = endDate;
                      
                      if (startDate != null && endDate != null) {
                        _selectedDays = endDate.difference(startDate).inDays;
                      } else {
                        _selectedDays = 365;
                      }
                    });
                    _loadAllData();
                  },
                ),
              ),

              RevenueChartCard(
                future: _revenueFuture,
                selectedDays: _selectedDays, 
              ),
              ReviewStatisticsCard(future: _reviewFuture),
              TopPerformanceCard(
                title: 'Dịch vụ bán chạy',
                icon: Icons.spa,
                future: _topServicesFuture,
              ),
              TopPerformanceCard(
                title: 'Nhân viên xuất sắc',
                icon: Icons.star_border_rounded,
                future: _topStaffsFuture,
                onItemTap: (item) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingManagementScreen(
                        initialStaffId: item.id, 
                        initialStartDate: _currentStartDate, 
                        initialEndDate: _currentEndDate,
                        initialIndex: 3,
                      ),
                    ),
                  );
                },
              ),
              TopPerformanceCard(
                title: 'Khách hàng VIP',
                icon: Icons.workspace_premium,
                future: _topCustomersFuture,
                onItemTap: (item) async { 
                  final currentStoreId = await TokenStorage.getStoreId();
                  if (!context.mounted) return;

                  if (currentStoreId == null || currentStoreId == 0) {
                    SnackBarHelper.showError(context, 'Không tìm thấy thông tin cửa hàng.');
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDetailScreen(
                        storeId: currentStoreId, 
                        customerId: item.id,    
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimens.paddingLarge * 2),
            ],
          ),
        ),
      ),
    );
  }
}