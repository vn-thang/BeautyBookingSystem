// lib/features/home/presentation/bloc/home_state.dart
import '../../domain/entities/home_data.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeData data;
  final String? userName;
  final String? locationName;
  final double lat;
  final double lon;

  HomeLoaded(
    this.data, {
    this.userName,
    this.locationName,
    required this.lat,
    required this.lon,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
