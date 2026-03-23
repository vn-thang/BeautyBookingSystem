import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../pages/booking_datetime_page.dart';

class BookingServicesPage extends StatefulWidget {
  final int storeId;
  final int selectedServiceId;

  const BookingServicesPage({
    super.key,
    required this.storeId,
    required this.selectedServiceId,
  });

  @override
  State<BookingServicesPage> createState() => _BookingServicesPageState();
}

class _BookingServicesPageState extends State<BookingServicesPage> {
  List<Map<String, dynamic>> services = [];

  List<int> selectedServices = [];
  List<String> selectedServiceNames = [];

  String storeName = "";

  double totalPrice = 0;
  int totalDuration = 0;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStoreServices();
  }

  Future<void> _loadStoreServices() async {
    try {
      final dio = di.sl<Dio>();

      final resp = await dio.get('Stores/${widget.storeId}');
      final data = resp.data;

      final svc = (data['services'] as List).cast<Map<String, dynamic>>();

      setState(() {
        services = svc;
        storeName = (data['name'] as String?) ?? '';

        if (services.any((s) => s['id'] == widget.selectedServiceId)) {
          final init = services.firstWhere(
            (s) => s['id'] == widget.selectedServiceId,
          );

          selectedServices = [widget.selectedServiceId];
          selectedServiceNames = [init['name']];

          totalPrice = (init['price'] as num).toDouble();
          totalDuration = init['durationMinutes'] as int;
        } else {
          selectedServices = [];
          selectedServiceNames = [];
          totalPrice = 0;
          totalDuration = 0;
        }

        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void _onToggle(
    int id,
    String name,
    double price,
    int duration,
    bool add,
  ) {
    setState(() {
      if (add) {
        if (!selectedServices.contains(id)) {
          selectedServices.add(id);
          selectedServiceNames.add(name);
          totalPrice += price;
          totalDuration += duration;
        }
      } else {
        if (selectedServices.contains(id)) {
          selectedServices.remove(id);
          selectedServiceNames.remove(name);
          totalPrice -= price;
          totalDuration -= duration;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7FB),
                Color(0xFFFFEEF5),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7FB),
                Color(0xFFFFEEF5),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Lỗi: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7FB),
              Color(0xFFFFEEF5),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    _backButton(context),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn dịch vụ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            storeName.isEmpty ? 'Danh sách dịch vụ' : storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _iconCircle(
                      icon: Icons.shopping_bag_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFDDE8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.design_services_rounded,
                          color: Color(0xFFE85E9C),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedServices.isEmpty
                                  ? 'Chưa chọn dịch vụ'
                                  : '${selectedServices.length} dịch vụ đã chọn',
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F1F24),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedServices.isEmpty
                                  ? 'Hãy chọn ít nhất 1 dịch vụ để tiếp tục'
                                  : selectedServiceNames.join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = services[index];

                    final id = s['id'] as int;
                    final name = s['name'] as String;
                    final price = (s['price'] as num).toDouble();
                    final duration = s['durationMinutes'] as int;

                    final selected = selectedServices.contains(id);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFFFB8D3)
                              : const Color(0xFFFFDDE8),
                          width: selected ? 1.2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: selected
                                ? const Color(0xFFFF6FAF).withOpacity(0.10)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        value: selected,
                        onChanged: (v) => _onToggle(
                          id,
                          name,
                          price,
                          duration,
                          v == true,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFFFF6FAF),
                        checkColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F1F24),
                            fontSize: 15.5,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              _miniChip(
                                icon: Icons.sell_rounded,
                                text: '${price.toStringAsFixed(0)} VND',
                              ),
                              const SizedBox(width: 8),
                              _miniChip(
                                icon: Icons.schedule_rounded,
                                text: '$duration phút',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            border: const Border(
              top: BorderSide(color: Color(0xFFFFDDE8)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryTile(
                      label: 'Tổng tiền',
                      value: '${totalPrice.toStringAsFixed(0)} VND',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryTile(
                      label: 'Tổng thời gian',
                      value: '$totalDuration phút',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6FAF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFFFC7DC),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: selectedServices.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDateTimePage(
                                storeId: widget.storeId,
                                storeName: storeName,
                                services: selectedServices,
                                serviceNames: selectedServiceNames,
                                totalDuration: totalDuration,
                              ),
                            ),
                          );
                        },
                  child: Text(
                    'Tiếp tục • ${totalPrice.toStringAsFixed(0)} VND',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE1EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFD1E3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFE85E9C)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3A3A40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD1E3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFFFF6FAF),
        ),
      ),
    );
  }

  Widget _iconCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD1E3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFE85E9C),
          ),
        ),
      ),
    );
  }
}
