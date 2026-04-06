import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_detail_screen.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/feedback/app_error_box.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart'; 
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_header.dart';

import '../models/customer_profile_model.dart';
import '../services/customer_api.dart';
import '../widgets/customer_info_card.dart';
import '../widgets/customer_stats_row.dart';
import '../widgets/service_history_card.dart';

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
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Hồ sơ Khách hàng',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppErrorBox(errorMessage: _errorMessage!),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                text: 'Thử lại',
                onPressed: _fetchCustomerProfile,
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) {
      return Center(
        child: Text(
          'Không tìm thấy dữ liệu khách hàng.',
          style: AppTextStyles.bodyText,
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchCustomerProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm), 

            CustomerInfoCard(profile: _profile!),
            const SizedBox(height: AppSpacing.xl),
            
            CustomerStatsRow(profile: _profile!),
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall), 
                  ),
                  child: const Icon(
                    Icons.history_edu, 
                    color: AppColors.primary, 
                    size: 20
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Lịch sử Dịch vụ',
                  style: AppTextStyles.heading1.copyWith(fontSize: 18), 
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _profile!.serviceHistories.isEmpty
              ? _buildEmptyHistory()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _profile!.serviceHistories.length,
                  itemBuilder: (context, index) {
                    final historyItem = _profile!.serviceHistories[index]; 

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppDimens.radiusSmall), 
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailScreen(
                                  bookingId: historyItem.bookingId,
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
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white, 
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.textSub.withValues(alpha: 0.2)), 
      ),
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, size: 56, color: AppColors.textSub.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Khách hàng chưa sử dụng\ndịch vụ nào tại tiệm.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSub, 
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}