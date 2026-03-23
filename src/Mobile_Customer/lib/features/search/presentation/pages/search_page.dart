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
  final DraggableScrollableController _resultSheetController =
      DraggableScrollableController();
  final TextEditingController _keywordController = TextEditingController();

  SearchSortMode _sortMode = SearchSortMode.nearest;
  String _location = '';
  int? _minRating;
  RangeValues _priceRange = const RangeValues(0, 5000000);

  SearchStore? _selectedStore;

  final NumberFormat _moneyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<SearchBloc>();
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
    _resultSheetController.dispose();
    _searchBloc.close();
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
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
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
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
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
                              child: const Text('Đặt lại'),
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
                              decoration: InputDecoration(
                                hintText: 'Nhập quận, phường, đường...',
                                prefixIcon:
                                    const Icon(Icons.location_on_rounded),
                                filled: true,
                                fillColor: const Color(0xFFF8F8FB),
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
                                    setModalState(() =>
                                        tempSort = SearchSortMode.nearest);
                                  },
                                ),
                                _choiceChip(
                                  label: 'Theo địa điểm',
                                  selected:
                                      tempSort == SearchSortMode.byLocation,
                                  onTap: () {
                                    setModalState(() =>
                                        tempSort = SearchSortMode.byLocation);
                                  },
                                ),
                                _choiceChip(
                                  label: 'Đánh giá cao',
                                  selected: tempSort == SearchSortMode.topRated,
                                  onTap: () {
                                    setModalState(() =>
                                        tempSort = SearchSortMode.topRated);
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
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 18,
                                        color: selected
                                            ? Colors.white
                                            : Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('$rating sao'),
                                    ],
                                  ),
                                  selectedColor: Colors.pink,
                                  backgroundColor: const Color(0xFFF6F6F9),
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87,
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
                              child: FilledButton(
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
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Áp dụng'),
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
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
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
      selectedColor: Colors.pink,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: const Color(0xFFF6F6F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      side: BorderSide(
        color: selected ? Colors.pink : Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF5F8),
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
                      onTap: _collapseResultSheet,
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
                              Color(0x66FFFFFF),
                              Color(0x00FFFFFF),
                              Color(0x55FFF5F8),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  offset: Offset(0, -4),
                                ),
                              ],
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
                                          color: Colors.grey.shade300,
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
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            if (_sortMode ==
                                                SearchSortMode.nearest)
                                              const Text('Gần nhất'),
                                            if (_sortMode ==
                                                SearchSortMode.byLocation)
                                              const Text('Theo địa điểm'),
                                            if (_sortMode ==
                                                SearchSortMode.topRated)
                                              const Text('Đánh giá cao'),
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
                                              child: Text('Không có dữ liệu'),
                                            )
                                          : loaded.stores.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    'Không tìm thấy cửa hàng phù hợp',
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
    return Material(
      color: Colors.white.withOpacity(0.96),
      elevation: 8,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: isLoading ? null : _openFilterSheet,
              icon: const Icon(Icons.tune_rounded),
              color: Colors.pink,
              tooltip: 'Bộ lọc',
            ),
            Expanded(
              child: TextField(
                controller: _keywordController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  if (!isLoading) _submitSearch();
                },
                decoration: const InputDecoration(
                  hintText: 'Tìm theo dịch vụ hoặc cửa hàng',
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
              color: Colors.pink,
              tooltip: 'Tìm kiếm',
            ),
          ],
        ),
      ),
    );
  }
}
