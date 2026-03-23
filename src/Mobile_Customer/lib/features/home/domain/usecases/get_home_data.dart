import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

class GetHomeData {
  final HomeRepository repository;

  GetHomeData(this.repository);

  Future<HomeData> call(double lat, double lon) {
    return repository.getHomeData(lat, lon);
  }
}