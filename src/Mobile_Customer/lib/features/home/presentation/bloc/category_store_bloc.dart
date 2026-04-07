import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_store_event.dart';
import 'category_store_state.dart';
import '../../domain/usecases/get_stores_by_category.dart';

class CategoryStoreBloc extends Bloc<CategoryStoreEvent, CategoryStoreState> {
  final GetStoresByCategory getStoresByCategory;
  CategoryStoreBloc({required this.getStoresByCategory}) : super(CategoryStoreInitial()) {
    on<FetchCategoryStores>(_onFetch);
  }

  Future<void> _onFetch(FetchCategoryStores event, Emitter<CategoryStoreState> emit) async {
    emit(CategoryStoreLoading());
    try {
      final stores = await getStoresByCategory(event.categoryId);
      emit(CategoryStoreLoaded(stores));
    } catch (e) {
      emit(CategoryStoreError(e.toString()));
    }
  }
}