import 'package:flutter_bloc/flutter_bloc.dart';
import 'store_detail_event.dart';
import 'store_detail_state.dart';
import '../../domain/usecases/get_store_by_id.dart';

class StoreDetailBloc extends Bloc<StoreDetailEvent, StoreDetailState> {
  final GetStoreById getStoreById;

  StoreDetailBloc({required this.getStoreById}) : super(StoreDetailInitial()) {
    on<FetchStoreDetail>(_onFetch);
  }

  Future<void> _onFetch(FetchStoreDetail event, Emitter<StoreDetailState> emit) async {
    emit(StoreDetailLoading());
    try {
      final store = await getStoreById.call(event.id);
      emit(StoreDetailLoaded(store));
    } catch (e) {
      emit(StoreDetailError(e.toString()));
    }
  }
}