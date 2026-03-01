import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return _buildContent(context, state);
            } else if (state is HomeError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    final data = state.data;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, state.userName, state.locationName),
          const SizedBox(height: 8),
          _buildSearchBar(context),
          const SizedBox(height: 8),

          // Global categories (icons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Danh mục', style: _sectionTitleStyle()),
          ),
          const SizedBox(height: 8),
          _buildCategories(context, data.categories),

          // Service groups chips
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Dịch vụ', style: _sectionTitleStyle()),
          ),
          const SizedBox(height: 8),
          _buildServiceChips(context, data.serviceGroups),

          // Stores near you (limit 5)
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cửa hàng gần bạn', style: _sectionTitleStyle()),
                GestureDetector(
                  onTap: () => context.push('/stores'), // all stores page
                  child: const Text('Xem tất cả', style: TextStyle(color: Colors.pink)),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildStores(context, data.stores),

          // Vouchers
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Khuyến mãi', style: _sectionTitleStyle()),
          ),
          const SizedBox(height: 8),
          _buildVouchers(context, data.vouchers),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _buildHeader(BuildContext context, String? userName, String? locationName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFF5C8A), Color(0xFFFF7DA8)]),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // avatar
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              // greeting + location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tiện Booking', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            locationName ?? 'Bạn đang ở đâu?',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              // icons: chat, bell
              IconButton(
                onPressed: () => context.push('/chat'),
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                ),
              ),
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.notifications_none, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 12),
              Expanded(child: Text('Tìm theo tên cửa hàng, dịch vụ...', style: TextStyle(color: Colors.grey))),
              Icon(Icons.mic, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List categories) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = categories[index];
          return GestureDetector(
            onTap: () => context.push('/category/${item.id}'),
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Center(
                      child: Icon(Icons.spa, color: Colors.pink), // ideally load image from item.icon
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
      ),
    );
  }

  Widget _buildServiceChips(BuildContext context, List serviceGroups) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(serviceGroups.length, (index) {
          final g = serviceGroups[index];
          return ActionChip(
            label: Text(g.name),
            backgroundColor: Colors.pink.shade50,
            onPressed: () => context.push('/service-group/${g.id}'),
          );
        }),
      ),
    );
  }

  Widget _buildStores(BuildContext context, List stores) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: stores.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        final s = stores[index];
        return GestureDetector(
          onTap: () => context.push('/store/${s.id}'),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.pink, child: Icon(Icons.store, color: Colors.white)),
              title: Text(s.name),
              subtitle: Text(s.address ?? ''),
              trailing: Text("${(s.distanceKm ?? 0).toStringAsFixed(1)} km"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVouchers(BuildContext context, List vouchers) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, index) {
          final v = vouchers[index];
          return GestureDetector(
            onTap: () => context.push('/voucher/${v.id}'),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.code ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(v.discountText ?? '-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: vouchers.length,
      ),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      onTap: (i) {
        switch (i) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/booking');
            break;
          case 2:
            context.go('/history');
            break;
          case 3:
            context.go('/account');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Đặt lịch'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
    );
  }

  TextStyle _sectionTitleStyle() => const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
}