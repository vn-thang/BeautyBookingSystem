// lib/injection/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../core/location/location_service.dart';

// Home feature
import '../features/home/data/datasources/home_remote_datasource_impl.dart';
import '../features/home/data/datasources/home_remote_datasource.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/get_home_data.dart';
import '../features/home/presentation/bloc/home_bloc.dart';

// other features (auth ...) keep if needed

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<Dio>(() => DioClient().dio);
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // Home - DataSource needs Dio
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<Dio>()),
  );

  // Home - Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );

  // Home - UseCase
  sl.registerLazySingleton(() => GetHomeData(sl<HomeRepository>()));

  // Home - Bloc (note: HomeBloc expects GetHomeData and LocationService)
  sl.registerFactory(
    () => HomeBloc(
      sl<GetHomeData>(),
      sl<LocationService>(),
    ),
  );

  // register other features...
}