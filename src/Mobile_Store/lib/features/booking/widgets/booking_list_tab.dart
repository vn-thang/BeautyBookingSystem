import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/store_booking_model.dart';
import '../services/store_booking_api.dart';
import 'booking_card.dart';
import '../screens/booking_detail_screen.dart';

class BookingListTab extends StatefulWidget {
  final String? status; 
  final DateTime? startDate; 
  final DateTime? endDate;  
  final int? staffId; 

  const BookingListTab({super.key, this.status, this.startDate, this.endDate,this.staffId});

  @override
  State<BookingListTab> createState() => _BookingListTabState();
}

class _BookingListTabState extends State<BookingListTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<StoreBookingListModel> _bookings = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant BookingListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate || oldWidget.endDate != widget.endDate || oldWidget.staffId != widget.staffId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await StoreBookingApi.getBookings(
        status: widget.status,
        startDate: widget.startDate,
        endDate: widget.endDate,
        staffId: widget.staffId,
      );
      if (mounted) {
        setState(() {
          _bookings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Lỗi tải đơn đặt lịch: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    if (_bookings.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          const SizedBox(height: 200),
          Center(
            child: Text('Không có đơn đặt lịch nào.', style: AppTextStyles.labelSmall),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return BookingCard(
          key: ValueKey(booking.id), 
          booking: booking,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailScreen(bookingId: booking.id),
              ),
            );
          },
        );
      },
    );
  }
}