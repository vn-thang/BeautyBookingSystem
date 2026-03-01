import 'global_category_model.dart';
import 'service_group_model.dart';
import 'store_model.dart';
import 'voucher_model.dart';

class HomeResponseModel {
  final List<GlobalCategoryModel> categories;
  final List<ServiceGroupModel> serviceGroups;
  final List<StoreModel> stores;
  final List<VoucherModel> vouchers;

  HomeResponseModel({
    required this.categories,
    required this.serviceGroups,
    required this.stores,
    required this.vouchers,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeResponseModel(
      categories: (json['categories'] as List)
          .map((e) => GlobalCategoryModel.fromJson(e))
          .toList(),
      serviceGroups: (json['serviceGroups'] as List)
          .map((e) => ServiceGroupModel.fromJson(e))
          .toList(),
      stores: (json['stores'] as List)
          .map((e) => StoreModel.fromJson(e))
          .toList(),
      vouchers: (json['vouchers'] as List)
          .map((e) => VoucherModel.fromJson(e))
          .toList(),
    );
  }
}