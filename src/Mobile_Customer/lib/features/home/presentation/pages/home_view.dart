import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../../core/widgets/network_image_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  StreamSubscription? _authSub;

  final PageController _bannerController =
      PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _currentIndex = 0;
  int _bannerLength = 0;

  final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  String _resolveImage(String? url) {
    if (url == null || url.isEmpty) return '';
    return url;
  }

  Future<void> _refreshHomeIfNeeded(bool? changed) async {
    if (changed == true && mounted) {
      context.read<HomeBloc>().add(LoadHomeEvent(forceRefresh: true));
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<HomeBloc>().add(LoadHomeEvent());

    final authBloc = context.read<AuthBloc>();
    _authSub = authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        context.read<HomeBloc>().add(LoadHomeEvent(forceRefresh: true));
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients || _bannerLength <= 1) return;

      final next = (_currentIndex + 1) % _bannerLength;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is HomeLoaded) {
            return _buildContent(context, state);
          }

          if (state is HomeError) {
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    final data = state.data;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppDecorations.pageGradient,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, state.locationName)),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: _buildBanners(context, data.systemContents),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _sectionHeader(context, 'Danh mục')),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildCategories(context, data.categories)),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(child: _sectionHeader(context, 'Dịch vụ')),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: _buildServiceScroller(context, data.serviceGroups),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: _buildStoreHorizontalSection(
              context,
              title: 'Cửa hàng yêu thích',
              stores: data.favoriteStores,
              showViewAll: false,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildServiceHorizontalSection(
              context,
              title: 'Dịch vụ yêu thích',
              services: data.favoriteServices,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildStoreHorizontalSection(
              context,
              title: 'Cửa hàng gần bạn',
              stores: data.nearbyStores,
              onViewAll: () {
                context.push(
                  '/search',
                  extra: {'sortMode': 'nearest'},
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _buildStoreHorizontalSection(
              context,
              title: 'Cửa hàng được đánh giá cao',
              stores: data.topRatedStores,
              onViewAll: () {
                context.push(
                  '/search',
                  extra: {'sortMode': 'topRated'},
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(child: _sectionHeader(context, 'Khuyến mãi')),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(child: _buildVouchers(context, data.vouchers)),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(title, style: AppTextStyles.sectionTitle),
    );
  }

  Widget _buildHeader(BuildContext context, String? locationNameFromHome) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        gradient: AppDecorations.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: AppDecorations.topBarShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(11),
              boxShadow: AppDecorations.avatarShadow,
            ),
            child: const Icon(
              Icons.place_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Text(
                locationNameFromHome ?? 'Bạn đang ở đâu?',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tìm theo tên cửa hàng, dịch vụ...',
                  style: AppTextStyles.bodyMuted,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: const Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanners(BuildContext context, List systemContents) {
    final banners = systemContents
        .where((e) => e.type == 5 && e.isActive == true)
        .map<String>((e) => (e.content ?? '').toString())
        .where((url) => url.isNotEmpty)
        .toList();

    _bannerLength = banners.length;

    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: banners.length,
        onPageChanged: (index) {
          if (!mounted) return;
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final url = banners[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppDecorations.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  _resolveImage(url),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: AppDecorations.heroGradient,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List categories) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = categories[index];

          return GestureDetector(
            onTap: () {
              context.pushNamed(
                'category',
                pathParameters: {'id': item.id.toString()},
                extra: item.name,
              );
            },
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.surface,
                          AppColors.surfaceSoft,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSoft),
                      boxShadow: AppDecorations.softShadow,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: NetworkImageWidget(
                          imageUrl: _resolveImage(item.iconUrl),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
      ),
    );
  }

  Widget _buildServiceScroller(BuildContext context, List serviceGroups) {
    if (serviceGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final bool isLast = index == serviceGroups.length;

          if (isLast) {
            return GestureDetector(
              onTap: () => _showAllServicesSheet(context, serviceGroups),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Tất cả',
                  style: AppTextStyles.chip,
                ),
              ),
            );
          }

          final g = serviceGroups[index];
          return GestureDetector(
            onTap: () => context.pushNamed(
              'service_group',
              pathParameters: {'id': g.id.toString()},
              extra: g.name,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderSoft),
                boxShadow: AppDecorations.softShadow,
              ),
              child: Text(
                g.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMuted.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: serviceGroups.length + 1,
      ),
    );
  }

  void _showAllServicesSheet(BuildContext context, List serviceGroups) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tất cả dịch vụ',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3.6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: serviceGroups.length,
                      itemBuilder: (context, index) {
                        final g = serviceGroups[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            context.pushNamed(
                              'service_group',
                              pathParameters: {'id': g.id.toString()},
                              extra: g.name,
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSoft),
                              boxShadow: AppDecorations.softShadow,
                            ),
                            child: Text(
                              g.name,
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHorizontalSection({
    required BuildContext context,
    required String title,
    required List items,
    required Widget Function(BuildContext context, dynamic item) itemBuilder,
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final displayItems = items.take(10).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppDecorations.softShadow, // làm mềm đường ngang nền
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTextStyles.sectionTitle),
                ),
                if (showViewAll)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Xem tất cả',
                      style: AppTextStyles.chip.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 225,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              itemCount: displayItems.length + (showViewAll ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                if (showViewAll && index == displayItems.length) {
                  return _viewAllStoreCard(onViewAll ?? () {});
                }
                return itemBuilder(context, displayItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHorizontalSection(
    BuildContext context, {
    required String title,
    required List stores,
    bool showViewAll = true,
    VoidCallback? onViewAll,
  }) {
    return _buildHorizontalSection(
      context: context,
      title: title,
      items: stores,
      showViewAll: showViewAll,
      onViewAll: onViewAll,
      itemBuilder: (context, s) => _storeCardHorizontal(context, s),
    );
  }

  Widget _buildServiceHorizontalSection(
    BuildContext context, {
    required String title,
    required List services,
  }) {
    return _buildHorizontalSection(
      context: context,
      title: title,
      items: services,
      itemBuilder: (context, s) {
        return GestureDetector(
          onTap: () async {
            final changed = await context.push<bool>('/service-detail/${s.id}');
            await _refreshHomeIfNeeded(changed);
          },
          child: Container(
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSoft),
              boxShadow: AppDecorations.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 102,
                    width: double.infinity,
                    child: NetworkImageWidget(
                      imageUrl: _resolveImage(s.imageUrl),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.storeName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMuted.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (s.price != null)
                            Text(
                              _vndFormat.format(s.price),
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
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

  Widget _viewAllStoreCard(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: AppDecorations.softShadow,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(height: 8),
              Text(
                'Xem tất cả',
                style: AppTextStyles.chip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeCardHorizontal(BuildContext context, dynamic s) {
    final coverUrl = _resolveImage(s.coverImageUrl ?? s.logoUrl);

    final double rating = (s.averageRating ?? 0).toDouble();
    final int reviewCount = (s.totalReviews ?? 0);
    final double? distanceKm = (s.distanceKm as num?)?.toDouble();

    return GestureDetector(
      onTap: () async {
        final changed = await context.push<bool>('/store/${s.id}');
        await _refreshHomeIfNeeded(changed);
      },
      child: Container(
        width: 180,
        height: 207,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 94,
                width: double.infinity,
                child: NetworkImageWidget(imageUrl: coverUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        s.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviewCount)',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            distanceKm != null
                                ? '${s.address ?? ''} • ${distanceKm.toStringAsFixed(1)} km'
                                : (s.address ?? ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVouchers(
    BuildContext context,
    List vouchers,
  ) {
    if (vouchers.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppDecorations.softShadow,
      ),
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vouchers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, index) {
            final v = vouchers[index];
            final String imageUrl = _resolveImage(v.imageUrl);

            final String serviceName = (v.serviceName ?? '').toString();
            final double originalPrice = (v.originalPrice ?? 0).toDouble();
            final double discountValue = (v.discountValue ?? 0).toDouble();

            final bool isPercent =
                v.discountType == 0 || v.discountType == true;

            final double discountPercent = isPercent
                ? discountValue
                : (originalPrice > 0
                    ? (discountValue / originalPrice) * 100
                    : 0);

            final double finalPrice = isPercent
                ? originalPrice * (1 - discountValue / 100)
                : (originalPrice - discountValue).clamp(0, double.infinity);

            final String discountLabel =
                '${discountPercent.toStringAsFixed(0)}%';

            return GestureDetector(
              onTap: () => context.push('/service-detail/${v.serviceId}'),
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSoft),
                  boxShadow: AppDecorations.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: AppDecorations.heroGradient,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: AppColors.primary,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      gradient: AppDecorations.heroGradient,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.local_offer_outlined,
                                      color: AppColors.primary,
                                      size: 34,
                                    ),
                                  ),
                            if (discountPercent > 0)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger
                                        .withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: AppDecorations.softShadow,
                                  ),
                                  child: Text(
                                    '-$discountLabel',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              serviceName.isNotEmpty ? serviceName : v.code,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _vndFormat.format(originalPrice),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 1.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _vndFormat.format(finalPrice),
                              style: AppTextStyles.body.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.danger,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
