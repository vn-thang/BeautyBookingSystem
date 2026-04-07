
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_store/features/customer/screens/customer_detail_screen.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/inputs/app_header.dart'; 
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../models/customer_list_model.dart';
import '../services/customer_api.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_search_bar.dart';

class CustomerListScreen extends StatefulWidget {
  final int storeId; 
  const CustomerListScreen({super.key, required this.storeId});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<CustomerListModel> _customers = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchCustomers({String? searchTerm}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await CustomerApi.getCustomers(widget.storeId, searchTerm: searchTerm);
      setState(() {
        _customers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCustomers(searchTerm: query);
    });
   
    setState(() {}); 
  }

  void _clearSearch() {
    _searchController.clear();
    _fetchCustomers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: const AppHeader(
        title: 'Quản lý Khách hàng',
      ),
      body: Column(
        children: [
          CustomerSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
          Expanded(
            child: _buildBodyContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading && _customers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null && _customers.isEmpty) {
      return _buildErrorState();
    }

    if (_customers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _fetchCustomers(searchTerm: _searchController.text),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingLarge, vertical: AppDimens.paddingMedium),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return CustomerCard(
            customer: customer,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CustomerDetailScreen(
                  storeId: widget.storeId, 
                  customerId: customer.customerId,
                )
              ));
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage!, 
              textAlign: TextAlign.center, 
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 150, 
              child: AppOutlineButton(
                text: 'Thử lại',
                onTap: () => _fetchCustomers(searchTerm: _searchController.text),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppColors.textSub.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _searchController.text.isNotEmpty 
                ? 'Không tìm thấy khách hàng nào\nphù hợp với từ khóa.'
                : 'Tiệm chưa có khách hàng nào.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyText.copyWith(fontSize: 16, color: AppColors.textSub),
          ),
        ],
      ),
    );
  }
}