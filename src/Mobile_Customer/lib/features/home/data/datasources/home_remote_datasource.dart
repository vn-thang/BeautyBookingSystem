import '../models/global_category_model.dart';
import '../models/service_group_model.dart';
import '../models/store_model.dart';
import '../models/voucher_model.dart';
import '../models/home_response_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeResponseModel> getHome(double lat, double lon);
  Future<List<GlobalCategoryModel>> getCategories();
  Future<List<ServiceGroupModel>> getServiceGroups();
  Future<List<StoreModel>> getStores();
  Future<List<VoucherModel>> getVouchers();
  Future<List<StoreModel>> getStoresByCategory(int categoryId);
  Future<List<StoreModel>> getStoresByGroup(int groupId);
  Future<StoreModel> getStoreById(int id);
  Future<List<VoucherModel>> getVouchersService(int serviceId, {int? storeId});
}
