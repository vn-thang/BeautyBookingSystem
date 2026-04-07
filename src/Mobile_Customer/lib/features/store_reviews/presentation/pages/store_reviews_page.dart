// store_reviews_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/store_reviews_bloc.dart';

// chỉnh lại path theme cho đúng project của bạn
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class StoreReviewsPage extends StatefulWidget {
  final int storeId;
  final String storeName;

  const StoreReviewsPage({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<StoreReviewsPage> createState() => _StoreReviewsPageState();
}

class _StoreReviewsPageState extends State<StoreReviewsPage> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  final int _pageSize = 10;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();

    context.read<StoreReviewsBloc>().add(
          LoadStoreReviews(
            storeId: widget.storeId,
            page: 1,
            pageSize: _pageSize,
          ),
        );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<StoreReviewsBloc>().state;
    if (state is! StoreReviewsLoaded) return;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state.hasMore) {
      _page++;
      context.read<StoreReviewsBloc>().add(
            LoadStoreReviews(
              storeId: widget.storeId,
              page: _page,
              pageSize: _pageSize,
              append: true,
            ),
          );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Đánh giá - ${widget.storeName}',
          style: AppTextStyles.pageTitle.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<StoreReviewsBloc, StoreReviewsState>(
        builder: (context, state) {
          if (state is StoreReviewsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is StoreReviewsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is StoreReviewsLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có đánh giá nào',
                  style: AppTextStyles.bodyMuted,
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                _page = 1;
                context.read<StoreReviewsBloc>().add(
                      LoadStoreReviews(
                        storeId: widget.storeId,
                        page: 1,
                        pageSize: _pageSize,
                      ),
                    );
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                itemCount: state.items.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  final r = state.items[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderSoft),
                      boxShadow: AppDecorations.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.placeholderStart,
                              backgroundImage: (r.customer.avatarUrl != null &&
                                      r.customer.avatarUrl!.trim().isNotEmpty)
                                  ? NetworkImage(r.customer.avatarUrl!.trim())
                                  : null,
                              child: (r.customer.avatarUrl == null ||
                                      r.customer.avatarUrl!.trim().isEmpty)
                                  ? Text(
                                      _initials(r.customer.fullName),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.customer.fullName,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dateFormat.format(r.createdAt.toLocal()),
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.warning,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${r.rating}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if ((r.comment ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            r.comment!.trim(),
                            style: AppTextStyles.bodyMuted.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        if ((r.reply ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSoft,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSoft),
                            ),
                            child: Text(
                              'Phản hồi: ${r.reply!.trim()}',
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
