import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/category_store_bloc.dart';
import '../bloc/category_store_event.dart';
import '../bloc/category_store_state.dart';
import '../../data/models/store_model.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_decorations.dart';

class CategoryStoresView extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryStoresView({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryStoresView> createState() => _CategoryStoresViewState();
}

class _CategoryStoresViewState extends State<CategoryStoresView> {
  @override
  void initState() {
    super.initState();
    context
        .read<CategoryStoreBloc>()
        .add(FetchCategoryStores(widget.categoryId));
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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSoft),
                          boxShadow: AppDecorations.topBarShadow,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 17,
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
                            widget.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Danh sách cửa hàng thuộc danh mục này',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<CategoryStoreBloc, CategoryStoreState>(
                  builder: (context, state) {
                    if (state is CategoryStoreLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is CategoryStoreLoaded) {
                      return _buildList(context, state.stores);
                    } else if (state is CategoryStoreError) {
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<StoreModel> stores) {
    if (stores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderSoft),
              boxShadow: AppDecorations.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppDecorations.heroGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppDecorations.avatarShadow,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có cửa hàng nào',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hiện tại chưa có cửa hàng nào thuộc danh mục này.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: stores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final s = stores[index];
        return _buildStoreCard(context, s);
      },
    );
  }

  Widget _buildStoreCard(BuildContext context, StoreModel store) {
    final hasImage =
        store.coverImageUrl != null && store.coverImageUrl!.trim().isNotEmpty;
    final rating = _ratingOf(store);
    final reviewCount = _reviewCountOf(store);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            context.pushNamed(
              'store',
              pathParameters: {'id': store.id.toString()},
              extra: store.name,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.surfaceSoft,
                        boxShadow: AppDecorations.softShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: hasImage
                            ? Image.network(
                                store.coverImageUrl!.trim(),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    _placeholderImage(),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: AppDecorations.heroGradient,
                                    ),
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : _placeholderImage(),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.borderSoft),
                          boxShadow: AppDecorations.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating > 0 ? rating.toStringAsFixed(1) : '0.0',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          final filled = rating >= starIndex;
                          final half =
                              rating >= index + 0.5 && rating < starIndex;

                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              filled
                                  ? Icons.star_rounded
                                  : half
                                      ? Icons.star_half_rounded
                                      : Icons.star_border_rounded,
                              size: 17,
                              color: AppColors.warning,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      if ((store.address ?? '').trim().isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                store.address!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMuted,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Đang cập nhật địa chỉ',
                          style: AppTextStyles.bodyMuted,
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _miniStat(
                            icon: Icons.star_rounded,
                            text: rating > 0
                                ? '${rating.toStringAsFixed(1)} sao'
                                : 'Chưa có đánh giá',
                          ),
                          const SizedBox(width: 10),
                          if (reviewCount > 0)
                            _miniStat(
                              icon: Icons.reviews_rounded,
                              text: '$reviewCount đánh giá',
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
    );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppDecorations.heroGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.store_rounded,
          color: AppColors.primary,
          size: 42,
        ),
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.borderSoft,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  double _ratingOf(StoreModel store) {
    final dynamic s = store;
    final value = s.averageRating;
    if (value == null) return 0.0;
    return (value is num)
        ? value.toDouble()
        : double.tryParse(value.toString()) ?? 0.0;
  }

  int _reviewCountOf(StoreModel store) {
    final dynamic s = store;
    final value = s.totalReviews;
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
