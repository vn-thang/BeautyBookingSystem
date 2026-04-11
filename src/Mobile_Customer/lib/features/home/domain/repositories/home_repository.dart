import '../entities/home_data.dart';

abstract class HomeRepository {
  Future<HomeData> getHomeData(double lat, double lon);
}