import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/bank_model.dart';

class BankSelectionBottomSheet extends StatefulWidget {
  const BankSelectionBottomSheet({super.key});

  @override
  State<BankSelectionBottomSheet> createState() => _BankSelectionBottomSheetState();

  static Future<BankModel?> show(BuildContext context) {
    return showModalBottomSheet<BankModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BankSelectionBottomSheet(),
    );
  }
}

class _BankSelectionBottomSheetState extends State<BankSelectionBottomSheet> {
  List<BankModel> _allBanks = [];
  List<BankModel> _filteredBanks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    try {
      final response = await http.get(Uri.parse('https://api.vietqr.io/v2/banks'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == '00') {
          final List<dynamic> bankList = data['data'];
          setState(() {
            _allBanks = bankList.map((json) => BankModel.fromJson(json)).toList();
            _filteredBanks = _allBanks;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Lỗi từ máy chủ: ${data['desc']}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Lỗi kết nối. Mã lỗi: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách ngân hàng. Vui lòng kiểm tra mạng.';
        _isLoading = false;
      });
    }
  }

  void _filterBanks(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredBanks = _allBanks.where((bank) {
        return bank.shortName.toLowerCase().contains(lowerCaseQuery) || 
               bank.name.toLowerCase().contains(lowerCaseQuery) ||
               bank.code.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85, 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Chọn Ngân Hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: _filterBanks,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, mã ngân hàng...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const Divider(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                    : ListView.separated(
                        itemCount: _filteredBanks.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final bank = _filteredBanks[index];
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  bank.logo,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance),
                                ),
                              ),
                            ),
                            title: Text(bank.shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(bank.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            onTap: () {
                              Navigator.pop(context, bank);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}