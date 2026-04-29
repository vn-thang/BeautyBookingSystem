import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/store_reviews_bloc.dart';

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
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  int _page = 1;
  final int _pageSize = 10;

  int? _selectedRating;
  String _sortBy = 'latest';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _scrollController.addListener(_onScroll);
  }

  void _loadReviews({bool append = false}) {
    context.read<StoreReviewsBloc>().add(
          LoadStoreReviews(
            storeId: widget.storeId,
            page: _page,
            pageSize: _pageSize,
            append: append,
            rating: _selectedRating,
            sortBy: _sortBy,
          ),
        );
  }

  void _reload() {
    _page = 1;
    _isLoadingMore = false;
    _loadReviews();
  }

  void _onScroll() {
    final state = context.read<StoreReviewsBloc>().state;

    if (state is! StoreReviewsLoaded) return;
    if (_isLoadingMore) return;

    final nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (nearBottom && state.hasMore) {
      _isLoadingMore = true;
      _page++;
      _loadReviews(append: true);
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

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterSection(),
              Expanded(
                child: BlocConsumer<StoreReviewsBloc, StoreReviewsState>(
                  listener: (context, state) {
                    if (state is StoreReviewsLoaded ||
                        state is StoreReviewsError) {
                      _isLoadingMore = false;
                    }
                  },
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
                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async => _reload(),
                          child: ListView(
                            children: const [
                              SizedBox(height: 140),
                              Center(
                                child: Text(
                                  'Chưa có đánh giá nào',
                                  style: AppTextStyles.bodyMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => _reload(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount:
                              state.items.length + (state.hasMore ? 1 : 0),
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

                            return _buildReviewCard(r);
                          },
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Đánh giá ${widget.storeName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Bộ lọc đánh giá',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _filterDropdown<int?>(
                  label: 'Số sao',
                  value: _selectedRating,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tất cả')),
                    DropdownMenuItem(value: 5, child: Text('5 sao')),
                    DropdownMenuItem(value: 4, child: Text('4 sao')),
                    DropdownMenuItem(value: 3, child: Text('3 sao')),
                    DropdownMenuItem(value: 2, child: Text('2 sao')),
                    DropdownMenuItem(value: 1, child: Text('1 sao')),
                  ],
                  onChanged: (value) {
                    if (_selectedRating == value) return;

                    setState(() => _selectedRating = value);
                    _reload();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _filterDropdown<String>(
                  label: 'Sắp xếp',
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: 'latest',
                      child: Text('Gần nhất'),
                    ),
                    DropdownMenuItem(
                      value: 'best',
                      child: Text('Tốt nhất'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null || value == _sortBy) return;

                    setState(() => _sortBy = value);
                    _reload();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption,
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderSoft),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildReviewCard(dynamic r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
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
              const SizedBox(width: 12),
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
                    const SizedBox(height: 3),
                    Text(
                      _dateFormat.format(r.createdAt.toLocal()),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              _ratingBadge(r.rating),
            ],
          ),
          if ((r.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              r.comment!.trim(),
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
          ],
          if ((r.reply ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Phản hồi: ${r.reply!.trim()}',
                      style: AppTextStyles.bodyMuted.copyWith(
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ratingBadge(int rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
