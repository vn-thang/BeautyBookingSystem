import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/inputs/app_header.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../../../shared/models/service_group_model.dart';
import '../../../shared/models/service_model.dart';
import '../../service/services/service_api.dart';
import '../services/store_booking_api.dart';
import '../models/store_booking_model.dart';
import '../models/store_createbooking_model.dart';
import '../widgets/step1_services_widget.dart';
import '../widgets/step2_datetime_widget.dart';
import '../widgets/step3_staff_widget.dart';
import '../widgets/step4_confirm_widget.dart';

class StoreCreateBookingScreen extends StatefulWidget {
  final int storeId;
  const StoreCreateBookingScreen({super.key, required this.storeId});

  @override
  State<StoreCreateBookingScreen> createState() => _StoreCreateBookingScreenState();
}

class _StoreCreateBookingScreenState extends State<StoreCreateBookingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  bool _isLoading = false;
  bool _isLoadingStaffs = false;

  List<ServiceGroupModel> _serviceGroups = []; 
  final List<ServiceModel> _selectedServices = []; 
  
  DateTime? _selectedDate;
  String? _selectedTime;
  
  List<AvailableStaffModel> _availableStaffs = [];
  int? _selectedStaffId;

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
     final groups = await ServiceApi.getGroupedServices(widget.storeId);
      if (!mounted) return;
      setState(() {
        _serviceGroups = groups;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackBarHelper.showError(context, 'Lỗi tải danh sách dịch vụ: $e');
    }
  }

  Future<void> _fetchAvailableStaffs() async {
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() => _isLoadingStaffs = true);
    try {
      int totalMinutes = _selectedServices.fold<int>(0, (sum, item) => sum + item.durationMinutes);
      
      final parts = _selectedTime!.split(':');
      final startDt = DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      final endDt = startDt.add(Duration(minutes: totalMinutes));
      final endTimeStr = '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';

      final staffs = await StoreBookingApi.getAvailableStaffs(
        date: _selectedDate!,
        startTime: _selectedTime!,
        endTime: endTimeStr,
      );

      if (!mounted) return;
      setState(() {
        _availableStaffs = staffs;
        _isLoadingStaffs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingStaffs = false);
      SnackBarHelper.showError(context, 'Lỗi tải danh sách nhân viên: $e');
    }
  }

List<TimeSlotModel> _availableTimeSlots = []; 
bool _isLoadingTimeSlots = false;

Future<void> _fetchTimeSlots() async {
  if (_selectedDate == null) return;
  
  int totalMinutes = _selectedServices.fold<int>(0, (sum, item) => sum + item.durationMinutes);
  if (totalMinutes == 0) return;

  setState(() {
    _isLoadingTimeSlots = true;
    _selectedTime = null; 
    _availableTimeSlots = [];
  });

  try {
    final slots = await StoreBookingApi.getAvailableTimeSlots(
      date: _selectedDate!,
      totalDurationMinutes: totalMinutes,
    );
    
    if (!mounted) return;
    setState(() {
      _availableTimeSlots = slots;
      _isLoadingTimeSlots = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoadingTimeSlots = false);
    SnackBarHelper.showError(context, 'Lỗi tải khung giờ: $e');
  }
}

  void _nextStep() {
    if (_currentStep == 0 && _selectedServices.isEmpty) {
      SnackBarHelper.showError(context, 'Vui lòng chọn ít nhất 1 dịch vụ');
      return;
    }
    if (_currentStep == 1 && (_selectedDate == null || _selectedTime == null)) {
      SnackBarHelper.showError(context, 'Vui lòng chọn ngày và giờ hẹn');
      return;
    }
    
    if (_currentStep == 1) _fetchAvailableStaffs();

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitBooking() async {
    if (_customerNameController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Vui lòng nhập tên khách hàng');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = CreateStoreBookingRequest(
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim().isNotEmpty ? _customerPhoneController.text.trim() : null,
        appointmentDate: _selectedDate!,
        note: "Tạo bởi cửa hàng",
        services: _selectedServices.map((s) {
          String formattedStartTime = _selectedTime!.length == 5 ? '$_selectedTime:00' : _selectedTime!;
          return StoreBookingServiceRequest(
            serviceId: s.id, 
            startTime: formattedStartTime,
            staffId: _selectedStaffId,
          );
        }).toList(),
      );

      final response = await StoreBookingApi.createStoreBooking(request);

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      SnackBarHelper.showSuccess(context, 'Tạo lịch hẹn thành công (Mã #${response.id})!');
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackBarHelper.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }
 
@override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0, 
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _previousStep(); 
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: _getStepTitle(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    backgroundColor: AppColors.surface,
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Step1ServicesWidget(
                          serviceGroups: _serviceGroups,
                          selectedServices: _selectedServices,
                          onServiceToggled: (service, isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedServices.add(service);
                              } else {
                                _selectedServices.removeWhere((s) => s.id == service.id);
                              }
                            });
                          },
                        ),
                        Step2DateTimeWidget(
                          selectedDate: _selectedDate,
                          selectedTime: _selectedTime,
                          availableTimeSlots: _availableTimeSlots,
                          isLoadingTimeSlots: _isLoadingTimeSlots,
                          onDateSelected: (date) {
                            setState(() => _selectedDate = date);
                            _fetchTimeSlots();
                          },
                          onTimeSelected: (time) => setState(() => _selectedTime = time),
                        ),
                        Step3StaffWidget(
                          isLoadingStaffs: _isLoadingStaffs,
                          availableStaffs: _availableStaffs,
                          selectedStaffId: _selectedStaffId,
                          onStaffSelected: (id) => setState(() => _selectedStaffId = id),
                        ),
                        Step4ConfirmWidget(
                          selectedServices: _selectedServices,
                          selectedDate: _selectedDate,
                          selectedTime: _selectedTime,
                          selectedStaffId: _selectedStaffId,
                          availableStaffs: _availableStaffs,
                          customerNameController: _customerNameController,
                          customerPhoneController: _customerPhoneController,
                        ),
                      ],
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Chọn dịch vụ';
      case 1: return 'Chọn ngày giờ';
      case 2: return 'Chọn nhân viên';
      case 3: return 'Xác nhận lịch hẹn';
      default: return '';
    }
  }

  Widget _buildBottomBar() {
    double totalPrice = _selectedServices.fold<double>(0.0, (sum, item) => sum + item.price);
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: AppPrimaryButton(
          text: _currentStep < 3 ? 'Tiếp tục • ${Formatters.formatCurrency(totalPrice)}' : 'Xác nhận tạo đơn',
          onPressed: _currentStep < 3 ? _nextStep : _submitBooking,
        ),
      ),
    );
  }
}