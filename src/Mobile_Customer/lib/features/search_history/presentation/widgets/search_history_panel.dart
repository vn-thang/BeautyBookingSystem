// search_history_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_history_bloc.dart';
import '../bloc/search_history_event.dart';
import '../bloc/search_history_state.dart';

// chỉnh lại path theme cho đúng project của bạn
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class SearchHistoryPanel extends StatelessWidget {
  final void Function(String keyword) onTapKeyword;

  const SearchHistoryPanel({
    super.key,
    required this.onTapKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
      builder: (context, state) {
        if (state is SearchHistoryLoading) {
          return _panel(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (state is! SearchHistoryLoaded) {
          return const SizedBox.shrink();
        }

        final items = state.filteredItems.take(5).toList();

        if (items.isEmpty) {
          return _panel(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Không có lịch sử tìm kiếm',
                style: AppTextStyles.bodyMuted,
              ),
            ),
          );
        }

        return _panel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Gợi ý gần đây',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              for (final item in items)
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(
                    Icons.history_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(
                    item.keyword,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                  onTap: () => onTapKeyword(item.keyword),
                  trailing: IconButton(
                    onPressed: () {
                      context
                          .read<SearchHistoryBloc>()
                          .add(DeleteSearchHistoryRequested(item.id));
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: child,
    );
  }
}
