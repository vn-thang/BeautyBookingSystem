import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/booking', builder: (context, state) => const BookingPage()),
      GoRoute(path: '/history', builder: (context, state) => const HistoryPage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      GoRoute(path: '/notification', builder: (context, state) => const NotificationPage()),
    ],
  );
}