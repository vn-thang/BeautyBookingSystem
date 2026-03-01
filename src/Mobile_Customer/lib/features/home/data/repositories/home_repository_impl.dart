import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<HomeData> getHomeData() async {
    final categories = await remote.getCategories();
    final serviceGroups = await remote.getServiceGroups();
    final stores = await remote.getStores();
    final vouchers = await remote.getVouchers();

    return HomeData(
      categories: categories.map((e) => e.toEntity()).toList(),
      serviceGroups: serviceGroups.map((e) => e.toEntity()).toList(),
      stores: stores.map((e) => e.toEntity()).toList(),
      vouchers: vouchers.map((e) => e.toEntity()).toList(),
    );
  }
}