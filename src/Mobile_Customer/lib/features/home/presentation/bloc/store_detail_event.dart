import 'package:equatable/equatable.dart';

abstract class StoreDetailEvent extends Equatable {
  const StoreDetailEvent();
  @override List<Object?> get props => [];
}

class FetchStoreDetail extends StoreDetailEvent {
  final int id;
  const FetchStoreDetail(this.id);
  @override List<Object?> get props => [id];
}