import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store/features/booking/screens/store_createbooking_screen.dart';
import 'package:mobile_store/shared/widgets/inputs/app_filter_dropdown.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../widgets/booking_list_tab.dart';
import '../../../shared/models/simple_staff_model.dart';
import '../../../shared/api/master_data_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class BookingManagementScreen extends StatefulWidget {
  final int initialIndex;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final int? initialStaffId; 

  const BookingManagementScreen({
    super.key,
    this.initialIndex = 0,
    this.initialStartDate, 
    this.initialEndDate,  
    this.initialStaffId, 
  });

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  
  int? _staffId;
  List<SimpleStaffModel> _staffList = [];
  bool _isLoadingStaff = true;

  bool _isFabExtended = true; 

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _staffId = widget.initialStaffId; 
    
    _loadStaffs();
  }

  Future<void> _loadStaffs() async {
    final staffs = await MasterDataApi.getStaffsForFilter();
    
    if (mounted) {
      setState(() {
        _staffList = staffs;
        _isLoadingStaff = false;
        
        if (_staffId != null && !_staffList.any((s) => s.id == _staffId)) {
          _staffId = null;
        }
      });
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            onSurface: AppColors.textMain,
          ),
        ),
        child: child!,
      ),
    );
    
    if (date != null) {
      setState(() {
        if (isStart) { 
          _startDate = date;
        } else { 
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, 
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: AppColors.background, 
        appBar: AppHeader(
          title: 'Đơn đặt lịch',
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
            tabAlignment: TabAlignment.start,
            labelStyle: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.bodyText,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Đã duyệt'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLarge, 
                vertical: AppDimens.paddingMedium
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateFilterButton(
                          'Bắt đầu', 
                          _startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Chọn...', 
                          () => _pickDate(true)
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildDateFilterButton(
                          'Kết thúc', 
                          _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Chọn...', 
                          () => _pickDate(false)
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.md),

                  AppFilterDropdown<int?>(
                    inlineLabel: 'Nhân viên: ',
                    hint: 'Tất cả nhân viên',
                    value: _staffId,
                    isLoading: _isLoadingStaff,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tất cả nhân viên'),
                      ),
                      ..._staffList.map((staff) {
                        return DropdownMenuItem<int?>(
                          value: staff.id,
                          child: Text(staff.fullName),
                        );
                      }),
                    ],
                    onChanged: (int? newValue) {
                      setState(() {
                        _staffId = newValue; 
                      });
                    },
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.forward) {
                    if (!_isFabExtended) setState(() => _isFabExtended = true);
                  } else if (notification.direction == ScrollDirection.reverse) {
                    if (_isFabExtended) setState(() => _isFabExtended = false);
                  }
                  return true;
                },
                child: TabBarView(
                  children: [
                    BookingListTab(status: null, startDate: _startDate, endDate: _endDate, staffId: _staffId),        
                    BookingListTab(status: 'Pending', startDate: _startDate, endDate: _endDate, staffId: _staffId),    
                    BookingListTab(status: 'Confirmed', startDate: _startDate, endDate: _endDate, staffId: _staffId),  
                    BookingListTab(status: 'Completed', startDate: _startDate, endDate: _endDate, staffId: _staffId),  
                    BookingListTab(status: 'Cancelled', startDate: _startDate, endDate: _endDate, staffId: _staffId),  
                  ],
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          isExtended: _isFabExtended,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreCreateBookingScreen(
                  storeId: 1, 
                ),
              ),
            );

            if (result == true && mounted) {
               setState(() {}); 
            }
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: AppColors.white),
          label: Text(
            'Tạo đơn mới',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.white, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(String label, String value, VoidCallback onTap) {
    return Row(
      children: [
        Text('$label: ', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub)), 
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            child: Container(
              height: 36, 
              padding: const EdgeInsets.symmetric(horizontal: 12), 
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
                color: AppColors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      value, 
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary, 
                        fontWeight: FontWeight.w500, 
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary), 
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}