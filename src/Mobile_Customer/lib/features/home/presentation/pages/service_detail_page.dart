import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/features/customer_favorite/presentation/widgets/customer_favorite_button.dart';

import '../../../booking/presentation/pages/booking_services_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customer_favorite/presentation/bloc/customer_favorite_bloc.dart';
import '../bloc/service_detail_bloc.dart';
import '../bloc/service_detail_event.dart';
import '../bloc/service_detail_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_decorations.dart';

class ServiceDetailPage extends StatefulWidget {
  final int serviceId;

  const ServiceDetailPage({super.key, required this.serviceId});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final NumberFormat _priceFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  bool _favoriteChanged = false;

  @override
  void initState() {
    super.initState();
    context.read<ServiceDetailBloc>().add(FetchServiceDetail(widget.serviceId));
  }

  String _formatPrice(num? value) {
    if (value == null) return 'Chưa cập nhật';
    return _priceFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: BlocBuilder<ServiceDetailBloc, ServiceDetailState>(
            builder: (context, state) {
              if (state is ServiceDetailLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (state is ServiceDetailError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.error,
                    ),
                  ),
                );
              }

              if (state is ServiceDetailLoaded) {
                final s = state.service;
                final hasImage =
                    s.imageUrl != null && s.imageUrl!.trim().isNotEmpty;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            _backButton(context),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Chi tiết dịch vụ',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.pageTitle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CustomerFavoriteButton(
                              type: CustomerFavoriteType.service,
                              targetId: s.id,
                              initialIsFavorite: s.isFavorite ?? false,
                              removeConfirmTitle: 'Bỏ yêu thích',
                              removeConfirmMessage:
                                  'Bạn có chắc muốn bỏ dịch vụ này khỏi danh sách yêu thích không?',
                              onChanged: () {
                                _favoriteChanged = true;
                                if (mounted) {
                                  context.read<ServiceDetailBloc>().add(
                                        FetchServiceDetail(widget.serviceId),
                                      );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: AppDecorations.cardShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (hasImage)
                                  Image.network(
                                    s.imageUrl!.trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imagePlaceholder(),
                                  )
                                else
                                  _imagePlaceholder(),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        AppColors.overlay.withOpacity(0.72),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                  child: Row(
                                    children: [
                                      if (s.isFeatured)
                                        _pill(
                                          text: 'Nổi bật',
                                          bgColor: AppColors.overlay
                                              .withOpacity(0.58),
                                        ),
                                      if (s.isFeatured && s.isActive)
                                        const SizedBox(width: 8),
                                      if (s.isActive)
                                        _pill(
                                          text: 'Đang hoạt động',
                                          bgColor: AppColors.overlay
                                              .withOpacity(0.58),
                                        )
                                      else
                                        _pill(
                                          text: 'Tạm ngưng',
                                          bgColor: AppColors.danger
                                              .withOpacity(0.72),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.94),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.borderSoft),
                            boxShadow: AppDecorations.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: AppTextStyles.sectionTitle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.storeName.trim().isNotEmpty
                                    ? s.storeName
                                    : 'Chưa có tên cửa hàng',
                                style: AppTextStyles.bodyMuted.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _chip(
                                    label: _formatPrice(s.price),
                                  ),
                                  _chip(
                                    label: '${s.durationMinutes} phút',
                                  ),
                                  _chip(
                                    label: s.isActive ? 'Đang mở' : 'Đang đóng',
                                    valueColor: s.isActive
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.surface,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Thêm vào lịch hẹn',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: () {
                                    final storeId =
                                        (s.storeId is int) ? s.storeId : null;

                                    if (storeId == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Không xác định cửa hàng cho dịch vụ này',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final isLoggedIn = context
                                        .read<AuthBloc>()
                                        .state is AuthAuthenticated;

                                    if (!isLoggedIn) {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          backgroundColor:
                                              AppColors.surfaceSoft,
                                          title: const Text(
                                            'Bạn cần đăng nhập',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          content: const Text(
                                            'Vui lòng đăng nhập để đặt lịch.',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: const Text('Hủy'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(dialogContext);
                                                context.push(
                                                  '/login',
                                                  extra:
                                                      GoRouterState.of(context)
                                                          .uri
                                                          .toString(),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor:
                                                    AppColors.surface,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: const Text('Đăng nhập'),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingServicesPage(
                                          storeId: storeId,
                                          selectedServiceId: s.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if ((s.description ?? '').trim().isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionHeader('Mô tả dịch vụ'),
                              const SizedBox(height: 10),
                              _sectionCard(
                                child: Text(
                                  s.description!.trim(),
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Thông tin'),
                            const SizedBox(height: 10),
                            _sectionCard(
                              child: Column(
                                children: [
                                  _detailRow(
                                    title: 'Cửa hàng',
                                    value: s.storeName.trim().isNotEmpty
                                        ? s.storeName
                                        : 'Chưa có tên cửa hàng',
                                  ),
                                  const SizedBox(height: 12),
                                  _detailRow(
                                    title: 'Giá',
                                    value: _formatPrice(s.price),
                                  ),
                                  const SizedBox(height: 12),
                                  _detailRow(
                                    title: 'Thời lượng',
                                    value: '${s.durationMinutes} phút',
                                  ),
                                  const SizedBox(height: 12),
                                  _detailRow(
                                    title: 'Trạng thái',
                                    value: s.isActive
                                        ? 'Dịch vụ đang mở'
                                        : 'Dịch vụ tạm ngưng',
                                    valueColor: s.isActive
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppDecorations.heroGradient,
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.sectionTitle,
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.softShadow,
      ),
      child: child,
    );
  }

  Widget _detailRow({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: valueColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _pill({
    required String text,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.overlay.withOpacity(0.48),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.surface,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (context.canPop()) {
          context.pop(_favoriteChanged);
        } else {
          context.go('/');
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: AppDecorations.topBarShadow,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
