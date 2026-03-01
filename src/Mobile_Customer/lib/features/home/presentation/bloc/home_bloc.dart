// lib/features/home/presentation/bloc/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/utils/distance_calculator.dart';

import '../../domain/usecases/get_home_data.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/store.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeData getHomeData;
  final LocationService locationService;

  HomeBloc(
    this.getHomeData,
    this.locationService,
  ) : super(HomeLoading()) {
    on<LoadHomeEvent>(_onLoadHome);
  }

  Future<void> _onLoadHome(
    LoadHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      // call usecase via its call() method explicitly to avoid confusion
      final HomeData data = await getHomeData.call();

      // Lấy vị trí người dùng
      final position = await locationService.getCurrentLocation();

      // Tạo list mới với distance (không mutate entity gốc)
      final updatedStores = data.stores.map((store) {
        final distance = calculateDistance(
          position.latitude,
          position.longitude,
          store.latitude,
          store.longitude,
        );

        return store.copyWith(distanceKm: distance);
      }).toList();

      // Sắp xếp theo khoảng cách tăng dần
      updatedStores.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

      // Emit HomeLoaded với HomeData mới (copyWith)
      // Emit HomeLoaded với thêm userName + locationName
emit(HomeLoaded(
  data.copyWith(stores: updatedStores),
  userName: "Quân", // tạm thời hardcode
  locationName: "Hai Bà Trưng", // tạm thời
));
    } catch (e, st) {
        print("HOME ERROR: $e");
        print(st);
        emit(HomeError(e.toString()));
    }
  }
}