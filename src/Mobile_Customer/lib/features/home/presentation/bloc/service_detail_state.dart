import '../../domain/entities/service.dart';

abstract class ServiceDetailState {}

class ServiceDetailInitial extends ServiceDetailState {}

class ServiceDetailLoading extends ServiceDetailState {}

class ServiceDetailLoaded extends ServiceDetailState {
  final Service service;
  ServiceDetailLoaded(this.service);
}

class ServiceDetailError extends ServiceDetailState {
  final String message;
  ServiceDetailError(this.message);
}