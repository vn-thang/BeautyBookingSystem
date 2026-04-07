import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../../data/models/booking_models.dart';
import 'booking_detail_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool _loading = true;
  bool _openingDetail = false;
  String? _error;
  List<BookingItem> _bookings = [];

  int _selectedFilter = -1;
  final String _bookingsEndpoint = 'bookings';

  static const _filters = <({int value, String label})>[
    (value: -1, label: 'Tất cả'),
    (value: 0, label: 'Chờ xác nhận'),
    (value: 1, label: 'Đã xác nhận'),
    (value: 2, label: 'Hoàn thành'),
    (value: 3, label: 'Đã hủy'),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = di.sl<Dio>();
      final resp = await dio.get(_bookingsEndpoint);
      final data = resp.data;

      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['items'] is List) {
        items = data['items'] as List;
      } else if (data is Map && data['data'] is List) {
        items = data['data'] as List;
      } else {
        items = data != null ? [data] : [];
      }

      final parsed = items
          .whereType<Map>()
          .map((e) => BookingItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (!mounted) return;
      setState(() {
        _bookings = parsed;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.response?.data?.toString() ??
            e.message ??
            'Không thể tải dữ liệu';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async => _loadBookings();

  Future<void> _openBookingDetail(BookingItem item) async {
    if (_openingDetail) return;
    _openingDetail = true;
    try {
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => BookingDetailPage(
            bookingId: item.id,
            initialBooking: item,
          ),
        ),
      );
      if (!mounted) return;
      if (changed == true) {
        await _loadBookings();
      }
    } finally {
      _openingDetail = false;
    }
  }

  List<BookingItem> get _filteredBookings {
    if (_selectedFilter == -1) return _bookings;
    return _bookings.where((e) => e.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    _backButton(),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lịch đặt của tôi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Theo dõi đơn đặt lịch và thanh toán',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final selected = filter.value == _selectedFilter;
                      final count = switch (filter.value) {
                        -1 => _bookings.length,
                        0 => _bookings.where((e) => e.status == 0).length,
                        1 => _bookings.where((e) => e.status == 1).length,
                        2 => _bookings.where((e) => e.status == 2).length,
                        3 => _bookings.where((e) => e.status == 3).length,
                        _ => 0,
                      };

                      return ChoiceChip(
                        label: Text('${filter.label} ($count)'),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter.value),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        side: BorderSide(
                          color:
                              selected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _error != null
                        ? _buildError()
                        : bookings.isEmpty
                            ? _buildEmpty()
                            : RefreshIndicator(
                                color: AppColors.primary,
                                onRefresh: _onRefresh,
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  itemCount: bookings.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = bookings[index];
                                    return _BookingCard(
                                      item: item,
                                      onTap: _openingDetail
                                          ? null
                                          : () => _openBookingDetail(item),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có lịch đặt nào',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn sẽ thấy toàn bộ đơn đặt lịch tại đây sau khi tạo booking.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted.copyWith(height: 1.45),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Khám phá dịch vụ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Không thể tải lịch đặt',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Đã xảy ra lỗi không xác định.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadBookings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.topBarShadow,
      ),
      child: IconButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 17,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingItem item;
  final VoidCallback? onTap;

  const _BookingCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(item.status);
    final firstService = item.services.isNotEmpty ? item.services.first : null;
    final appointmentText = item.appointmentText;
    final serviceSummary = item.effectiveServiceSummary;
    final serviceCount = item.extraServiceCount;
    final staffName = (item.staffName ?? firstService?.staffName ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StoreAvatar(
                      avatarUrl: (item.storeAvatarUrl ?? '').trim(),
                      name: item.storeName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.storeName?.trim().isNotEmpty == true
                                      ? item.storeName!
                                      : 'Booking #${item.id}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: 15.5,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _StatusChip(
                                label: statusInfo.label,
                                color: statusInfo.color,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            serviceSummary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMuted.copyWith(
                              fontSize: 13.2,
                              height: 1.35,
                            ),
                          ),
                          if (staffName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Nhân viên: $staffName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(text: appointmentText),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Column(
                    children: [
                      _MoneyLine(
                        label: 'Tổng tiền',
                        value: item.finalPrice,
                      ),
                      const SizedBox(height: 8),
                      if (item.depositAmount > 0 &&
                          item.paidAmountFromApi == 0) ...[
                        _MoneyLine(
                          label: 'Tiền cọc',
                          value: item.depositAmount,
                        ),
                        const SizedBox(height: 8),
                      ],
                      _MoneyLine(
                        label: 'Đã thanh toán',
                        value: item.paidAmountFromApi,
                      ),
                      const Divider(height: 20),
                      _MoneyLine(
                        label: 'Còn lại',
                        value: item.remainingAmountFromApi,
                        emphasis: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({String label, Color color}) _statusInfo(int status) {
    switch (status) {
      case 0:
        return (label: 'Chờ xác nhận', color: AppColors.warning);
      case 1:
        return (label: 'Đã xác nhận', color: AppColors.success);
      case 2:
        return (label: 'Hoàn thành', color: AppColors.secondary);
      case 3:
        return (label: 'Đã hủy', color: AppColors.danger);
      default:
        return (label: 'Không rõ', color: AppColors.textSecondary);
    }
  }
}

class _StoreAvatar extends StatelessWidget {
  final String avatarUrl;
  final String? name;

  const _StoreAvatar({
    required this.avatarUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        (name ?? '').trim().isNotEmpty ? name!.trim()[0].toUpperCase() : 'B';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.primary.withValues(alpha: 0.10),
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MoneyLine extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasis;

  const _MoneyLine({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: emphasis ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)} VND',
          style: AppTextStyles.body.copyWith(
            fontSize: 13.5,
            fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
            color: emphasis ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
