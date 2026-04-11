// lib/injection/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_customer/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:mobile_customer/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:mobile_customer/features/notification/domain/repositories/notification_repository.dart';
import 'package:mobile_customer/features/notification/domain/usecases/get_notifications.dart';
import 'package:mobile_customer/features/notification/domain/usecases/get_unread_count.dart';
import 'package:mobile_customer/features/notification/domain/usecases/mark_all_as_read.dart';
import 'package:mobile_customer/features/notification/domain/usecases/mark_as_read.dart';
import 'package:mobile_customer/features/notification/presentation/bloc/notification_bloc.dart';

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
import '../features/review/data/datasources/review_remote_datasource.dart';
import '../features/review/data/repositories/review_repository_impl.dart';
import '../features/review/domain/repositories/review_repository.dart';
import '../features/review/domain/usecases/create_review.dart';
import '../features/review/domain/usecases/get_my_reviews.dart';
import '../features/review/presentation/bloc/review_bloc.dart';
import '../features/search/data/datasources/search_remote_datasource.dart';
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/domain/usecases/search_usecase.dart';
import '../features/search/presentation/bloc/search_bloc.dart';

//Chat feature
import '../features/chat/data/datasources/chat_remote_data_source.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/get_chat_history_usecase.dart';
import '../features/chat/domain/usecases/send_chat_message_usecase.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';

//Customer Favorite feature
import '../features/customer_favorite/data/datasources/customer_favorite_remote_datasource.dart';
import '../features/customer_favorite/data/repositories/customer_favorite_repository_impl.dart';
import '../features/customer_favorite/domain/repositories/customer_favorite_repository.dart';
import '../features/customer_favorite/domain/usecases/favorite_service_usecase.dart';
import '../features/customer_favorite/domain/usecases/favorite_store_usecase.dart';
import '../features/customer_favorite/domain/usecases/unfavorite_service_usecase.dart';
import '../features/customer_favorite/domain/usecases/unfavorite_store_usecase.dart';

// Search History feature
import '../features/search_history/data/datasources/search_history_remote_datasource.dart';
import '../features/search_history/data/repositories/search_history_repository_impl.dart';
import '../features/search_history/domain/repositories/search_history_repository.dart';
import '../features/search_history/domain/usecases/delete_search_history.dart';
import '../features/search_history/domain/usecases/get_recent_search_histories.dart';
import '../features/search_history/domain/usecases/record_search_history.dart';
import '../features/search_history/presentation/bloc/search_history_bloc.dart';
import '../features/store_reviews/data/datasources/store_reviews_remote_data_source.dart';
import '../features/store_reviews/data/repositories/store_reviews_repository_impl.dart';
import '../features/store_reviews/domain/repositories/store_reviews_repository.dart';
import '../features/store_reviews/domain/usecases/get_store_reviews_usecase.dart';
import '../features/store_reviews/domain/usecases/get_top_store_reviews_usecase.dart';
import '../features/store_reviews/presentation/bloc/store_reviews_bloc.dart';

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

  //Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSource(sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerFactory(
    () => ChatBloc(
      sl<ChatRemoteDataSource>(),
      sl<LocationService>(),
    ),
  );

  //Customer Favorite
  sl.registerLazySingleton<CustomerFavoriteRemoteDataSource>(
    () => CustomerFavoriteRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<CustomerFavoriteRepository>(
    () => CustomerFavoriteRepositoryImpl(
      sl<CustomerFavoriteRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => FavoriteStoreUseCase(
        sl<CustomerFavoriteRepository>(),
      ));

  sl.registerLazySingleton(() => UnfavoriteStoreUseCase(
        sl<CustomerFavoriteRepository>(),
      ));

  sl.registerLazySingleton(() => FavoriteServiceUseCase(
        sl<CustomerFavoriteRepository>(),
      ));

  sl.registerLazySingleton(() => UnfavoriteServiceUseCase(
        sl<CustomerFavoriteRepository>(),
      ));

  //Review
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSource(sl<Dio>()),
  );

  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetMyReviews(sl<ReviewRepository>()));
  sl.registerLazySingleton(() => CreateReview(sl<ReviewRepository>()));

  sl.registerFactory(
    () => ReviewBloc(
      getMyReviews: sl<GetMyReviews>(),
      createReview: sl<CreateReview>(),
    ),
  );

  // Search History
  sl.registerFactory<SearchHistoryRemoteDataSource>(
    () => SearchHistoryRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerFactory<SearchHistoryRepository>(
    () => SearchHistoryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => GetRecentSearchHistories(sl()));
  sl.registerFactory(() => RecordSearchHistory(sl()));
  sl.registerFactory(() => DeleteSearchHistory(sl()));

  sl.registerFactory<SearchHistoryBloc>(
    () => SearchHistoryBloc(
      getRecentSearchHistories: sl(),
      recordSearchHistory: sl(),
      deleteSearchHistory: sl(),
    ),
  );

  // Store Reviews
  sl.registerFactory<StoreReviewsBloc>(
    () => StoreReviewsBloc(
      sl<GetStoreReviewsUseCase>(),
    ),
  );
  sl.registerLazySingleton<StoreReviewsRemoteDataSource>(
    () => StoreReviewsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<StoreReviewsRepository>(
    () => StoreReviewsRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetStoreReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetTopStoreReviewsUseCase(sl()));

  // 1. Bloc
 // Đổi registerFactory thành registerLazySingleton
sl.registerLazySingleton(() => NotificationBloc(
      getNotifications: sl(),
      getUnreadCount: sl(),
      markAsRead: sl(),
      markAllAsRead: sl(),
    ));

  // 2. Use Cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetUnreadCount(sl()));
  sl.registerLazySingleton(() => MarkAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllAsRead(sl()));

  // 3. Repository
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(sl()));

  // 4. Data Source
  // (Giả sử bạn đã đăng ký Dio ở đâu đó rồi: sl.registerLazySingleton(() => Dio());)
  sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSource(sl()));
}
