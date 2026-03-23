import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/search_store.dart';

class StoreCard extends StatelessWidget {
  final SearchStore store;

  const StoreCard({
    super.key,
    required this.store,
  });
  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );
  @override
  Widget build(BuildContext context) {
    final hasImage =
        store.imageUrl != null && store.imageUrl!.trim().isNotEmpty;
    final services = store.services.take(3).toList(growable: false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF7FA),
            Color(0xFFFFEEF5),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFC5D8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            context.push(
              '/store/${store.id}',
              extra: store.name,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: hasImage
                            ? Image.network(
                                store.imageUrl!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low,
                                gaplessPlayback: true,
                                errorBuilder: (_, __, ___) {
                                  return _placeholderImage();
                                },
                              )
                            : _placeholderImage(),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${store.rating.toStringAsFixed(1)}★',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                height: 1.2,
                                color: Color(0xFF1F1F24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _infoChip(
                            icon: Icons.location_on_rounded,
                            text: '${store.distanceKm.toStringAsFixed(1)} km',
                          ),
                          _infoChip(
                            icon: Icons.star_rounded,
                            text: store.rating.toStringAsFixed(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (services.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final service in services)
                              _serviceChip(
                                '${service.name} • ${_currencyFormat.format(service.price)}đ',
                              ),
                            if (store.services.length > 3)
                              _serviceChip(
                                '+${store.services.length - 3} dịch vụ khác',
                                muted: true,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE2EC),
            Color(0xFFFAD1DE),
          ],
        ),
      ),
      child: const Icon(
        Icons.store_rounded,
        color: Color(0xFFB54C72),
        size: 30,
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFD6E4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.pink.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A3A40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceChip(String text, {bool muted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF7F7FA) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: muted ? const Color(0xFFE8E8EF) : const Color(0xFFFFD1E0),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: muted ? Colors.grey.shade700 : const Color(0xFF2E2E35),
        ),
      ),
    );
  }

  Widget _pricePill(double price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6FA3),
            Color(0xFFFF8BB2),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '${_currencyFormat.format(price)}đ+',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
