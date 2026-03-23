import 'package:equatable/equatable.dart';
import '../../data/models/store_model.dart';

abstract class ServiceGroupStoreState extends Equatable {
  const ServiceGroupStoreState();
  @override List<Object?> get props => [];
}

class ServiceGroupStoreInitial extends ServiceGroupStoreState {}
class ServiceGroupStoreLoading extends ServiceGroupStoreState {}
class ServiceGroupStoreLoaded extends ServiceGroupStoreState {
  final List<StoreModel> stores;
  const ServiceGroupStoreLoaded(this.stores);
  @override List<Object?> get props => [stores];
}
class ServiceGroupStoreError extends ServiceGroupStoreState {
  final String message;
  const ServiceGroupStoreError(this.message);
  @override List<Object?> get props => [message];
}