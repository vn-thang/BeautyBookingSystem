import 'package:equatable/equatable.dart';
import '../../data/models/store_model.dart';

abstract class StoreDetailState extends Equatable {
  const StoreDetailState();
  @override List<Object?> get props => [];
}

class StoreDetailInitial extends StoreDetailState {}
class StoreDetailLoading extends StoreDetailState {}
class StoreDetailLoaded extends StoreDetailState {
  final StoreModel store;
  const StoreDetailLoaded(this.store);
  @override List<Object?> get props => [store];
}
class StoreDetailError extends StoreDetailState {
  final String message;
  const StoreDetailError(this.message);
  @override List<Object?> get props => [message];
}