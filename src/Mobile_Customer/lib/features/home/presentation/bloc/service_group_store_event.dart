import 'package:equatable/equatable.dart';

abstract class ServiceGroupStoreEvent extends Equatable {
  const ServiceGroupStoreEvent();
  @override List<Object?> get props => [];
}
class FetchServiceGroupStores extends ServiceGroupStoreEvent {
  final int groupId;
  const FetchServiceGroupStores(this.groupId);
  @override List<Object?> get props => [groupId];
}