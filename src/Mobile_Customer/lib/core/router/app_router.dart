import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../injection/service_locator.dart' as di;
import '../navigation/main_bottom_nav.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';

import '../../features/search/presentation/pages/search_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';

import '../../features/home/presentation/pages/category_store_page.dart';
import '../../features/home/presentation/pages/service_group_store_page.dart';
import '../../features/home/presentation/pages/store_detail_page.dart';
import '../../features/home/presentation/pages/service_detail_page.dart';

import '../../features/home/presentation/bloc/category_store_bloc.dart';
import '../../features/home/presentation/bloc/service_group_store_bloc.dart';
import '../../features/home/presentation/bloc/store_detail_bloc.dart';
import '../../features/home/presentation/bloc/store_detail_event.dart';
import '../../features/home/presentation/bloc/service_detail_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: "/",

    /// refresh khi auth state đổi
    refreshListenable: GoRouterRefreshStream(
      di.sl<AuthBloc>().stream,
    ),

    /// AUTH GUARD
    redirect: (context, state) {
      final authState = di.sl<AuthBloc>().state;

      final loggingIn = state.matchedLocation == "/login";

      final protectedRoutes = [
        "/booking",
        "/history",
        "/profile",
      ];

      final needAuth = protectedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      /// chưa login
      if (authState is AuthUnauthenticated && needAuth) {
        return "/login";
      }

      /// đã login mà vào login
      if (authState is AuthAuthenticated && loggingIn) {
        return "/";
      }

      return null;
    },

    routes: [

      /// ============================
      /// SHELL ROUTE (BOTTOM NAV)
      /// ============================

      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: const MainBottomNav(),
          );
        },
        routes: [

          /// HOME
          GoRoute(
            path: "/",
            builder: (context, state) => const HomePage(),
          ),

          /// BOOKING
          GoRoute(
            path: "/booking",
            builder: (context, state) => const BookingPage(),
          ),

          /// HISTORY
          GoRoute(
            path: "/history",
            builder: (context, state) => const HistoryPage(),
          ),

          /// PROFILE
          GoRoute(
            path: "/profile",
            builder: (context, state) => const ProfilePage(),
          ),

          /// SEARCH
          GoRoute(
            path: "/search",
            builder: (context, state) => const SearchPage(),
          ),

          /// CHAT
          GoRoute(
            path: "/chat",
            builder: (context, state) => const ChatPage(),
          ),

          /// NOTIFICATION
          GoRoute(
            path: "/notification",
            builder: (context, state) => const NotificationPage(),
          ),

          /// ============================
          /// CATEGORY STORE
          /// ============================

          GoRoute(
            path: "/category/:id",
            name: "category",
            builder: (context, state) {
              final categoryId =
                  int.tryParse(state.pathParameters["id"] ?? "0") ?? 0;

              final categoryName =
                  state.extra as String? ?? "Danh mục";

              return BlocProvider(
                create: (_) => di.sl<CategoryStoreBloc>(),
                child: CategoryStoresView(
                  categoryId: categoryId,
                  categoryName: categoryName,
                ),
              );
            },
          ),

          /// ============================
          /// SERVICE GROUP STORE
          /// ============================

          GoRoute(
            path: "/service-group/:id",
            name: "service_group",
            builder: (context, state) {
              final groupId =
                  int.tryParse(state.pathParameters["id"] ?? "0") ?? 0;

              final groupName =
                  state.extra as String? ?? "Nhóm dịch vụ";

              return BlocProvider(
                create: (_) => di.sl<ServiceGroupStoreBloc>(),
                child: ServiceGroupStoresView(
                  groupId: groupId,
                  groupName: groupName,
                ),
              );
            },
          ),

          /// ============================
          /// STORE DETAIL
          /// ============================

          GoRoute(
            path: "/store/:id",
            name: "store",
            builder: (context, state) {
              final storeId =
                  int.tryParse(state.pathParameters["id"] ?? "0") ?? 0;

              final storeName = state.extra as String?;

              return BlocProvider(
                create: (_) {
                  final bloc = di.sl<StoreDetailBloc>();
                  bloc.add(FetchStoreDetail(storeId));
                  return bloc;
                },
                child: StoreDetailPage(
                  storeId: storeId,
                  storeName: storeName,
                ),
              );
            },
          ),

          /// ============================
          /// SERVICE DETAIL
          /// ============================

          GoRoute(
            path: "/service-detail/:id",
            name: "service_detail",
            builder: (context, state) {
              final serviceId =
                  int.parse(state.pathParameters["id"]!);

              return BlocProvider(
                create: (_) => di.sl<ServiceDetailBloc>(),
                child: ServiceDetailPage(
                  serviceId: serviceId,
                ),
              );
            },
          ),
        ],
      ),

      /// ============================
      /// LOGIN (NO BOTTOM NAV)
      /// ============================

      GoRoute(
        path: "/login",
        builder: (context, state) {
          final redirect = state.extra as String?;
          return LoginPage(redirectPath: redirect);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}