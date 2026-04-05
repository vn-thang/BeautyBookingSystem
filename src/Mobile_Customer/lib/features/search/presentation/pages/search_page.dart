// search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/search_store.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_map.dart';
import '../widgets/store_card.dart';
import '../../../../injection/service_locator.dart';

// Search history
import '../../../search_history/presentation/bloc/search_history_bloc.dart';
import '../../../search_history/presentation/bloc/search_history_event.dart';
import '../../../search_history/presentation/bloc/search_history_state.dart';

// chỉnh lại path theme cho đúng project của bạn
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

enum SearchSortMode {
  nearest,
  byLocation,
  topRated,
}

class SearchFilterData {
  final SearchSortMode sortMode;
  final String location;
  final int? minRating;
  final RangeValues priceRange;

  const SearchFilterData({
    required this.sortMode,
    required this.location,
    required this.minRating,
    required this.priceRange,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchBloc _searchBloc;
  late final SearchHistoryBloc _searchHistoryBloc;

  final DraggableScrollableController _resultSheetController =
      DraggableScrollableController();
  final TextEditingController _keywordController = TextEditingController();
  final FocusNode _keywordFocusNode = FocusNode();

  SearchSortMode _sortMode = SearchSortMode.nearest;
  String _location = '';
  int? _minRating;
  RangeValues _priceRange = const RangeValues(0, 5000000);

  SearchStore? _selectedStore;

  final NumberFormat _moneyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  bool _initialized = false;
  bool _showHistoryPanel = false;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<SearchBloc>();
    _searchHistoryBloc = sl<SearchHistoryBloc>();

    _searchHistoryBloc.add(const LoadRecentSearchHistories());

    _keywordFocusNode.addListener(() {
      if (!mounted) return;

      if (!_keywordFocusNode.hasFocus) {
        setState(() {
          _showHistoryPanel = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final state = GoRouterState.of(context);
    final extra = state.extra;

    if (extra is Map<String, dynamic>) {
      final sort = extra['sortMode'];

      if (sort == 'topRated') {
        _sortMode = SearchSortMode.topRated;
      } else if (sort == 'nearest') {
        _sortMode = SearchSortMode.nearest;
      }
    }

    _searchBloc.add(
      SearchRequested(
        keyword: null,
        location: null,
        sortBy: _sortToApi(_sortMode),
        minRating: null,
        minPrice: null,
        maxPrice: null,
      ),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _keywordFocusNode.dispose();
    _resultSheetController.dispose();
    _searchBloc.close();
    _searchHistoryBloc.close();
    super.dispose();
  }

  String _sortToApi(SearchSortMode mode) {
    switch (mode) {
      case SearchSortMode.nearest:
        return 'nearest';
      case SearchSortMode.byLocation:
        return 'location';
      case SearchSortMode.topRated:
        return 'topRated';
    }
  }

  void _submitSearch() {
    final keyword = _keywordController.text.trim();

    if (keyword.isNotEmpty) {
      _searchHistoryBloc.add(RecordSearchHistoryRequested(keyword));
    }

    _searchBloc.add(
      SearchRequested(
        keyword: keyword.isEmpty ? null : keyword,
        location: _location.trim().isEmpty ? null : _location.trim(),
        sortBy: _sortToApi(_sortMode),
        minRating: _minRating,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
      ),
    );

    FocusScope.of(context).unfocus();
    setState(() {
      _showHistoryPanel = false;
    });
  }

  void _showRecentHistories() {
    _searchHistoryBloc.add(const LoadRecentSearchHistories());
    setState(() {
      _showHistoryPanel = true;
    });
  }

  void _onTapHistoryKeyword(String keyword) {
    _keywordController.text = keyword;
    _keywordController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _submitSearch();
  }

  void _toggleResultSheet() {
    if (!_resultSheetController.isAttached) return;

    final size = _resultSheetController.size;

    if (size < 0.4) {
      _resultSheetController.animateTo(
        0.55,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _resultSheetController.animateTo(
        0.28,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _collapseResultSheet() {
    if (!_resultSheetController.isAttached) return;

    _resultSheetController.animateTo(
      0.15,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<SearchFilterData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        SearchSortMode tempSort = _sortMode;
        int? tempMinRating = _minRating;
        RangeValues tempPriceRange = _priceRange;
        String tempLocation = _location;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.82,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: AppDecorations.topBarShadow,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Bộ lọc',
                                style: AppTextStyles.sectionTitle,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  tempSort = SearchSortMode.nearest;
                                  tempMinRating = null;
                                  tempPriceRange =
                                      const RangeValues(0, 5000000);
                                  tempLocation = '';
                                });
                              },
                              child: const Text(
                                'Đặt lại',
                                style: AppTextStyles.chip,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            _sectionTitle('Theo địa điểm'),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: tempLocation,
                              onChanged: (v) => tempLocation = v,
                              style: AppTextStyles.body,
                              decoration: InputDecoration(
                                hintText: 'Nhập quận, phường, đường...',
                                hintStyle: AppTextStyles.bodyMuted,
                                filled: true,
                                fillColor: AppColors.surfaceSoft,
                                prefixIcon: const Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle('Sắp xếp'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _choiceChip(
                                  label: 'Gần nhất',
                                  selected: tempSort == SearchSortMode.nearest,
                                  onTap: () {
                                    setModalState(() {
                                      tempSort = SearchSortMode.nearest;
                                    });
                                  },
                                ),
                                _choiceChip(
                                  label: 'Theo địa điểm',
                                  selected:
                                      tempSort == SearchSortMode.byLocation,
                                  onTap: () {
                                    setModalState(() {
                                      tempSort = SearchSortMode.byLocation;
                                    });
                                  },
                                ),
                                _choiceChip(
                                  label: 'Đánh giá cao',
                                  selected: tempSort == SearchSortMode.topRated,
                                  onTap: () {
                                    setModalState(() {
                                      tempSort = SearchSortMode.topRated;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle('Đánh giá từ'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(5, (index) {
                                final rating = index + 1;
                                final selected = tempMinRating == rating;
                                return FilterChip(
                                  selected: selected,
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    setModalState(() {
                                      tempMinRating = selected ? null : rating;
                                    });
                                  },
                                  label: Text('$rating sao'),
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.surfaceSoft,
                                  side: BorderSide(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 22),
                            _sectionTitle('Khoảng giá dịch vụ'),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatMoney(tempPriceRange.start)}  -  ${_formatMoney(tempPriceRange.end)}',
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            RangeSlider(
                              values: tempPriceRange,
                              min: 0,
                              max: 5000000,
                              divisions: 100,
                              labels: RangeLabels(
                                _formatMoney(tempPriceRange.start),
                                _formatMoney(tempPriceRange.end),
                              ),
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.borderSoft,
                              onChanged: (values) {
                                setModalState(() {
                                  tempPriceRange = values;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(
                                    sheetContext,
                                    SearchFilterData(
                                      sortMode: tempSort,
                                      location: tempLocation,
                                      minRating: tempMinRating,
                                      priceRange: tempPriceRange,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Áp dụng',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      _sortMode = result.sortMode;
      _location = result.location;
      _minRating = result.minRating;
      _priceRange = result.priceRange;
    });

    _submitSearch();
  }

  String _formatMoney(double value) {
    return _moneyFormat.format(value.round());
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.surfaceSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _searchBloc),
        BlocProvider.value(value: _searchHistoryBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              final isLoading = state is SearchLoading;
              final loaded = state is SearchLoaded ? state : null;

              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showHistoryPanel = false;
                        });
                        _collapseResultSheet();
                      },
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Positioned.fill(
                    child: loaded == null
                        ? const Center(child: CircularProgressIndicator())
                        : SearchMap(
                            userLat: loaded.userLat,
                            userLng: loaded.userLng,
                            stores: loaded.stores,
                            selectedStoreId: _selectedStore?.id,
                            onStoreTap: (store) {
                              setState(() {
                                _selectedStore = store;
                              });
                            },
                          ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x55FFFFFF),
                              Color(0x00FFFFFF),
                              Color(0x44FFF7FB),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _buildSearchBar(isLoading),
                    ),
                  ),
                  DraggableScrollableSheet(
                    controller: _resultSheetController,
                    initialChildSize: 0.28,
                    minChildSize: 0.15,
                    maxChildSize: 0.92,
                    snap: true,
                    snapSizes: const [0.15, 0.28, 0.55, 0.92],
                    builder: (context, scrollController) {
                      return AnimatedBuilder(
                        animation: _resultSheetController,
                        builder: (context, _) {
                          final sheetSize = _resultSheetController.isAttached
                              ? _resultSheetController.size
                              : 0.28;

                          final showSelectedStore =
                              _selectedStore != null && sheetSize > 0.34;

                          return Container(
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                              boxShadow: AppDecorations.topBarShadow,
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _toggleResultSheet,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 42,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppColors.border,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'Kết quả tìm kiếm',
                                                style:
                                                    AppTextStyles.sectionTitle,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceSoft,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: AppColors.borderSoft,
                                                ),
                                              ),
                                              child: Text(
                                                _sortMode ==
                                                        SearchSortMode.nearest
                                                    ? 'Gần nhất'
                                                    : _sortMode ==
                                                            SearchSortMode
                                                                .byLocation
                                                        ? 'Theo địa điểm'
                                                        : 'Đánh giá cao',
                                                style: AppTextStyles.caption,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                                if (showSelectedStore) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: StoreCard(store: _selectedStore!),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Expanded(
                                  child: isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : loaded == null
                                          ? const Center(
                                              child: Text(
                                                'Không có dữ liệu',
                                                style: AppTextStyles.bodyMuted,
                                              ),
                                            )
                                          : loaded.stores.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    'Không tìm thấy cửa hàng phù hợp',
                                                    style:
                                                        AppTextStyles.bodyMuted,
                                                  ),
                                                )
                                              : ListView.separated(
                                                  controller: scrollController,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                    16,
                                                    8,
                                                    16,
                                                    20,
                                                  ),
                                                  itemCount:
                                                      loaded.stores.length,
                                                  separatorBuilder: (_, __) =>
                                                      const SizedBox(
                                                          height: 12),
                                                  itemBuilder: (_, i) {
                                                    final store =
                                                        loaded.stores[i];
                                                    return StoreCard(
                                                      store: store,
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: isLoading ? null : _openFilterSheet,
                  icon: const Icon(Icons.tune_rounded),
                  color: AppColors.primary,
                  tooltip: 'Bộ lọc',
                ),
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    focusNode: _keywordFocusNode,
                    textInputAction: TextInputAction.search,
                    onTap: _showRecentHistories,
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        _searchHistoryBloc
                            .add(const LoadRecentSearchHistories());
                      } else {
                        _searchHistoryBloc
                            .add(FilterSearchHistoriesRequested(value));
                      }

                      setState(() {
                        _showHistoryPanel = true;
                      });
                    },
                    onSubmitted: (_) {
                      if (!isLoading) _submitSearch();
                    },
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Tìm theo dịch vụ hoặc cửa hàng',
                      hintStyle: AppTextStyles.bodyMuted,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : _submitSearch,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  color: AppColors.primary,
                  tooltip: 'Tìm kiếm',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_showHistoryPanel)
          BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
            builder: (context, state) {
              if (state is SearchHistoryLoading) {
                return const _HistoryPanel(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (state is! SearchHistoryLoaded) {
                return const SizedBox.shrink();
              }

              final items = state.filteredItems.take(5).toList();

              if (items.isEmpty) {
                return const _HistoryPanel(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Không có lịch sử tìm kiếm',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ),
                );
              }

              return _HistoryPanel(
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
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
                        onTap: () => _onTapHistoryKeyword(item.keyword),
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
          ),
      ],
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  final Widget child;

  const _HistoryPanel({required this.child});

  @override
  Widget build(BuildContext context) {
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
