import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_service_detail.dart';
import 'service_detail_event.dart';
import 'service_detail_state.dart';

class ServiceDetailBloc
    extends Bloc<ServiceDetailEvent, ServiceDetailState> {

  final GetServiceDetail getServiceDetail;

  ServiceDetailBloc(this.getServiceDetail)
      : super(ServiceDetailInitial()) {

    on<FetchServiceDetail>((event, emit) async {
      emit(ServiceDetailLoading());
      try {
        final service = await getServiceDetail(event.id);
        emit(ServiceDetailLoaded(service));
      } catch (e) {
        emit(ServiceDetailError(e.toString()));
      }
    });
  }
}