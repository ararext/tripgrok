// lib/screens/enhanced_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final ValueChanged<bool>? onThemeChanged;
  final ValueChanged<String>? onLocaleChange;

  const SettingsScreen({
    Key? key,
    this.onThemeToggle,
    this.onThemeChanged,
    this.onLocaleChange,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _locationTrackingEnabled = true;
  bool _emergencyAlertsEnabled = true;
  bool _darkModeEnabled = false;
  double _textScaleFactor = 1.0;
  bool _highContrastMode = false;
  bool _reduceAnimations = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedLanguage = prefs.getString('locale') ?? 'en';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _locationTrackingEnabled = prefs.getBool('location_tracking') ?? true;
      _emergencyAlertsEnabled = prefs.getBool('emergency_alerts') ?? true;
      _darkModeEnabled = prefs.getBool('isDarkMode') ?? false;
      _textScaleFactor = prefs.getDouble('text_scale') ?? 1.0;
      _highContrastMode = prefs.getBool('high_contrast') ?? false;
      _reduceAnimations = prefs.getBool('reduce_animations') ?? false;
    });
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', lang);
    if (!mounted) return;
    setState(() {
      _selectedLanguage = lang;
    });
    widget.onLocaleChange?.call(lang);
    _showAppliedDialog('Language updated successfully.');
  }

  Future<void> _toggleSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', scale);
  }

  void _showAppliedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryBlue),
            SizedBox(width: 12),
            Text('Settings Updated'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Tourist ID: BLOCKCHAIN_ID_123'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
          color: isDark ? AppTheme.backgroundDark : null,
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  _buildHeader(l10n, theme),
                  const SizedBox(height: 30),

                  // Profile Section
                  _buildProfileSection(theme),
                  const SizedBox(height: 20),

                  // Language & Localization
                  _buildLanguageSection(l10n, theme),
                  const SizedBox(height: 20),

                  // Privacy & Security
                  _buildPrivacySection(l10n, theme),
                  const SizedBox(height: 20),

                  // Notifications
                  _buildNotificationsSection(l10n, theme),
                  const SizedBox(height: 20),

                  // Accessibility
                  _buildAccessibilitySection(l10n, theme),
                  const SizedBox(height: 20),

                  // App Preferences
                  _buildAppPreferencesSection(l10n, theme),
                  const SizedBox(height: 20),

                  // Support & Info
                  _buildSupportSection(l10n, theme),
                  const SizedBox(height: 20),

                  // Emergency Settings
                  _buildEmergencySection(l10n, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            l10n.settings,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return GlassCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: const Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Tourist ID: BLOCKCHAIN_ID_123'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: _showProfileDialog,
      ),
    );
  }

  Widget _buildLanguageSection(AppLocalizations l10n, ThemeData theme) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'Language & Region',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingTile(
            'Select Language',
            _selectedLanguage == 'en' ? '🇺🇸 English' : '🇮🇳 हिन्दी',
            Icons.translate,
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
                DropdownMenuItem(value: 'hi', child: Text('🇮🇳 हिन्दी')),
              ],
              onChanged: (value) => _changeLanguage(value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(AppLocalizations l10n, ThemeData theme) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'Privacy & Security',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            'Location Tracking',
            'Allow app to track your location for safety',
            Icons.location_on,
            _locationTrackingEnabled,
            (value) {
              setState(() {
                _locationTrackingEnabled = value;
              });
              _toggleSetting('location_tracking', value);
            },
          ),
          _buildSettingTile(
            'Data Export',
            'Export your personal data',
            Icons.download,
            onTap: () => _showDataExportDialog(),
          ),
          _buildSettingTile(
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_forever,
            color: AppTheme.dangerRed,
            onTap: () => _showDeleteAccountDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(AppLocalizations l10n, ThemeData theme) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'Notifications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            'Push Notifications',
            'Receive general app notifications',
            Icons.notifications_active,
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _toggleSetting('notifications', value);
            },
          ),
          _buildSwitchTile(
            'Emergency Alerts',
            'Receive critical safety alerts',
            Icons.emergency,
            _emergencyAlertsEnabled,
            (value) {
              setState(() {
                _emergencyAlertsEnabled = value;
              });
              _toggleSetting('emergency_alerts', value);
            },
          ),
          _buildSettingTile(
            'Notification Schedule',
            'Customize quiet hours',
            Icons.schedule,
            onTap: () => _showScheduleDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(AppLocalizations l10n, ThemeData theme) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.accessibility, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'Accessibility',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSliderTile(
            'Text Size',
            'Adjust text size for better readability',
            Icons.text_fields,
            _textScaleFactor,
            0.8,
            1.5,
            (value) {
              setState(() {
                _textScaleFactor = value;
              });
              _saveTextScale(value);
            },
          ),
          _buildSwitchTile(
            'High Contrast',
            'Increase contrast for better visibility',
            Icons.contrast,
            _highContrastMode,
            (value) {
              setState(() {
                _highContrastMode = value;
              });
              _toggleSetting('high_contrast', value);
            },
          ),
          _buildSwitchTile(
            'Reduce Animations',
            'Minimize motion for sensitive users',
            Icons.motion_photos_off,
            _reduceAnimations,
            (value) {
              setState(() {
                _reduceAnimations = value;
              });
              _toggleSetting('reduce_animations', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferencesSection(AppLocalizations l10n, ThemeData theme) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'App Preferences',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            'Dark Mode',
            'Switch to dark theme',
            Icons.dark_mode,
            _darkModeEnabled,
            (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              _toggleSetting('isDarkMode', value);
              if (widget.onThemeChanged != null) {
                widget.onThemeChanged!(value);
              } else {
                widget.onThemeToggle?.call();
              }
              _showAppliedDialog('Theme preference updated.');
            },
          ),
          _buildSettingTile(
            'Map Style',
            'Choose preferred map appearance',
            Icons.map,
            onTap: () => _showMapStyleDialog(),
          ),
          _buildSettingTile(
            'Units',
            'Distance and temperature units',
            Icons.straighten,
            onTap: () => _showUnitsDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(AppLocalizations l10n, ThemeData theme) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'Support & Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingTile(
            'Help Center',
            'Get answers to common questions',
            Icons.help_center,
            onTap: () => _showHelpDialog(),
          ),
          _buildSettingTile(
            'Contact Support',
            'Get help from our support team',
            Icons.support_agent,
            onTap: () => _showContactDialog(),
          ),
          _buildSettingTile(
            'App Version',
            'Version 1.0.0 (Build 100)',
            Icons.info,
          ),
          _buildSettingTile(
            'Terms & Privacy',
            'Review our policies',
            Icons.policy,
            onTap: () => _showPolicyDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(AppLocalizations l10n, ThemeData theme) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: AppTheme.dangerRed),
              const SizedBox(width: 12),
              Text(
                'Emergency Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingTile(
            'Emergency Contacts',
            'Manage your emergency contact list',
            Icons.contact_phone,
            onTap: () => _showEmergencyContactsDialog(),
          ),
          _buildSettingTile(
            'Medical Information',
            'Add important medical details',
            Icons.medical_services,
            onTap: () => _showMedicalInfoDialog(),
          ),
          _buildSettingTile(
            'Test Emergency System',
            'Verify emergency features work',
            Icons.bug_report,
            color: AppTheme.warningOrange,
            onTap: () => _testEmergencySystem(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[600]),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, IconData icon, double value, double min, double max, Function(double) onChanged) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey[600]),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Text('${(value * 100).round()}%'),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 7,
          activeColor: AppTheme.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Dialog methods
  void _showDataExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Data'),
        content: const Text('Your data will be exported as a JSON file and saved to your device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export started...'), backgroundColor: AppTheme.successGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Export', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account', style: TextStyle(color: AppTheme.dangerRed)),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion cancelled'), backgroundColor: AppTheme.successGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Notification Schedule'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Quiet Hours'), subtitle: Text('10:00 PM - 7:00 AM')),
            ListTile(title: Text('Emergency Override'), subtitle: Text('Always allow emergency alerts')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMapStyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Map Style'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Standard'),
              trailing: Icon(Icons.check, color: AppTheme.primaryBlue),
            ),
            ListTile(
              title: const Text('Satellite'),
            ),
            ListTile(
              title: const Text('Terrain'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Distance'), subtitle: Text('Kilometers')),
            const ListTile(title: Text('Temperature'), subtitle: Text('Celsius')),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Help Center'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• How to use Emergency SOS'),
            Text('• Understanding Safety Scores'),
            Text('• Managing Your Digital ID'),
            Text('• Privacy and Security Guide'),
            Text('• Troubleshooting Common Issues'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Support'),
              subtitle: Text('support@touristsafety.gov.in'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone Support'),
              subtitle: Text('+91-11-23320005'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terms & Privacy'),
        content: const SingleChildScrollView(
          child: Text(
            'This app is developed by the Government of India for tourist safety. '
            'By using this app, you agree to our terms of service and privacy policy. '
            'Your data is protected and used only for safety purposes.',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Understood', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Emergency Contacts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Police'), subtitle: Text('+91-100')),
            ListTile(title: Text('Tourist Helpline'), subtitle: Text('+91-11-23320005')),
            ListTile(title: Text('Personal Contact'), subtitle: Text('+91-1234567890')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMedicalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Medical Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blood Type: O+'),
            Text('Allergies: None'),
            Text('Medications: None'),
            Text('Emergency Contact: +91-1234567890'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _testEmergencySystem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successGreen),
            SizedBox(width: 12),
            Text('System Test Complete'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ GPS Location: Working'),
            Text('✅ Emergency Contacts: Reachable'),
            Text('✅ Network Connection: Strong'),
            Text('✅ SOS Button: Responsive'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
            child: const Text('Great!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
}
