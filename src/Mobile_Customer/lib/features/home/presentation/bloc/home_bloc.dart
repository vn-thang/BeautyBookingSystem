// lib/features/home/presentation/bloc/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/location/location_service.dart';

import '../../domain/usecases/get_home_data.dart';

import 'home_event.dart';
import 'home_state.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeData getHomeData;
  final LocationService locationService;
  final AuthBloc authBloc;

  double? _cachedLat;
  double? _cachedLon;
  String? _cachedLocationName;

  bool _isLoading = false;

  HomeBloc(
    this.getHomeData,
    this.locationService,
    this.authBloc,
  ) : super(HomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
  }

  Future<void> _onLoadHome(
    LoadHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    // chặn call trùng
    if (_isLoading) return;

    // nếu đã load rồi và không force thì skip
    if (!event.forceRefresh && state is HomeLoaded) return;

    _isLoading = true;

    emit(HomeLoading());

    try {
      double lat;
      double lon;

      // dùng cache location
      if (_cachedLat != null && _cachedLon != null) {
        lat = _cachedLat!;
        lon = _cachedLon!;
      } else {
        final position = await locationService.getCurrentLocation();

        lat = position?.latitude ?? 0;
        lon = position?.longitude ?? 0;

        _cachedLat = lat;
        _cachedLon = lon;
      }

      //CALL API
      final data = await getHomeData(lat, lon);

      // USER NAME
      String userName = "";

      if (authBloc.state is AuthAuthenticated) {
        userName = (authBloc.state as AuthAuthenticated).user.name ?? "";
      }

      //LOCATION NAME CACHE
      String locationName;

      if (_cachedLocationName != null) {
        locationName = _cachedLocationName!;
      } else {
        locationName = "Không xác định";

        if (lat != 0 && lon != 0) {
          final address = await locationService.getAddress(lat, lon);

          if (address.isNotEmpty) {
            locationName = address;
          }
        }

        _cachedLocationName = locationName;
      }

      emit(
        HomeLoaded(
          data,
          userName: userName,
          locationName: locationName,
          lat: lat,
          lon: lon,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    } finally {
      _isLoading = false;
    }
  }
}
