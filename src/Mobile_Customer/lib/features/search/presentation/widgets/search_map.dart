// search_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/search_store.dart';

// chỉnh lại path theme cho đúng project của bạn
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';

class SearchMap extends StatefulWidget {
  final double userLat;
  final double userLng;
  final List<SearchStore> stores;
  final int? selectedStoreId;
  final ValueChanged<SearchStore> onStoreTap;

  const SearchMap({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.stores,
    this.selectedStoreId,
    required this.onStoreTap,
  });

  @override
  State<SearchMap> createState() => _SearchMapState();
}

class _SearchMapState extends State<SearchMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant SearchMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final latChanged = oldWidget.userLat != widget.userLat;
    final lngChanged = oldWidget.userLng != widget.userLng;

    if ((latChanged || lngChanged) &&
        widget.userLat != 0 &&
        widget.userLng != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(
            LatLng(widget.userLat, widget.userLng),
            _mapController.camera.zoom,
          );
        } catch (_) {}
      });
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (widget.userLat != 0 && widget.userLng != 0) {
      markers.add(
        Marker(
          point: LatLng(widget.userLat, widget.userLng),
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppDecorations.avatarShadow,
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      );
    }

    for (final store in widget.stores) {
      final lat = store.lat;
      final lng = store.lng;

      if (lat == null || lng == null) continue;

      final isSelected = store.id == widget.selectedStoreId;

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 44,
          height: 44,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onStoreTap(store),
            child: Icon(
              Icons.location_on_rounded,
              color: isSelected ? AppColors.primary : AppColors.danger,
              size: isSelected ? 44 : 40,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final hasValidCenter = widget.userLat != 0 && widget.userLng != 0;
    final center = hasValidCenter
        ? LatLng(widget.userLat, widget.userLng)
        : const LatLng(21.0278, 105.8342);

    return SizedBox(
      height: 250,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.quan.beautybooking',
                tileBuilder: (context, tileWidget, tile) {
                  return ColoredBox(
                    color: AppColors.surfaceSoft,
                    child: tileWidget,
                  );
                },
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
