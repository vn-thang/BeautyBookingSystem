// store_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/search_store.dart';

// chỉnh lại path theme cho đúng project của bạn
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
        boxShadow: AppDecorations.cardShadow,
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
                        color: AppColors.surfaceSoft,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
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
                          color: AppColors.overlay,
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
                      Text(
                        store.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _infoChip(
                            text: '${store.distanceKm.toStringAsFixed(1)} km',
                          ),
                          _infoChip(
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
                              GestureDetector(
                                onTap: () {
                                  context.push(
                                    '/store/${store.id}',
                                    extra: store.name,
                                  );
                                },
                                child: _serviceChip(
                                  'Xem thêm',
                                  muted: true,
                                ),
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
        gradient: AppDecorations.heroGradient,
      ),
      child: const Icon(
        Icons.store_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }

  Widget _infoChip({
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _serviceChip(String text, {bool muted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: muted ? AppColors.surfaceSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: muted ? AppColors.borderSoft : AppColors.border,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: muted ? AppColors.textSecondary : AppColors.textMuted,
        ),
      ),
    );
  }
}
