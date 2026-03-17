import 'package:flutter/material.dart';

class LocationVerification extends StatelessWidget {
  final bool isGettingLocation;
  final double? latitude;
  final double? longitude;
  final VoidCallback onVerifyAddress;
  final VoidCallback onGetGPS;

  const LocationVerification({
    super.key,
    required this.isGettingLocation,
    this.latitude,
    this.longitude,
    required this.onVerifyAddress,
    required this.onGetGPS,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton.icon(
            onPressed: isGettingLocation ? null : onVerifyAddress,
            icon: isGettingLocation 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Icon(latitude != null ? Icons.check_circle : Icons.map),
            label: Text(
              latitude != null ? "Đã xác minh vị trí" : "Xác minh từ địa chỉ",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: latitude != null ? Colors.green : Colors.blue,
              foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton.icon(
            onPressed: isGettingLocation ? null : onGetGPS,
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text("Hoặc lấy vị trí GPS hiện tại"),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
          ),
        ),
        if (latitude != null && longitude != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text("📍 Lat: $latitude, Lng: $longitude", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ),
      ],
    );
  }
}