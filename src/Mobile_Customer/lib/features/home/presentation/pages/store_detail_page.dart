import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/features/customer_favorite/presentation/widgets/customer_favorite_button.dart';
import '../../../customer_favorite/presentation/bloc/customer_favorite_bloc.dart';
import '../../../store_reviews/presentation/bloc/store_reviews_bloc.dart';
import '../../data/models/store_model.dart';
import '../bloc/store_detail_bloc.dart';
import '../bloc/store_detail_event.dart';
import '../bloc/store_detail_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_decorations.dart';

class StoreDetailPage extends StatefulWidget {
  final int storeId;
  final String? storeName;

  const StoreDetailPage({
    super.key,
    required this.storeId,
    this.storeName,
  });

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  bool _favoriteChanged = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    if (!_loaded) {
      _loaded = true;
      context.read<StoreDetailBloc>().add(FetchStoreDetail(widget.storeId));
    }

    context.read<StoreReviewsBloc>().add(
          LoadStoreReviews(
            storeId: widget.storeId,
            page: 1,
            pageSize: 5,
          ),
        );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  int _apiDayOfWeek(DateTime now) {
    return now.weekday == DateTime.sunday ? 0 : now.weekday;
  }

  int _timeToMinutes(String time) {
    final parts = time.trim().split(':');
    if (parts.length < 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  String _formatTime(String time) {
    final t = time.trim();
    if (t.isEmpty) return 'Chưa cập nhật';
    final parts = t.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return t;
  }

  String _dayName(int day) {
    switch (day) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 0:
        return 'Chủ nhật';
      default:
        return 'Không rõ';
    }
  }

  int _sortDay(int day) => day == 0 ? 7 : day;

  OperatingHourModel? _todayOperatingHour(List<OperatingHourModel> hours) {
    final today = _apiDayOfWeek(DateTime.now());
    for (final h in hours) {
      if (h.dayOfWeek == today) return h;
    }
    return null;
  }

  bool _isStoreOpenNow(List<OperatingHourModel> hours) {
    final todayHour = _todayOperatingHour(hours);
    if (todayHour == null) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final openMinutes = _timeToMinutes(todayHour.openTime);
    final closeMinutes = _timeToMinutes(todayHour.closeTime);

    if (closeMinutes > openMinutes) {
      return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
    } else if (closeMinutes < openMinutes) {
      return currentMinutes >= openMinutes || currentMinutes < closeMinutes;
    }
    return false;
  }

  String _todayRange(List<OperatingHourModel> hours) {
    final todayHour = _todayOperatingHour(hours);
    if (todayHour == null) return 'Chưa cập nhật';
    return '${_formatTime(todayHour.openTime)} - ${_formatTime(todayHour.closeTime)}';
  }

  String _openStatusText(List<OperatingHourModel> hours) {
    return _isStoreOpenNow(hours) ? 'Đang mở cửa' : 'Đang đóng cửa';
  }

  final NumberFormat _moneyFormat = NumberFormat('#,##0', 'vi_VN');

  String _formatMoney(num value) {
    return '${_moneyFormat.format(value)} đ';
  }

  void _showOperatingHoursSheet(
    BuildContext context,
    List<OperatingHourModel> hours,
  ) {
    final sortedHours = [...hours]
      ..sort((a, b) => _sortDay(a.dayOfWeek).compareTo(_sortDay(b.dayOfWeek)));

    final isOpenNow = _isStoreOpenNow(hours);
    final todayHour = _todayOperatingHour(hours);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        final sheetHeight = MediaQuery.of(context).size.height * 2 / 3;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: sheetHeight,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Giờ hoạt động của shop',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isOpenNow
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.danger.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isOpenNow
                            ? AppColors.success.withOpacity(0.22)
                            : AppColors.danger.withOpacity(0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOpenNow
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color:
                              isOpenNow ? AppColors.success : AppColors.danger,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isOpenNow
                                ? 'Shop đang mở cửa'
                                : 'Shop hiện đang đóng cửa',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isOpenNow
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                        if (todayHour != null)
                          Text(
                            '${_formatTime(todayHour.openTime)} - ${_formatTime(todayHour.closeTime)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: sortedHours.isEmpty
                        ? Center(
                            child: Text(
                              'Chưa cập nhật giờ hoạt động',
                              style: AppTextStyles.bodyMuted,
                            ),
                          )
                        : ListView.builder(
                            itemCount: sortedHours.length,
                            itemBuilder: (context, index) {
                              final e = sortedHours[index];
                              final isToday =
                                  e.dayOfWeek == _apiDayOfWeek(DateTime.now());

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppColors.surfaceSoft
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isToday
                                        ? AppColors.border
                                        : AppColors.borderSoft,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.placeholderStart
                                            .withOpacity(0.28),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.schedule_rounded,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _dayName(e.dayOfWeek),
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_formatTime(e.openTime)} - ${_formatTime(e.closeTime)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_favoriteChanged);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppDecorations.pageGradient,
          ),
          child: SafeArea(
            child: BlocBuilder<StoreDetailBloc, StoreDetailState>(
              builder: (context, state) {
                if (state is StoreDetailLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is StoreDetailError) {
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

                if (state is StoreDetailLoaded) {
                  final s = state.store;
                  final banners = s.banners;

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Row(
                            children: [
                              _backButton(context),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  s.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.pageTitle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              CustomerFavoriteButton(
                                type: CustomerFavoriteType.store,
                                targetId: widget.storeId,
                                initialIsFavorite: s.isFavorite ?? false,
                                removeConfirmTitle: 'Bỏ yêu thích',
                                removeConfirmMessage:
                                    'Bạn có chắc muốn bỏ store này khỏi danh sách yêu thích không?',
                                onChanged: () {
                                  _favoriteChanged = true;
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
                            height: 210,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: AppDecorations.cardShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Stack(
                                children: [
                                  if (banners.isNotEmpty)
                                    PageView.builder(
                                      controller: _bannerController,
                                      itemCount: banners.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _bannerIndex = index;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final banner = banners[index];
                                        final imageUrl = banner.imageUrl.trim();

                                        return Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _bannerPlaceholder(),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    AppColors.overlay
                                                        .withOpacity(0.30),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  else
                                    _bannerPlaceholder(),
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 14,
                                    child: Row(
                                      children: [
                                        if (banners.isNotEmpty)
                                          _bannerIndicator(banners.length),
                                        const Spacer(),
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.borderSoft),
                              boxShadow: AppDecorations.cardShadow,
                            ),
                            child: Row(
                              children: [
                                _storeAvatar(
                                  logoUrl: s.logoUrl,
                                  name: s.name,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.sectionTitle,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.storefront_rounded,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              s.address,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.bodyMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 18,
                                            color: AppColors.warning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            s.averageRating != null
                                                ? '${s.averageRating!.toStringAsFixed(1)} / 5'
                                                : 'Chưa có đánh giá',
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '• ${s.totalReviews ?? 0} lượt',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionHeader('Dịch vụ'),
                              const SizedBox(height: 10),
                              if (s.services.isEmpty)
                                _sectionCard(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      child: Text(
                                        'Hiện chưa có dịch vụ nào',
                                        style: AppTextStyles.bodyMuted,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: s.services.map((sv) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.borderSoft,
                                        ),
                                        boxShadow: AppDecorations.softShadow,
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        title: Text(
                                          sv.name,
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Text(
                                            '${_formatMoney(sv.price)} • ${sv.durationMinutes} phút',
                                            style: AppTextStyles.caption,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                        onTap: () async {
                                          final changed =
                                              await context.push<bool>(
                                            '/service-detail/${sv.id}',
                                          );
                                          if (changed == true) {
                                            _favoriteChanged = true;
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 18),
                              _sectionHeader('Thông tin liên hệ'),
                              const SizedBox(height: 10),
                              _sectionCard(
                                child: Column(
                                  children: [
                                    _detailRow(
                                      icon: Icons.phone_in_talk_rounded,
                                      title: 'Điện thoại',
                                      value: (s.phone != null &&
                                              s.phone!.trim().isNotEmpty)
                                          ? s.phone!.trim()
                                          : 'Chưa cập nhật',
                                    ),
                                    const SizedBox(height: 14),
                                    _detailRow(
                                      icon: Icons.location_on_rounded,
                                      title: 'Địa chỉ',
                                      value: s.address.trim().isNotEmpty
                                          ? s.address.trim()
                                          : 'Chưa cập nhật',
                                    ),
                                    const SizedBox(height: 14),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () {
                                        _showOperatingHoursSheet(
                                          context,
                                          s.operatingHours,
                                        );
                                      },
                                      child: _detailRow(
                                        icon: Icons.schedule_rounded,
                                        title: 'Giờ hoạt động',
                                        value:
                                            '${_openStatusText(s.operatingHours)} • ${_todayRange(s.operatingHours)}',
                                        valueColor:
                                            _isStoreOpenNow(s.operatingHours)
                                                ? AppColors.success
                                                : AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              BlocBuilder<StoreReviewsBloc, StoreReviewsState>(
                                builder: (context, reviewState) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _sectionHeader('Đánh giá từ booking'),
                                      const SizedBox(height: 10),
                                      _sectionCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Đánh giá gần nhất',
                                                    style: TextStyle(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    context.push(
                                                      '/store-reviews/${widget.storeId}?name=${Uri.encodeComponent(s.name)}',
                                                    );
                                                  },
                                                  child:
                                                      const Text('Xem tất cả'),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            if (reviewState
                                                is StoreReviewsLoading)
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              )
                                            else if (reviewState
                                                is StoreReviewsError)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                                child: Text(
                                                  reviewState.message,
                                                  style: TextStyle(
                                                    color: AppColors.danger,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            else if (reviewState
                                                    is StoreReviewsLoaded &&
                                                reviewState.items.isNotEmpty)
                                              Column(
                                                children: reviewState.items
                                                    .take(5)
                                                    .map((r) {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 10,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.surfaceSoft,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        16,
                                                      ),
                                                      border: Border.all(
                                                        color: AppColors
                                                            .borderSoft,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 16,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .placeholderStart
                                                                      .withOpacity(
                                                                0.35,
                                                              ),
                                                              backgroundImage: (r
                                                                              .customer
                                                                              .avatarUrl !=
                                                                          null &&
                                                                      r.customer
                                                                          .avatarUrl!
                                                                          .trim()
                                                                          .isNotEmpty)
                                                                  ? NetworkImage(
                                                                      r.customer
                                                                          .avatarUrl!
                                                                          .trim(),
                                                                    )
                                                                  : null,
                                                              child: (r.customer
                                                                              .avatarUrl ==
                                                                          null ||
                                                                      r.customer
                                                                          .avatarUrl!
                                                                          .trim()
                                                                          .isEmpty)
                                                                  ? Text(
                                                                      _initials(
                                                                        r.customer
                                                                            .fullName,
                                                                      ),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                        color: AppColors
                                                                            .primary,
                                                                      ),
                                                                    )
                                                                  : null,
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                r.customer
                                                                    .fullName,
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: AppColors
                                                                      .textPrimary,
                                                                ),
                                                              ),
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .star_rounded,
                                                              size: 18,
                                                              color: AppColors
                                                                  .warning,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              r.rating
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if ((r.comment ?? '')
                                                            .trim()
                                                            .isNotEmpty) ...[
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            r.comment!.trim(),
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: AppTextStyles
                                                                .bodyMuted,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              )
                                            else
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                                child: Text(
                                                  'Chưa có đánh giá nào',
                                                  style:
                                                      AppTextStyles.bodyMuted,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              _sectionHeader('Giới thiệu'),
                              const SizedBox(height: 10),
                              if ((s.description ?? '').trim().isNotEmpty)
                                _sectionCard(
                                  child: Text(
                                    s.description!.trim(),
                                    style: AppTextStyles.body,
                                  ),
                                )
                              else
                                _sectionCard(
                                  child: Text(
                                    'Chưa có giới thiệu cho shop này',
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerIndicator(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = index == _bannerIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 4),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? AppColors.surface
                : AppColors.surface.withOpacity(0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  Widget _storeAvatar({
    required String? logoUrl,
    required String name,
  }) {
    final hasLogo = logoUrl != null && logoUrl.trim().isNotEmpty;

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.placeholderStart,
            AppColors.placeholderEnd,
          ],
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.avatarShadow,
      ),
      child: ClipOval(
        child: hasLogo
            ? Image.network(
                logoUrl!.trim(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(name),
              )
            : _avatarFallback(name),
      ),
    );
  }

  Widget _avatarFallback(String name) {
    final initials = _initials(name);
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _initials(String name) {
    final source = name.trim();
    if (source.isEmpty) return 'S';

    final parts =
        source.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return source[0].toUpperCase();
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return (parts.first[0] + parts.last[0]).toUpperCase();
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
        color: AppColors.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.softShadow,
      ),
      child: child,
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).pop(_favoriteChanged),
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

  Widget _bannerPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppDecorations.heroGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: AppColors.primary,
          size: 44,
        ),
      ),
    );
  }
}
