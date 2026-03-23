import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/injection/service_locator.dart' as di;
import 'package:mobile_customer/core/constants/app_config.dart';

import 'booking_confirm_page.dart';

class BookingStaffPage extends StatefulWidget {
  final int storeId;
  final List<int> services;
  final DateTime appointmentDate;
  final String startTime;

  const BookingStaffPage({
    super.key,
    required this.storeId,
    required this.services,
    required this.appointmentDate,
    required this.startTime,
  });

  @override
  State<BookingStaffPage> createState() => _BookingStaffPageState();
}

class _BookingStaffPageState extends State<BookingStaffPage> {
  bool loading = true;
  String? error;

  List<Map<String, dynamic>> staffs = [];
  int? selectedStaffId;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      final dio = di.sl<Dio>();

      final resp = await dio.post(
        'bookings/available-staff',
        data: {
          "storeId": widget.storeId,
          "serviceId": widget.services.first,
          "appointmentDate":
              DateFormat('yyyy-MM-dd').format(widget.appointmentDate),
          "startTime": widget.startTime,
        },
      );

      final data = List<Map<String, dynamic>>.from(resp.data);

      setState(() {
        staffs = data;
        loading = false;
        selectedStaffId = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  void _goNext() {
    String? selectedStaffName;

    if (selectedStaffId != null) {
      final staff = staffs.firstWhere(
        (s) => s['id'] == selectedStaffId,
        orElse: () => <String, dynamic>{},
      );
      selectedStaffName = staff['name']?.toString();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmPage(
          storeId: widget.storeId,
          services: widget.services,
          appointmentDate: widget.appointmentDate,
          startTime: widget.startTime,
          staffId: selectedStaffId,
          staffName: selectedStaffName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(widget.appointmentDate);

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
                          const Text(
                            'Chọn nhân viên',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dateLabel • ${widget.startTime}',
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
                      icon: Icons.groups_rounded,
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
                          Icons.event_available_rounded,
                          color: Color(0xFFE85E9C),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chọn nhân viên phù hợp',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F1F24),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bạn có thể chọn bất kỳ nhân viên nào hoặc chọn người cụ thể nếu muốn.',
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
              if (loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _sectionHeader('Lựa chọn nhanh'),
                      const SizedBox(height: 10),
                      _optionCard(
                        selected: selectedStaffId == null,
                        onTap: () {
                          setState(() {
                            selectedStaffId = null;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4F8),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFFE85E9C),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bất kỳ nhân viên nào',
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1F1F24),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Hệ thống sẽ tự sắp xếp nhân viên phù hợp nhất cho bạn.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.35,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _sectionHeader('Danh sách nhân viên'),
                      const SizedBox(height: 10),
                      if (staffs.isEmpty)
                        _emptyCard()
                      else
                        ...staffs.map((s) {
                          final int staffId = s['id'] as int;
                          final String name = (s['name'] ?? '').toString();
                          final String avatar =
                              (s['avatarUrl'] ?? '').toString();

                          final bool selected = selectedStaffId == staffId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _optionCard(
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  selectedStaffId = staffId;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFFF1F6),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFFFF6FAF)
                                            : const Color(0xFFFFDDE8),
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: avatar.isNotEmpty
                                          ? Image.network(
                                              avatar,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _avatarFallback(name),
                                            )
                                          : _avatarFallback(name),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1F1F24),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selected
                                              ? 'Đã chọn nhân viên này'
                                              : 'Nhấn để chọn nhân viên',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: selected
                                                ? const Color(0xFFE85E9C)
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Radio<int?>(
                                    value: staffId,
                                    groupValue: selectedStaffId,
                                    activeColor: const Color(0xFFFF6FAF),
                                    onChanged: (v) {
                                      setState(() {
                                        selectedStaffId = v;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
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
                      label: 'Ngày',
                      value: dateLabel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryTile(
                      label: 'Giờ',
                      value: widget.startTime,
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
                  onPressed: _goNext,
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(
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

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F1F24),
      ),
    );
  }

  Widget _optionCard({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  selected ? const Color(0xFFFFB8D3) : const Color(0xFFFFDDE8),
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
          child: child,
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

  Widget _avatarFallback(String name) {
    final initials = _initials(name);
    return Container(
      color: const Color(0xFFFFEEF5),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFFFF6FAF),
        ),
      ),
    );
  }

  String _initials(String name) {
    final source = name.trim();
    if (source.isEmpty) return 'S';

    final parts =
        source.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return source[0].toUpperCase();
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return (parts.first[0] + parts.last[0]).toUpperCase();
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

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFDDE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_off_rounded,
              color: Color(0xFFE85E9C),
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Chưa có nhân viên phù hợp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hệ thống chưa tìm thấy nhân viên khả dụng cho khung giờ này.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
