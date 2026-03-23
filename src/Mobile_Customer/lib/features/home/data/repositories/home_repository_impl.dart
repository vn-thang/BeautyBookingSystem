import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_response_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<HomeData> getHomeData(double lat, double lon) async {

    final HomeResponseModel remoteHome =
        await remote.getHome(lat, lon);

    final categories =
        remoteHome.categories.map((e) => e.toEntity()).toList();

    final serviceGroups =
        remoteHome.serviceGroups.map((e) => e.toEntity()).toList();

    final stores =
        remoteHome.stores.map((e) => e.toEntity()).toList();

    final nearbyStores =
        remoteHome.nearbyStores.map((e) => e.toEntity()).toList();

    final topRatedStores =
        remoteHome.topRatedStores.map((e) => e.toEntity()).toList();

    final vouchers =
        remoteHome.vouchers.map((e) => e.toEntity()).toList();
    
    final systemContents = remoteHome.systemContents;

    return HomeData(
        categories: categories,
        serviceGroups: serviceGroups,
        stores: nearbyStores,
        nearbyStores: nearbyStores,
        topRatedStores: topRatedStores,
        vouchers: vouchers,
        systemContents: systemContents,
    );
  }
}