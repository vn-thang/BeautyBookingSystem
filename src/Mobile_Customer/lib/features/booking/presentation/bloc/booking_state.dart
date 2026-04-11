import '../../domain/entities/available_staff.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class AvailableStaffLoading extends BookingState {}

class AvailableStaffLoaded extends BookingState {
  final List<AvailableStaff> staffs;

  AvailableStaffLoaded(this.staffs);
}

class AvailableStaffError extends BookingState {
  final String message;

  AvailableStaffError(this.message);
}