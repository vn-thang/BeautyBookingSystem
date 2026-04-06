import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart'; 
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  late LatLng _currentCenterPosition;
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    _currentCenterPosition = LatLng(
      widget.initialLat ?? 21.028511, 
      widget.initialLng ?? 105.854165,
    );
  }

  Future<void> _jumpToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      
      final newLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(newLatLng, 16.0); 
      setState(() {
        _currentCenterPosition = newLatLng;
      });
    } catch (e) {
      debugPrint("Lỗi lấy GPS trên Map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Chọn vị trí trên bản đồ'),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenterPosition,
              initialZoom: 15.0,
              onPositionChanged: (camera, hasGesture) {
                _currentCenterPosition = camera.center;
              },
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveStart) {
                  setState(() => _isMoving = true);
                } else if (event is MapEventMoveEnd) {
                  setState(() => _isMoving = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile_store', 
              ),
            ],
          ),

          AnimatedPadding(
            padding: EdgeInsets.only(bottom: _isMoving ? 30.0 : 0.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: const Icon(Icons.location_on, color: AppColors.error, size: 50),
          ),
          Positioned(
            child: Icon(Icons.circle, size: 6, color: AppColors.textMain.withValues(alpha: 0.4))
          ),

          Positioned(
            bottom: AppDimens.paddingLarge, 
            left: AppDimens.paddingLarge, 
            right: AppDimens.paddingLarge,
            child: AppPrimaryButton(
              text: 'Xác nhận tọa độ này',
              onPressed: () {
                Navigator.pop(context, _currentCenterPosition);
              },
            ),
          ),
          
          Positioned(
            bottom: 100, 
            right: AppDimens.paddingLarge,
            child: FloatingActionButton(
              heroTag: 'map_gps',
              backgroundColor: AppColors.white,
              onPressed: _jumpToCurrentLocation,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          )
        ],
      ),
    );
  }
}