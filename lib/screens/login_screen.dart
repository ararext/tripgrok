// lib/screens/enhanced_login_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/app_localizations.dart';
import '../models/tourist_data.dart';
import '../core/theme/app_theme.dart';
import '../core/storage/tourist_secure_storage.dart';
import '../widgets/glass_card.dart';
import 'enhanced_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final Function(String)? onLocaleChange;

  const LoginScreen({
    Key? key,
    this.onThemeToggle,
    this.onLocaleChange,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _passportController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSettings();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _formAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formController.forward();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('locale') ?? 'en';
    });
  }

  Future<void> _simulateCheckIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final mockData = TouristData(
      id: 'BLOCKCHAIN_ID_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      passport: _passportController.text,
      itinerary: [],
      emergencyContacts: ['+91-100', '+91-1234567890'],
      expiry: DateTime.now().add(const Duration(days: 7)),
    );

    await TouristSecureStorage.saveTouristData(mockData);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const EnhancedDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
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
          color: isDark ? AppTheme.backgroundDark : null,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo and Title
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.appTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Digital Safety Companion',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Login Form
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _formAnimation,
                    child: GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.login,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Name/Aadhaar Field
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name / Aadhaar Number',
                                prefixIcon: const Icon(Icons.person),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 148, 147, 147),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name or Aadhaar number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Passport Field
                            TextFormField(
                              controller: _passportController,
                              decoration: InputDecoration(
                                labelText:
                                    'Passport Number (Optional for Indians)',
                                prefixIcon: const Icon(Icons.credit_card),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 148, 147, 147),
                              ),
                              validator: (value) {
                                // Optional validation for passport format
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Language Selection
                            DropdownButtonFormField<String>(
                              value: _selectedLanguage,
                              decoration: InputDecoration(
                                labelText: l10n.language,
                                prefixIcon: const Icon(Icons.language),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 148, 147, 147),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'en', child: Text('🇺🇸 English')),
                                DropdownMenuItem(
                                    value: 'hi', child: Text('🇮🇳 हिन्दी')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedLanguage = value;
                                  });
                                  widget.onLocaleChange?.call(value);
                                }
                              },
                            ),
                            const SizedBox(height: 32),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _simulateCheckIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.login,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.login,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Features Preview
                _buildFeaturesPreview(l10n, theme),

                const SizedBox(height: 30),

                // Theme Toggle
                if (widget.onThemeToggle != null)
                  TextButton.icon(
                    onPressed: widget.onThemeToggle,
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    label: Text(
                      isDark ? 'Light Mode' : 'Dark Mode',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesPreview(AppLocalizations l10n, ThemeData theme) {
    final features = [
      {
        'icon': Icons.security,
        'title': 'Digital ID',
        'description': 'Blockchain-based verification',
      },
      {
        'icon': Icons.location_on,
        'title': 'Live Tracking',
        'description': 'Real-time safety monitoring',
      },
      {
        'icon': Icons.emergency,
        'title': 'Emergency SOS',
        'description': 'One-tap help button',
      },
      {
        'icon': Icons.map,
        'title': 'Safe Routes',
        'description': 'AI-powered navigation',
      },
    ];

    return GlassCard(
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 122, 10, 197),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 107, 106, 106).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        const Color.fromARGB(255, 53, 53, 53).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: const Color.fromARGB(255, 122, 10, 197),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 155, 56, 248),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 148, 44, 245)
                            .withOpacity(0.8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _nameController.dispose();
    _passportController.dispose();
    super.dispose();
  }
}
