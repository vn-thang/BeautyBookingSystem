import 'package:flutter/material.dart';
import 'package:mobile_store/features/voucher/screens/store_banner_management_screen.dart';
import 'package:mobile_store/features/voucher/screens/voucher_management_screen.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../widgets/marketing_menu_item.dart'; 

class MarketingMenuScreen extends StatelessWidget {
  const MarketingMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Marketing & Khuyến mãi'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingMedium),
        children: [
          // Mục 1: Quản lý Voucher
          MarketingMenuItem( // 👉 ĐỔI TÊN THÀNH MARKETING_MENU_ITEM
            icon: Icons.local_offer_outlined,
            title: 'Mã giảm giá (Voucher)',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherManagementScreen()));
            },
          ),
          const Divider(height: 1, color: AppColors.surface),
          
          // Mục 2: Quản lý Banner
          MarketingMenuItem( // 👉 ĐỔI TÊN THÀNH MARKETING_MENU_ITEM
            icon: Icons.view_carousel_outlined,
            title: 'Banner quảng cáo',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreBannerManagementScreen()));
            },
          ),
          const Divider(height: 1, color: AppColors.surface),
        ],
      ),
    );
  }
}