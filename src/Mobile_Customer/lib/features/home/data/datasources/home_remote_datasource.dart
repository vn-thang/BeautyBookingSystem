import '../models/global_category_model.dart';
import '../models/service_group_model.dart';
import '../models/store_model.dart';
import '../models/voucher_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<GlobalCategoryModel>> getCategories();
  Future<List<ServiceGroupModel>> getServiceGroups();
  Future<List<StoreModel>> getStores();
  Future<List<VoucherModel>> getVouchers();
}