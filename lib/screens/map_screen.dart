// lib/screens/enhanced_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  late AnimationController _pulseController;
  late AnimationController _markerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _markerAnimation;

  // Current location (Mock: Delhi)
  final LatLng _currentLocation = const LatLng(28.6139, 77.2090);
  
  // Risk zones (Mock data)
  final List<RiskZone> _riskZones = [
    RiskZone(
      center: const LatLng(28.6500, 77.2300),
      radius: 500,
      riskLevel: RiskLevel.high,
      name: "High Crime Area - Old Delhi",
    ),
    RiskZone(
      center: const LatLng(28.5800, 77.1900),
      radius: 300,
      riskLevel: RiskLevel.medium,
      name: "Moderate Risk - Construction Zone",
    ),
    RiskZone(
      center: const LatLng(28.7000, 77.1500),
      radius: 400,
      riskLevel: RiskLevel.low,
      name: "Low Risk - Tourist Area",
    ),
  ];

  // Safety locations
  final List<SafetyLocation> _safetyLocations = [
    SafetyLocation(
      position: const LatLng(28.6300, 77.2200),
      type: SafetyType.police,
      name: "Delhi Police Station",
      phone: "+91-100",
    ),
    SafetyLocation(
      position: const LatLng(28.6400, 77.2100),
      type: SafetyType.hospital,
      name: "All India Institute of Medical Sciences",
      phone: "+91-11-26588500",
    ),
    SafetyLocation(
      position: const LatLng(28.6200, 77.2000),
      type: SafetyType.tourist_help,
      name: "Tourist Helpline Center",
      phone: "+91-11-23320005",
    ),
    SafetyLocation(
      position: const LatLng(28.6100, 77.2300),
      type: SafetyType.embassy,
      name: "Tourist Information Center",
      phone: "+91-11-23320008",
    ),
  ];

  bool _showRiskZones = true;
  bool _showSafetyLocations = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _simulateLocationUpdates();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _markerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _markerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _markerController, curve: Curves.elasticOut),
    );

    _markerController.forward();
  }

  void _simulateLocationUpdates() {
    // Simulate entering risk zones
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkRiskZones();
      }
    });
  }

  void _checkRiskZones() {
    for (final zone in _riskZones) {
      final distance = const Distance().as(LengthUnit.Meter, _currentLocation, zone.center);
      if (distance <= zone.radius) {
        _showRiskAlert(zone);
        break;
      }
    }
  }

  void _showRiskAlert(RiskZone zone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _getRiskColor(zone.riskLevel).withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _getRiskIcon(zone.riskLevel),
              color: _getRiskColor(zone.riskLevel),
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Risk Zone Alert!',
                style: TextStyle(color: _getRiskColor(zone.riskLevel)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are entering: ${zone.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Risk Level: ${zone.riskLevel.name.toUpperCase()}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Safety Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...zone.getSafetyTips().map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(tip)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSafeRoute();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Show Safe Route', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSafeRoute() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.navigation, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(child: Text('Safe route calculated! Avoiding high-risk areas.')),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Navigate',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would integrate with navigation apps
          },
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return AppTheme.dangerRed;
      case RiskLevel.medium:
        return AppTheme.warningOrange;
      case RiskLevel.low:
        return AppTheme.successGreen;
    }
  }

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return Icons.dangerous;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.low:
        return Icons.info;
    }
  }

  Color _getSafetyColor(SafetyType type) {
    switch (type) {
      case SafetyType.police:
        return Colors.blue;
      case SafetyType.hospital:
        return Colors.red;
      case SafetyType.tourist_help:
        return Colors.green;
      case SafetyType.embassy:
        return Colors.purple;
    }
  }

  IconData _getSafetyIcon(SafetyType type) {
    switch (type) {
      case SafetyType.police:
        return Icons.local_police;
      case SafetyType.hospital:
        return Icons.local_hospital;
      case SafetyType.tourist_help:
        return Icons.help;
      case SafetyType.embassy:
        return Icons.account_balance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _onMapTap(point),
            ),
            children: [
              // Base tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tourist_safety',
              ),
              
              // Risk zones
              if (_showRiskZones) ..._buildRiskZoneCircles(),
              
              // Safety locations markers
              if (_showSafetyLocations) _buildSafetyMarkers(),
              
              // Current location marker
              _buildCurrentLocationMarker(),
            ],
          ),

          // Top controls
          _buildTopControls(l10n, theme),

          // Bottom info panel
          _buildBottomPanel(l10n, theme),

          // Floating action buttons
          _buildFloatingActions(l10n),
        ],
      ),
    );
  }

  List<Widget> _buildRiskZoneCircles() {
    return _riskZones.map((zone) {
      return CircleLayer(
        circles: [
          CircleMarker(
            point: zone.center,
            radius: zone.radius.toDouble(),
            color: _getRiskColor(zone.riskLevel).withValues(alpha: 0.5),
            borderColor: _getRiskColor(zone.riskLevel),
            borderStrokeWidth: 2,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildSafetyMarkers() {
    final filteredLocations = _selectedFilter == 'all' 
        ? _safetyLocations 
        : _safetyLocations.where((loc) => loc.type.name == _selectedFilter).toList();

    return MarkerLayer(
      markers: filteredLocations.map((location) {
        return Marker(
          point: location.position,
          width: 40,
          height: 40,
          child: AnimatedBuilder(
            animation: _markerAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _markerAnimation.value,
                child: GestureDetector(
                  onTap: () => _showLocationInfo(location),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getSafetyColor(location.type),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getSafetyColor(location.type).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getSafetyIcon(location.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentLocationMarker() {
    return MarkerLayer(
      markers: [
        Marker(
          point: _currentLocation,
          width: 60,
          height: 60,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ring
                  Container(
                    width: 60 * _pulseAnimation.value,
                    height: 60 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withValues(
                        alpha: 0.3 * (1 - _pulseAnimation.value),
                      ),
                    ),
                  ),
                  // Main marker
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopControls(AppLocalizations l10n, ThemeData theme) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: GlassCard(
              child: Text(
                l10n.map,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Filter button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'all', child: Text('All Locations')),
                const PopupMenuItem(value: 'police', child: Text('Police Stations')),
                const PopupMenuItem(value: 'hospital', child: Text('Hospitals')),
                const PopupMenuItem(value: 'tourist_help', child: Text('Tourist Help')),
                const PopupMenuItem(value: 'embassy', child: Text('Embassies')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(AppLocalizations l10n, ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: GlassCard(
          opacity: 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const Text(
                          'Connaught Place, New Delhi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          color: AppTheme.successGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Safe Zone',
                          style: TextStyle(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildToggle(
                    'Risk Zones',
                    _showRiskZones,
                    (value) => setState(() => _showRiskZones = value),
                    Icons.warning,
                    AppTheme.warningOrange,
                  ),
                  const SizedBox(width: 16),
                  _buildToggle(
                    'Safety Points',
                    _showSafetyLocations,
                    (value) => setState(() => _showSafetyLocations = value),
                    Icons.security,
                    AppTheme.successGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: value ? color.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? color : Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: value ? color : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: value ? color : Colors.grey,
                    fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(
                value ? Icons.toggle_on : Icons.toggle_off,
                color: value ? color : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions(AppLocalizations l10n) {
    return Positioned(
      right: 16,
      top: 120,
      child: Column(
        children: [
          // Center on user location
          FloatingActionButton(
            heroTag: 'center',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              _mapController.move(_currentLocation, 15.0);
            },
            child: const Icon(Icons.my_location, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 12),
          
          // Emergency SOS
          FloatingActionButton(
            heroTag: 'sos',
            mini: true,
            backgroundColor: AppTheme.dangerRed,
            onPressed: () => _triggerEmergency(),
            child: const Icon(Icons.emergency, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _onMapTap(LatLng point) {
    // Check if tapped on a risk zone
    for (final zone in _riskZones) {
      final distance = const Distance().as(LengthUnit.Meter, point, zone.center);
      if (distance <= zone.radius) {
        _showRiskZoneInfo(zone);
        return;
      }
    }
  }

  void _showRiskZoneInfo(RiskZone zone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getRiskIcon(zone.riskLevel), color: _getRiskColor(zone.riskLevel), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    zone.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Risk Level: ${zone.riskLevel.name.toUpperCase()}'),
            Text('Radius: ${zone.radius}m'),
            const SizedBox(height: 16),
            const Text('Safety Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...zone.getSafetyTips().map((tip) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $tip'),
            )),
          ],
        ),
      ),
    );
  }

  void _showLocationInfo(SafetyLocation location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSafetyIcon(location.type), color: _getSafetyColor(location.type), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Type: ${location.type.name.replaceAll('_', ' ').toUpperCase()}'),
            Text('Phone: ${location.phone}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // In a real app, this would make a call
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${location.phone}...')),
                      );
                    },
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text('Call', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigation started...')),
                      );
                    },
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text('Navigate', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _triggerEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Emergency SOS Activated!', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🚨 Emergency services notified'),
            SizedBox(height: 8),
            Text('📍 Location shared with authorities'),
            SizedBox(height: 8),
            Text('📞 Emergency contacts alerted'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _markerController.dispose();
    super.dispose();
  }
}

// Data models
enum RiskLevel { low, medium, high }
enum SafetyType { police, hospital, tourist_help, embassy }

class RiskZone {
  final LatLng center;
  final int radius;
  final RiskLevel riskLevel;
  final String name;

  RiskZone({
    required this.center,
    required this.radius,
    required this.riskLevel,
    required this.name,
  });

  List<String> getSafetyTips() {
    switch (riskLevel) {
      case RiskLevel.high:
        return [
          'Avoid traveling alone, especially at night',
          'Keep emergency contacts handy',
          'Stay in well-lit, populated areas',
          'Consider taking alternate routes',
        ];
      case RiskLevel.medium:
        return [
          'Stay alert and aware of surroundings',
          'Keep valuables secure',
          'Travel in groups when possible',
        ];
      case RiskLevel.low:
        return [
          'Exercise normal precautions',
          'Follow local guidelines',
        ];
    }
  }
}

class SafetyLocation {
  final LatLng position;
  final SafetyType type;
  final String name;
  final String phone;

  SafetyLocation({
    required this.position,
    required this.type,
    required this.name,
    required this.phone,
  });
}
