import 'package:flutter/material.dart';
import '../models/store_booking_model.dart';
import '../services/store_booking_api.dart';
import 'booking_card.dart';
import '../screens/booking_detail_screen.dart';

class BookingListTab extends StatefulWidget {
  final String? status; // null = Tất cả, 'Pending', 'Confirmed', 'Completed', 'Cancelled'

  const BookingListTab({super.key, this.status});

  @override
  State<BookingListTab> createState() => _BookingListTabState();
}

class _BookingListTabState extends State<BookingListTab> {
  late Future<List<StoreBookingListModel>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _bookingsFuture = StoreBookingApi.getBookings(status: widget.status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StoreBookingListModel>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFDE4660)));
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${snapshot.error}', textAlign: TextAlign.center),
                TextButton(onPressed: _loadData, child: const Text('Thử lại')),
              ],
            ),
          );
        }
        
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('Không có đơn đặt lịch nào.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: const Color(0xFFDE4660),
          child: ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(
                booking: bookings[index],
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(bookingId: bookings[index].id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}