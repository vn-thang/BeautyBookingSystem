import 'package:flutter_bloc/flutter_bloc.dart';
import 'service_group_store_event.dart';
import 'service_group_store_state.dart';
import '../../domain/usecases/get_stores_by_group.dart';

class ServiceGroupStoreBloc extends Bloc<ServiceGroupStoreEvent, ServiceGroupStoreState> {
  final GetStoresByGroup getStoresByGroup;

  ServiceGroupStoreBloc({required this.getStoresByGroup}) : super(ServiceGroupStoreInitial()) {
    on<FetchServiceGroupStores>(_onFetch);
  }

  Future<void> _onFetch(FetchServiceGroupStores event, Emitter<ServiceGroupStoreState> emit) async {
    emit(ServiceGroupStoreLoading());
    try {
      final stores = await getStoresByGroup.call(event.groupId);
      emit(ServiceGroupStoreLoaded(stores));
    } catch (e) {
      emit(ServiceGroupStoreError(e.toString()));
    }
  }
}