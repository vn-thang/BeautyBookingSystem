// lib/features/home/presentation/pages/home_view.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/features/home/data/datasources/home_remote_datasource_impl.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../../../../core/widgets/network_image_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const Color _pink1 = Color(0xFFFF5C8A);
  static const Color _pink2 = Color(0xFFFF7DA8);
  static const Color _bg = Color(0xFFFFF5F7);

  final PageController _bannerController =
      PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _currentIndex = 0;
  int _bannerLength = 0;

  String _resolveImage(String? url) {
    if (url == null || url.isEmpty) return '';
    return url; // backend trả full URL Cloudinary
  }

  @override
  void initState() {
    super.initState();

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
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return _buildContent(context, state);
          } else if (state is HomeError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
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
      color: _bg,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, state.locationName)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
              child: _buildBanners(context, data.systemContents)),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Danh mục', style: _sectionTitleStyle()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildCategories(context, data.categories)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Dịch vụ', style: _sectionTitleStyle()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
              child: _buildServiceScroller(context, data.serviceGroups)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _buildStoreHorizontalSection(
              context,
              title: 'Cửa hàng gần bạn',
              stores: data.nearbyStores,
              onViewAll: () {
                context.push(
                  '/search',
                  extra: {
                    'sortMode': 'nearest',
                  },
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
                  extra: {
                    'sortMode': 'topRated',
                  },
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Khuyến mãi', style: _sectionTitleStyle()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _buildVouchers(
              context,
              data.vouchers,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildBanners(BuildContext context, List systemContents) {
    final banners = systemContents
        .where((e) => e.type == 0 && e.isActive == true)
        .map<String>((e) => e.content.toString())
        .where((url) => url.isNotEmpty)
        .toList();

    _bannerLength = banners.length;

    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150,
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
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  _resolveImage(url),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFFFF0F2),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: _pink1,
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

  Widget _buildHeader(BuildContext context, String? locationNameFromHome) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_pink1, _pink2]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationNameFromHome ?? 'Bạn đang ở đâu?',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tìm theo tên cửa hàng, dịch vụ...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Icon(Icons.mic, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List categories) {
    return SizedBox(
      height: 92,
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
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFF0F2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 0,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: NetworkImageWidget(
                          imageUrl: _resolveImage(item.iconUrl),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
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
    if (serviceGroups == null || serviceGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
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
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _pink1.withOpacity(0.18)),
                ),
                child: const Text(
                  'Tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _pink1,
                  ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                g.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tất cả dịch vụ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              g.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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

  Widget _storeCard(BuildContext context, dynamic s) {
    return GestureDetector(
      onTap: () => context.push('/store/${s.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: NetworkImageWidget(
                    imageUrl: _resolveImage(s.logoUrl),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.address ?? '',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _pink1.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(s.distanceKm ?? 0).toStringAsFixed(1)} km",
                  style: const TextStyle(
                    color: _pink1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreHorizontalSection(
    BuildContext context, {
    required String title,
    required List stores,
    required VoidCallback onViewAll,
  }) {
    if (stores.isEmpty) return const SizedBox.shrink();

    final displayStores = stores.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: _sectionTitleStyle()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260, // tăng nhẹ
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.fromLTRB(16, 4, 16, 16), // thêm bottom padding
            itemCount: displayStores.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              if (index == displayStores.length) {
                return _viewAllStoreCard(onViewAll);
              }
              return _storeCardHorizontal(context, displayStores[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _viewAllStoreCard(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward_ios_rounded, color: _pink1),
              SizedBox(height: 8),
              Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _pink1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeCardHorizontal(BuildContext context, dynamic s) {
    final coverUrl = _resolveImage(
      s.coverImageUrl ?? s.logoUrl,
    );

    final double rating = (s.averageRating ?? 0).toDouble();
    final int reviewCount = (s.totalReviews ?? 0);
    final double distanceKm = (s.distanceKm ?? 0).toDouble();

    return GestureDetector(
      onTap: () => context.push('/store/${s.id}'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: NetworkImageWidget(imageUrl: coverUrl),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviewCount)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${s.address ?? ''} • ${distanceKm.toStringAsFixed(1)} km',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
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

    String formatMoney(num value) {
      final s = value.toStringAsFixed(0);
      final parts = s.split('.');
      final integer = parts[0];
      final buffer = StringBuffer();

      for (int i = 0; i < integer.length; i++) {
        final reverseIndex = integer.length - i - 1;
        buffer.write(integer[reverseIndex]);
        if (i % 3 == 2 && i != integer.length - 1) {
          buffer.write('.');
        }
      }

      return '${buffer.toString().split('').reversed.join()} đ';
    }

    const discountedColor = Color(0xFFE53935);

    return SizedBox(
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
          final double discountedPrice = (v.discountedPrice ?? 0).toDouble();

          return GestureDetector(
            onTap: () => context.push('/voucher/${v.id}'),
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFFFF0F2),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: _pink1,
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFFFF0F2),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.local_offer_outlined,
                                color: _pink1,
                                size: 34,
                              ),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              serviceName.isNotEmpty ? serviceName : v.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatMoney(originalPrice),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 1.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatMoney(discountedPrice),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: discountedColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
      ),
    );
  }

  TextStyle _sectionTitleStyle() => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      );
}
