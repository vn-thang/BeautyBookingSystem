import 'package:flutter_bloc/flutter_bloc.dart';

import 'booking_event.dart';
import 'booking_state.dart';
import '../../domain/usecases/get_available_staff.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {

  final GetAvailableStaff getAvailableStaff;

  BookingBloc(this.getAvailableStaff) : super(BookingInitial()) {

    on<FetchAvailableStaffEvent>((event, emit) async {

      emit(AvailableStaffLoading());

      try {

        final staffs = await getAvailableStaff(
          storeId: event.storeId,
          serviceId: event.serviceId,
          appointmentDate: event.appointmentDate,
          startTime: event.startTime,
        );

        emit(AvailableStaffLoaded(staffs));

      } catch (e) {
        emit(AvailableStaffError(e.toString()));
      }

    });

  }
}