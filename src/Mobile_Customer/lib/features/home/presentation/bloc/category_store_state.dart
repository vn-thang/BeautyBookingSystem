import 'package:equatable/equatable.dart';
import '../../data/models/store_model.dart';

abstract class CategoryStoreState extends Equatable {
  const CategoryStoreState();
  @override List<Object?> get props => [];
}

class CategoryStoreInitial extends CategoryStoreState {}
class CategoryStoreLoading extends CategoryStoreState {}
class CategoryStoreLoaded extends CategoryStoreState {
  final List<StoreModel> stores;
  const CategoryStoreLoaded(this.stores);
  @override List<Object?> get props => [stores];
}
class CategoryStoreError extends CategoryStoreState {
  final String message;
  const CategoryStoreError(this.message);
  @override List<Object?> get props => [message];
}