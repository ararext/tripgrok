import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tripgrok/generated/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geo-fencing Alert'),
        content: Text(AppLocalizations.of(context)!.alertHighRisk),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.map)),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(28.6139, 77.2090), // Mock: Delhi
              initialZoom: 10.0,
              onTap: (_, __) => _showAlert(), // Simulate entering risk zone
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(28.6139, 77.2090),
                    child: const Icon(Icons.location_on, color: Colors.red),
                  ),
                  // Add mock police/hospital markers
                  Marker(
                    point: const LatLng(28.7041, 77.1025),
                    child: const Icon(Icons.local_hospital, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Safe route suggested: Avoid XYZ area')),
              ),
              child: const Text('Suggest Safe Route'),
            ),
          ),
        ],
      ),
    );
  }
}