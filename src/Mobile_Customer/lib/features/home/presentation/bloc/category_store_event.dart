import 'package:equatable/equatable.dart';

abstract class CategoryStoreEvent extends Equatable {
  const CategoryStoreEvent();
  @override List<Object?> get props => [];
}

class FetchCategoryStores extends CategoryStoreEvent {
  final int categoryId;
  const FetchCategoryStores(this.categoryId);
  @override List<Object?> get props => [categoryId];
}