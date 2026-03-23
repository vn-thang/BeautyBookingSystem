import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/store_detail_bloc.dart';
import '../bloc/store_detail_event.dart';
import '../bloc/store_detail_state.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreDetailBloc>().add(FetchStoreDetail(widget.storeId));
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7FB),
              Color(0xFFFFEEF5),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<StoreDetailBloc, StoreDetailState>(
            builder: (context, state) {
              if (state is StoreDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is StoreDetailError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _iconCircle(
                              icon: Icons.share_outlined,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// BANNER SLIDER
                    /// BANNER SLIDER
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Container(
                          height: 210,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
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
                                                  Colors.black
                                                      .withOpacity(0.28),
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

                    /// AVATAR + NAME
                    /// AVATAR + NAME
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFFFDDE8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F1F24),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.storefront_rounded,
                                          size: 16,
                                          color: Colors.pink.shade400,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            s.address,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              height: 1.35,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
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

                    /// CONTENT
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((s.description ?? '').trim().isNotEmpty) ...[
                              _sectionHeader('Giới thiệu'),
                              const SizedBox(height: 10),
                              _sectionCard(
                                child: Text(
                                  s.description!.trim(),
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    height: 1.6,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
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
                                  _detailRow(
                                    icon: Icons.star_rounded,
                                    title: 'Đánh giá',
                                    value: s.averageRating != null
                                        ? '${s.averageRating!.toStringAsFixed(1)} / 5 • ${s.totalReviews ?? 0} lượt'
                                        : 'Chưa có đánh giá',
                                  ),
                                  const SizedBox(height: 14),
                                  _detailRow(
                                    icon: s.isOpen == true
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    title: 'Giờ hoạt động',
                                    value: s.isOpen == true
                                        ? 'Đang mở cửa'
                                        : 'Đang đóng cửa',
                                    valueColor: s.isOpen == true
                                        ? const Color(0xFF1E8E3E)
                                        : const Color(0xFFE25555),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
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
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFFDDE8),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      title: Text(
                                        sv.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1F1F24),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          '${sv.price} đ • ${sv.durationMinutes} phút',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFFE85E9C),
                                      ),
                                      onTap: () {
                                        context.push(
                                          '/service-detail/${sv.id}',
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 10),
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
            color: active ? Colors.white : Colors.white.withOpacity(0.45),
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
            Color(0xFFFFF4F8),
            Color(0xFFFFE1EC),
          ],
        ),
        border: Border.all(color: const Color(0xFFFFD1E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
      color: const Color(0xFFFFEEF5),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Color(0xFFFF6FAF),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1F1F24),
        ),
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
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFDDE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE1EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFFE85E9C),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            color: const Color(0xFFFFF4F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFE85E9C),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: valueColor ?? const Color(0xFF333333),
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
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD1E3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFFFF6FAF),
        ),
      ),
    );
  }

  Widget _iconCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD1E3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFE85E9C),
          ),
        ),
      ),
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE2EC),
            Color(0xFFFAD1DE),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: Color(0xFFB54C72),
          size: 44,
        ),
      ),
    );
  }
}
