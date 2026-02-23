// lib/screens/enhanced_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/app_localizations.dart';
import '../models/tourist_data.dart';
import '../core/theme/app_theme.dart';
import '../core/storage/tourist_secure_storage.dart';
import '../widgets/safety_score_card.dart';
import '../widgets/emergency_button.dart' as eb;
import '../widgets/glass_card.dart' as gc;
import '../widgets/animated_fab.dart';
import 'id_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'dart:math' as math;

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  TouristData? _data;
  double _safetyScore = 85.0;
  List<String> _itinerary = [];
  final _itineraryController = TextEditingController();
  
  late AnimationController _pulseController;
  late AnimationController _cardController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cardAnimation;

  bool _isInDangerZone = false;
  String _currentLocation = "Connaught Place, Delhi";
  int _nearbyPoliceStations = 3;
  int _nearbyHospitals = 2;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAnimations();
    _simulateLocationUpdates();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );
    
    _cardController.forward();
  }

  void _simulateLocationUpdates() {
    // Simulate real-time safety score updates
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _safetyScore = 78.0;
          _currentLocation = "India Gate, Delhi";
          _isInDangerZone = true;
        });
        _showRiskAlert();
      }
    });
  }

  Future<void> _loadData() async {
    final secureData = await TouristSecureStorage.loadTouristData();
    setState(() {
      _data = secureData;
      _itinerary = _data!.itinerary;
    });
  }

  void _addItinerary() async {
    if (_itineraryController.text.isNotEmpty) {
      setState(() {
        _itinerary.add(_itineraryController.text);
      });
      await TouristSecureStorage.saveItinerary(_itinerary);
      _itineraryController.clear();
      _showSnackBar('Itinerary item added successfully!', Colors.green);
    }
  }

  void _showRiskAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600, size: 32),
            const SizedBox(width: 12),
            const Text('Risk Alert!', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have entered a high-risk zone. Your safety score has decreased.',
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              'Suggested actions:\n• Stay in well-lit areas\n• Keep emergency contacts ready\n• Consider changing route',
              style: TextStyle(color: Colors.grey.shade700),
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
              _navigateToMap();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('View Safe Route', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _simulatePanic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red.shade600, size: 32),
            const SizedBox(width: 12),
            const Text('Emergency Alert Sent!', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚨 Emergency services have been notified'),
            const SizedBox(height: 8),
            const Text('📍 Your location has been shared'),
            const SizedBox(height: 8),
            const Text('📞 Emergency contacts alerted'),
            const SizedBox(height: 16),
            Text(
              'Help is on the way!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? null : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(l10n, theme),
                const SizedBox(height: 24),

                // Safety Score Card
                AnimatedBuilder(
                  animation: _cardAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _cardAnimation.value,
                    child: SafetyScoreCard(
                      score: _safetyScore,
                      location: _currentLocation,
                      isDangerZone: _isInDangerZone,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Stats
                _buildQuickStats(l10n, theme),
                const SizedBox(height: 20),

                // Emergency Section
                gc.GlassCard(
                  child: Column(
                    children: [
                      Text(
                        l10n.emergency,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _isInDangerZone ? _pulseAnimation.value : 1.0,
                          child: eb.EmergencyButton(
                            onPressed: _simulatePanic,
                            isActive: _isInDangerZone,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Itinerary Section
                _buildItinerarySection(l10n, theme),
                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(l10n, theme),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IdScreen()),
        ),
        icon: Icons.credit_card,
        label: l10n.digitalId,
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              _data?.name ?? 'Tourist',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await TouristSecureStorage.clearTouristData();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(AppLocalizations l10n, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: gc.GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.local_police,
                  color: AppTheme.primaryBlue,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_nearbyPoliceStations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nearby Police',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: gc.GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: AppTheme.successGreen,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_nearbyHospitals',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nearby Hospitals',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItinerarySection(AppLocalizations l10n, ThemeData theme) {
    return gc.GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Your Itinerary',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_itinerary.isEmpty)
            Center(
              child: Text(
                'No itinerary items yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            )
          else
            ..._itinerary.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item)),
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successGreen,
                      size: 20,
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itineraryController,
                  decoration: InputDecoration(
                    labelText: l10n.addItinerary,
                    prefixIcon: const Icon(Icons.add_location),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addItinerary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n, ThemeData theme) {
    return gc.GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToMap,
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: Text(l10n.map, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ),
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: Text(l10n.settings, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cardController.dispose();
    _itineraryController.dispose();
    super.dispose();
  }
}
