import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_store/features/customer/screens/customer_detail_screen.dart';
import '../models/customer_list_model.dart';
import '../services/customer_api.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_search_bar.dart';
import '../../../core/theme/app_colors.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Quản lý Khách hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, 
        elevation: 0,
        
        backgroundColor: AppColors.primary, 
       
        foregroundColor: AppColors.background, 
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _customers.isEmpty) {
      return _buildErrorState();
    }

    if (_customers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _fetchCustomers(searchTerm: _searchController.text),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          // Gọi Widget Card đã tách
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

  // Giao diện khi Lỗi
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchCustomers(searchTerm: _searchController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
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
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty 
                ? 'Không tìm thấy khách hàng nào\nphù hợp với từ khóa.'
                : 'Tiệm chưa có khách hàng nào.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}