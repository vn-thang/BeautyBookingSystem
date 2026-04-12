import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../customer_favorite/presentation/bloc/customer_favorite_bloc.dart';
import '../../../customer_favorite/presentation/widgets/customer_favorite_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/data/datasources/home_remote_datasource.dart';
import '../../../home/domain/entities/favorite_service.dart';
import '../../../home/domain/entities/favorite_store.dart';

class FavoritesPage extends StatefulWidget {
  final HomeRemoteDataSource homeRemoteDataSource;

  const FavoritesPage({
    super.key,
    required this.homeRemoteDataSource,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<_FavoriteBundle> future;

  @override
  void initState() {
    super.initState();
    future = _loadFavoriteData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Danh sách yêu thích",
                      style: AppTextStyles.sectionTitle,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: FutureBuilder<_FavoriteBundle>(
                    future: future,
                    builder: (context, snapshot) {
                      final loading =
                          snapshot.connectionState == ConnectionState.waiting;
                      final error = snapshot.hasError;
                      final data = snapshot.data;

                      void reloadFavorites() {
                        setState(() {
                          future = _loadFavoriteData();
                        });
                      }

                      return Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Yêu thích",
                                style: AppTextStyles.sectionTitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              tabs: [
                                Tab(text: "Cửa hàng"),
                                Tab(text: "Dịch vụ"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: error
                                ? _favoriteErrorState()
                                : loading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : TabBarView(
                                        children: [
                                          _favoriteStoreList(
                                            context,
                                            data?.stores ?? const [],
                                            reloadFavorites,
                                          ),
                                          _favoriteServiceList(
                                            context,
                                            data?.services ?? const [],
                                            reloadFavorites,
                                          ),
                                        ],
                                      ),
                          ),
                        ],
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

  Future<_FavoriteBundle> _loadFavoriteData() async {
    final response = await widget.homeRemoteDataSource.getHomeFavorites();

    final storeList = (response['favoriteStores'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (json) => FavoriteStore(
            id: (json['id'] as num).toInt(),
            name: json['name']?.toString() ?? '',
            address: json['address']?.toString(),
            logoUrl: json['logoUrl']?.toString(),
            coverImageUrl: json['coverImageUrl']?.toString(),
            averageRating: (json['averageRating'] as num?)?.toDouble(),
            totalReviews: (json['totalReviews'] as num?)?.toInt(),
            distanceKm: (json['distanceKm'] as num?)?.toDouble(),
          ),
        )
        .toList();

    final serviceList = (response['favoriteServices'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (json) => FavoriteService(
            id: (json['id'] as num).toInt(),
            name: json['name']?.toString() ?? '',
            imageUrl: json['imageUrl']?.toString(),
            price: (json['price'] as num?)?.toDouble(),
            storeId: (json['storeId'] as num?)?.toInt(),
            storeName: json['storeName']?.toString(),
          ),
        )
        .toList();

    return _FavoriteBundle(
      stores: storeList,
      services: serviceList,
    );
  }

  Widget _favoriteErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _favoriteEmptyCard(
        icon: Icons.error_outline_rounded,
        title: "Không tải được dữ liệu yêu thích",
        subtitle: "Vui lòng thử lại sau.",
      ),
    );
  }

  Widget _favoriteEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _favoriteStoreList(
    BuildContext context,
    List<FavoriteStore> stores,
    VoidCallback onChanged,
  ) {
    if (stores.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          _favoriteEmptyCard(
            icon: Icons.storefront_outlined,
            title: "Chưa có cửa hàng yêu thích",
            subtitle: "Các cửa hàng bạn lưu sẽ hiển thị ở đây.",
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: stores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = stores[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/store/${item.id}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSoft),
                boxShadow: AppDecorations.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: item.coverImageUrl != null &&
                              item.coverImageUrl!.isNotEmpty
                          ? Image.network(
                              item.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.address ?? "Chưa có địa chỉ",
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.averageRating != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            "⭐ ${item.averageRating!.toStringAsFixed(1)}"
                            "${item.totalReviews != null ? " (${item.totalReviews})" : ""}",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomerFavoriteButton(
                    type: CustomerFavoriteType.store,
                    targetId: item.id,
                    initialIsFavorite: true,
                    removeConfirmTitle: "Bỏ yêu thích cửa hàng?",
                    removeConfirmMessage:
                        "Bạn có muốn bỏ '${item.name}' khỏi danh sách yêu thích không?",
                    onChanged: onChanged,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _favoriteServiceList(
    BuildContext context,
    List<FavoriteService> services,
    VoidCallback onChanged,
  ) {
    if (services.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          _favoriteEmptyCard(
            icon: Icons.spa_outlined,
            title: "Chưa có dịch vụ yêu thích",
            subtitle: "Các dịch vụ bạn lưu sẽ hiển thị ở đây.",
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = services[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/service-detail/${item.id}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSoft),
                boxShadow: AppDecorations.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.spa_rounded,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.spa_rounded,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.storeName ?? "Chưa rõ cửa hàng",
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.price != null
                              ? "${item.price!.toStringAsFixed(0)} đ"
                              : "Liên hệ",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomerFavoriteButton(
                    type: CustomerFavoriteType.service,
                    targetId: item.id,
                    initialIsFavorite: true,
                    removeConfirmTitle: "Bỏ yêu thích dịch vụ?",
                    removeConfirmMessage:
                        "Bạn có muốn bỏ '${item.name}' khỏi danh sách yêu thích không?",
                    onChanged: onChanged,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteBundle {
  final List<FavoriteStore> stores;
  final List<FavoriteService> services;

  const _FavoriteBundle({
    required this.stores,
    required this.services,
  });
}
