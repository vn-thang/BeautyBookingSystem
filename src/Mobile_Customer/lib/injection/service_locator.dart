// lib/injection/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/dio_client.dart';
import '../core/location/location_service.dart';

// Auth import
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login.dart';
import '../features/auth/domain/usecases/get_profile.dart';
import '../features/auth/domain/usecases/register.dart';
import '../features/auth/domain/usecases/change_password.dart';
import '../features/auth/domain/usecases/forgot_password.dart';
import '../features/auth/domain/usecases/reset_password.dart';
import '../features/auth/domain/usecases/update_profile.dart';
import '../features/auth/domain/usecases/upload_avatar.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

// Home feature
import '../features/home/data/datasources/home_remote_datasource_impl.dart';
import '../features/home/data/datasources/home_remote_datasource.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/get_home_data.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/domain/repositories/store_repository.dart';
import '../features/home/data/repositories/store_repository_impl.dart';

import '../features/home/domain/usecases/get_stores_by_category.dart';
import '../features/home/presentation/bloc/category_store_bloc.dart';

import '../features/home/presentation/bloc/service_group_store_bloc.dart';
import '../features/home/domain/usecases/get_stores_by_group.dart';

import '../features/home/domain/usecases/get_store_by_id.dart';
import '../features/home/presentation/bloc/store_detail_bloc.dart';

import '../features/home/domain/usecases/get_service_detail.dart';
import '../features/home/presentation/bloc/service_detail_bloc.dart';

import '../features/booking/data/datasources/booking_remote_datasource.dart';
import '../features/booking/data/repositories/booking_repository_impl.dart';
import '../features/booking/domain/repositories/booking_repository.dart';
import '../features/booking/domain/usecases/create_booking.dart';
import '../features/booking/domain/usecases/get_available_staff.dart';
import '../features/booking/presentation/bloc/booking_bloc.dart';

// Search feature
import '../features/search/data/datasources/search_remote_datasource.dart';
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/domain/usecases/search_usecase.dart';
import '../features/search/presentation/bloc/search_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<Dio>(() => DioClient().dio);
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => Login(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetProfile(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Register(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ChangePassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfile(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UploadAvatar(sl<AuthRepository>()));

  sl.registerLazySingleton(
    () => AuthBloc(
      sl<Login>(),
      sl<GetProfile>(),
      sl<Register>(),
      sl<ChangePassword>(),
      sl<ForgotPassword>(),
      sl<ResetPassword>(),
      sl<UpdateProfile>(),
      sl<UploadAvatar>(),
    ),
  );

  // Home
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetHomeData(sl<HomeRepository>()));
  sl.registerFactory(
    () => HomeBloc(
      sl<GetHomeData>(),
      sl<LocationService>(),
      sl<AuthBloc>(),
    ),
  );

// Booking
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl<BookingRemoteDataSource>()),
  );
  sl.registerLazySingleton(
    () => CreateBooking(sl<BookingRepository>()),
  );
  sl.registerLazySingleton(() => GetAvailableStaff(sl()));
  sl.registerFactory(() => BookingBloc(sl()));

//Store
  sl.registerLazySingleton<StoreRepository>(
      () => StoreRepositoryImpl(sl<HomeRemoteDataSource>()));
  sl.registerLazySingleton(() => GetStoresByCategory(sl<StoreRepository>()));
  sl.registerFactory(
      () => CategoryStoreBloc(getStoresByCategory: sl<GetStoresByCategory>()));
  sl.registerLazySingleton(() => GetStoresByGroup(sl<StoreRepository>()));
  sl.registerFactory(
      () => ServiceGroupStoreBloc(getStoresByGroup: sl<GetStoresByGroup>()));
  sl.registerLazySingleton(
    () => GetStoreById(sl<StoreRepository>()),
  );
  sl.registerFactory(() => StoreDetailBloc(getStoreById: sl<GetStoreById>()));

//Service
  sl.registerLazySingleton(() => GetServiceDetail(sl<Dio>()));
  sl.registerFactory(() => ServiceDetailBloc(sl<GetServiceDetail>()));

//Search
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl<SearchRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => SearchUseCase(sl()));
  sl.registerFactory(
    () => SearchBloc(
      sl<SearchUseCase>(),
      sl<LocationService>(),
    ),
  );
}
