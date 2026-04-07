import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/service_group_store_bloc.dart';
import '../bloc/service_group_store_event.dart';
import '../bloc/service_group_store_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/widgets/cards/app_store_card.dart';
import '../../../../core/widgets/common/app_empty_state_card.dart';

class ServiceGroupStoresView extends StatefulWidget {
  final int groupId;
  final String groupName;

  const ServiceGroupStoresView({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ServiceGroupStoresView> createState() => _ServiceGroupStoresViewState();
}

class _ServiceGroupStoresViewState extends State<ServiceGroupStoresView> {
  @override
  void initState() {
    super.initState();
    context
        .read<ServiceGroupStoreBloc>()
        .add(FetchServiceGroupStores(widget.groupId));
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
                          color: AppColors.surface.withValues(alpha: 0.95),
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
                            widget.groupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Danh sách cửa hàng thuộc nhóm dịch vụ này',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    BlocBuilder<ServiceGroupStoreBloc, ServiceGroupStoreState>(
                  builder: (context, state) {
                    if (state is ServiceGroupStoreLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is ServiceGroupStoreLoaded) {
                      return _buildList(context, state.stores);
                    } else if (state is ServiceGroupStoreError) {
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

  Widget _buildList(BuildContext context, List<dynamic> stores) {
    if (stores.isEmpty) {
      return const AppEmptyStateCard(
        title: 'Không có cửa hàng nào',
        description: 'Hiện tại chưa có cửa hàng nào thuộc nhóm dịch vụ này.',
        icon: Icons.storefront_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: stores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final store = stores[index];
        return AppStoreCard(
          name: store.name ?? '',
          imageUrl: store.coverImageUrl,
          address: store.address,
          rating: _ratingOf(store),
          reviewCount: _reviewCountOf(store),
          onTap: () => context.push('/store/${store.id}'),
        );
      },
    );
  }

  double _ratingOf(dynamic store) {
    final value = store.averageRating;
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  int _reviewCountOf(dynamic store) {
    final value = store.totalReviews;
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
