// main.dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'package:android_intent_plus/android_intent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResQReactApp());
}

class NotificationManager {
  static void showMonitoringActive() {
    // Enhanced notification message
    debugPrint('Monitoring active: ResQReact is actively monitoring for falls');

    // Vibrate device to provide feedback
    _vibrate(pattern: [0, 100, 50, 100]);
  }

  static void showEmergencyAlert() {
    // Enhanced emergency alert message
    debugPrint(
        'EMERGENCY ALERT: Fall detected! Sending alerts to emergency contacts.');

    // Vibrate device with emergency pattern
    _vibrate(pattern: [0, 500, 200, 500, 200, 500]);
  }

  static void cancelNotification(int id) {
    debugPrint('Notification $id cancelled');
  }

  // Helper method to vibrate the device
  static void _vibrate({required List<int> pattern}) {
    // This would use platform channels to trigger vibration
    // For now, we just log the pattern
    debugPrint('Device would vibrate with pattern: $pattern');
  }
}

class ResQReactApp extends StatefulWidget {
  const ResQReactApp({Key? key}) : super(key: key);

  @override
  State<ResQReactApp> createState() => _ResQReactAppState();
}

class _ResQReactAppState extends State<ResQReactApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQReact',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
          primary: Colors.red,
          secondary: Colors.redAccent,
          tertiary: Colors.green,
        ),
        useMaterial3: true,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: const CardTheme(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
          primary: Colors.red,
          secondary: Colors.redAccent,
          tertiary: Colors.green,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: const CardTheme(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: SplashScreen(
          setThemeMode: setThemeMode, currentThemeMode: _themeMode),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Function(ThemeMode)? setThemeMode;
  final ThemeMode? currentThemeMode;

  const SplashScreen({Key? key, this.setThemeMode, this.currentThemeMode})
      : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    // Start the animation
    _animationController.forward();

    // Navigate to HomeScreen after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutQuart;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Theme toggle button
          if (widget.setThemeMode != null)
            IconButton(
              icon: Icon(
                widget.currentThemeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                if (widget.setThemeMode != null) {
                  widget.setThemeMode!(
                    widget.currentThemeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  );
                }
              },
            ),
        ],
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'ResQReact',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                                letterSpacing: 1.2,
                              ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Fall Detection & Emergency Alerts',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isMonitoring = false;
  bool _isDarkMode = false;
  bool _isCalibrating = false;
  String _userName = "";
  List<String> _contacts = [];
  bool _allPermissionsGranted = false;
  double _fallThreshold = 15.0; // Default threshold
  Timer? _calibrationTimer;
  Timer? _backgroundTimer;
  List<double> _accelerationMagnitudes = [];
  int _countdownSeconds = 3;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  Position? _currentPosition;
  double _currentAcceleration = 0.0;
  double _meanRestingAcceleration = 9.8; // Initial value (earth's gravity)
  double _stdDevRestingAcceleration = 1.0; // Initial standard deviation

  // SMS frequency settings
  int _smsCount = 3; // Default to 3 SMS messages
  int _smsIntervalMinutes = 5; // Default to 5 minute intervals

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize the app
    _checkAndRequestPermissions(); // Changed to check permissions first
    _loadUserData();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopMonitoring();
    _backgroundTimer?.cancel();
    _calibrationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Keep the service running in background
    if (state == AppLifecycleState.paused && _isMonitoring) {
      _setupBackgroundTask();
    }
  }

  // Set up a background task to ensure monitoring continues
  void _setupBackgroundTask() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSensorsActive();
    });
  }

  // Ensure sensors are still active
  void _checkSensorsActive() {
    if (_isMonitoring &&
        (_accelerometerSubscription == null ||
            _gyroscopeSubscription == null)) {
      _startMonitoring();
    }
  }

  // Check permissions and request if needed on startup
  Future<void> _checkAndRequestPermissions() async {
    // Check current permission status first
    PermissionStatus locationStatus = await Permission.location.status;
    PermissionStatus smsStatus = await Permission.sms.status;
    PermissionStatus microphoneStatus = await Permission.microphone.status;

    // Update the permission status flag
    setState(() {
      _allPermissionsGranted = locationStatus.isGranted &&
          smsStatus.isGranted &&
          microphoneStatus.isGranted;
    });

    // Automatically request permissions on fresh install
    if (!_allPermissionsGranted) {
      _requestPermissions();
    }
  }

  // Show permission dialog and request permissions
  Future<void> _requestPermissions() async {
    // Check current permission status first
    PermissionStatus locationStatus = await Permission.location.status;
    PermissionStatus smsStatus = await Permission.sms.status;
    PermissionStatus microphoneStatus = await Permission.microphone.status;

    // Show a more detailed dialog explaining why permissions are needed
    if (!locationStatus.isGranted ||
        !smsStatus.isGranted ||
        !microphoneStatus.isGranted) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Important Permissions Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ResQReact needs the following permissions to function properly:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildPermissionExplanation(
                  'Location',
                  'To send your exact location in emergency alerts',
                  Icons.location_on,
                  locationStatus.isGranted,
                ),
                const SizedBox(height: 8),
                _buildPermissionExplanation(
                  'SMS',
                  'To send emergency messages to your contacts',
                  Icons.sms,
                  smsStatus.isGranted,
                ),
                const SizedBox(height: 8),
                _buildPermissionExplanation(
                  'Microphone',
                  'For voice commands during emergencies',
                  Icons.mic,
                  microphoneStatus.isGranted,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Request permissions after explanation
                  await _requestEachPermission();
                },
                child: const Text('Grant Permissions'),
              ),
            ],
          ),
        );
      }
    } else {
      // All permissions already granted
      setState(() {
        _allPermissionsGranted = true;
      });
      debugPrint('All required permissions already granted');
    }
  }

  // Helper widget to show permission explanation with status
  Widget _buildPermissionExplanation(
      String title, String description, IconData icon, bool isGranted) {
    return Row(
      children: [
        Icon(icon, color: isGranted ? Colors.green : Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Icon(
          isGranted ? Icons.check_circle : Icons.error,
          color: isGranted ? Colors.green : Colors.red,
          size: 20,
        ),
      ],
    );
  }

  // Request each permission individually with proper handling
  Future<void> _requestEachPermission() async {
    bool allGranted = true;

    // Request location permission
    PermissionStatus locationStatus = await Permission.location.request();
    if (!locationStatus.isGranted && mounted) {
      allGranted = false;
      _showPermissionDeniedDialog('Location');
    }

    // Request SMS permission
    PermissionStatus smsStatus = await Permission.sms.request();
    if (!smsStatus.isGranted && mounted) {
      allGranted = false;
      _showPermissionDeniedDialog('SMS');
    }

    // Request microphone permission
    PermissionStatus microphoneStatus = await Permission.microphone.request();
    if (!microphoneStatus.isGranted && mounted) {
      allGranted = false;
      _showPermissionDeniedDialog('Microphone');
    }

    // Update permission status
    if (mounted) {
      setState(() {
        _allPermissionsGranted = allGranted;
      });
    }

    // Check if any permission is permanently denied and show settings option
    if ((locationStatus.isPermanentlyDenied ||
            smsStatus.isPermanentlyDenied ||
            microphoneStatus.isPermanentlyDenied) &&
        mounted) {
      _showOpenSettingsDialog();
    }
  }

  // Show dialog for individual permission denial
  void _showPermissionDeniedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
            '$permissionName permission is needed for the app to function properly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Show dialog to open settings for permanently denied permissions
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Some permissions have been permanently denied. Please open settings and enable them manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _contacts = prefs.getStringList('emergencyContacts') ?? [];
      _fallThreshold = prefs.getDouble('fallThreshold') ?? 15.0;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setStringList('emergencyContacts', _contacts);
    await prefs.setDouble('fallThreshold', _fallThreshold);
  }

  void _startLocationUpdates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Get current position periodically
      Geolocator.getPositionStream().listen((Position position) {
        setState(() {
          _currentPosition = position;
        });
      });
    } catch (e) {
      debugPrint('Error starting location updates: $e');
    }
  }

  void _calibrateSystem() {
    setState(() {
      _isCalibrating = true;
      _countdownSeconds = 3;
    });

    _accelerationMagnitudes.clear();

    // Start countdown timer
    _calibrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
        } else {
          _isCalibrating = false;
          timer.cancel();
          _finishCalibration();
        }
      });
    });

    // Subscribe to accelerometer during calibration
    _accelerometerSubscription = userAccelerometerEvents.listen((event) {
      if (_isCalibrating) {
        final double x = event.x;
        final double y = event.y;
        final double z = event.z;
        final double magnitude = sqrt(x * x + y * y + z * z);

        if (_accelerationMagnitudes.length < 100) {
          _accelerationMagnitudes.add(magnitude);
        }
      }
    });
  }

  void _finishCalibration() {
    if (_accelerationMagnitudes.isEmpty) {
      // Use defaults if no data collected
      _meanRestingAcceleration = 9.8;
      _stdDevRestingAcceleration = 1.0;
    } else {
      // Calculate mean
      double sum = 0;
      for (var magnitude in _accelerationMagnitudes) {
        sum += magnitude;
      }
      _meanRestingAcceleration = sum / _accelerationMagnitudes.length;

      // Calculate standard deviation
      double sumSquaredDiff = 0;
      for (var magnitude in _accelerationMagnitudes) {
        sumSquaredDiff += pow(magnitude - _meanRestingAcceleration, 2);
      }
      _stdDevRestingAcceleration =
          sqrt(sumSquaredDiff / _accelerationMagnitudes.length);
    }

    // Set threshold to be mean + 3 * stdDev (covers 99.7% of normal activity)
    _fallThreshold = _meanRestingAcceleration +
        (3 * _stdDevRestingAcceleration) +
        5.0; // Add safety margin

    // Save the calibrated threshold
    _saveUserData();

    // Clean up calibration subscription
    _accelerometerSubscription?.cancel();

    // Show calibration results
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Calibration complete. Fall threshold: ${_fallThreshold.toStringAsFixed(2)}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _startMonitoring() {
    if (_isMonitoring) return;

    setState(() {
      _isMonitoring = true;
    });

    // Subscribe to accelerometer events
    _accelerometerSubscription = userAccelerometerEventStream().listen((event) {
      final double x = event.x;
      final double y = event.y;
      final double z = event.z;
      final double magnitude = sqrt(x * x + y * y + z * z);

      setState(() {
        _currentAcceleration = magnitude;
      });

      // Detect falls using the threshold
      if (magnitude > _fallThreshold) {
        _verifyFallWithGyroscope();
      }
    });

    // Subscribe to gyroscope events
    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      // Data will be used in fall verification
    });

    // Show a notification that the app is monitoring
    NotificationManager.showMonitoringActive();
  }

  void _stopMonitoring() {
    setState(() {
      _isMonitoring = false;
    });

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;

    // Cancel background timer if active
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    // Cancel monitoring notification
    NotificationManager.cancelNotification(1);
  }

  void _verifyFallWithGyroscope() {
    // Implement a short delay to check if the person has recovered
    Timer(const Duration(seconds: 3), () {
      // If we're still above threshold after delay, it's likely a real fall
      if (_currentAcceleration > _fallThreshold * 0.7) {
        _triggerEmergencyAlert();
      }
    });
  }

  void _triggerEmergencyAlert() {
    // Show alert dialog with countdown
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        int countDown = 15;
        Timer? countdownTimer;

        return StatefulBuilder(builder: (context, setDialogState) {
          // Start the countdown immediately when dialog shows
          if (countdownTimer == null) {
            // Use exact 1000ms interval for accurate 15-second countdown
            countdownTimer =
                Timer.periodic(const Duration(milliseconds: 1000), (timer) {
              if (countDown > 0) {
                setDialogState(() {
                  countDown--;
                });
              } else {
                timer.cancel();
                Navigator.of(dialogContext)
                    .pop(true); // Return true to indicate sending alerts
              }
            });
          }

          return PopScope(
            canPop: false, // Prevent back button from dismissing
            child: AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF2D2D2D) // Dark theme background
                  : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fall Detected!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red.shade900.withOpacity(0.15)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'We detected a possible fall. Emergency contacts will be alerted if you don\'t respond.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Countdown timer with circular progress indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: countDown /
                                15, // 15 is the initial countdown value
                            strokeWidth: 8,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$countDown',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Text('seconds',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Will send $_smsCount SMS messages\nevery $_smsIntervalMinutes minutes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop(false); // Don't send alerts
                  },
                  child: const Text('I\'m OK - Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext)
                        .pop(true); // Send alerts immediately
                  },
                  child: const Text('Send Alerts Now'),
                ),
              ],
            ),
          );
        });
      },
    ).then((sendAlerts) {
      // Only send alerts if the result is true
      if (sendAlerts == true) {
        _sendEmergencyAlerts();
      }
    });
  }

  void _sendEmergencyAlerts() {
    // Get location
    String locationStr = 'Unknown location';
    if (_currentPosition != null) {
      locationStr =
          'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';
    }

    // Show confirmation notification
    NotificationManager.showEmergencyAlert();

    // Create the emergency message
    final String emergencyMessage =
        'EMERGENCY: $_userName may have fallen and needs help. ' +
            'Location: $locationStr';

    // Schedule multiple SMS messages based on user settings
    _scheduleSmsMessages(emergencyMessage);

    // For demo purposes, show what would be sent
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency Alert Sent'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Alert sent to emergency contacts:'),
              const SizedBox(height: 10),
              Text(_contacts.isEmpty
                  ? 'No contacts configured'
                  : _contacts.join(', ')),
              const SizedBox(height: 15),
              const Text('Message sent:'),
              const SizedBox(height: 5),
              Text(
                emergencyMessage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                'Sending $_smsCount messages with $_smsIntervalMinutes minute intervals',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _scheduleSmsMessages(String message) {
    // Log the message for debugging
    debugPrint(
        'Scheduling $_smsCount SMS messages with $_smsIntervalMinutes minute intervals');

    // Send first SMS immediately
    _sendSmsToContacts(message, 1);

    // Schedule additional SMS messages if needed
    for (int i = 1; i < _smsCount; i++) {
      debugPrint('Scheduling message ${i + 1}: $message');
      // Schedule future SMS messages
      Future.delayed(Duration(minutes: i * _smsIntervalMinutes), () {
        _sendSmsToContacts(message, i + 1);
      });
    }
  }

  // Helper method to actually send SMS messages
  Future<void> _sendSmsToContacts(String message, int messageNumber) async {
    debugPrint('Sending emergency SMS $messageNumber of $_smsCount');

    if (_contacts.isEmpty) {
      debugPrint('No emergency contacts configured');
      return;
    }

    // Check if SMS permission is granted
    PermissionStatus smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted) {
      debugPrint('SMS permission not granted, requesting...');
      smsStatus = await Permission.sms.request();
      if (!smsStatus.isGranted) {
        debugPrint('SMS permission denied, cannot send messages');
        return;
      }
    }

    // Show a dialog to inform the user about SMS being sent
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sending Emergency SMS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Emergency SMS messages are being sent to your contacts.'),
              const SizedBox(height: 10),
              Text('Contacts: ${_contacts.join(", ")}'),
              const SizedBox(height: 10),
              const Text('Message:'),
              Text(message,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    // Send SMS to each contact using flutter_sms
    bool allSent = true;
    for (String contact in _contacts) {
      try {
        // Format phone number (remove any non-digit characters)
        String phoneNumber = contact.replaceAll(RegExp(r'\D'), '');

        // Use Android Intent to send SMS directly
        try {
          // Create an Android Intent for sending SMS
          final AndroidIntent intent = AndroidIntent(
            action: 'android.intent.action.SENDTO',
            data: 'smsto:$phoneNumber',
            arguments: <String, dynamic>{
              'sms_body': message,
              // Add these flags to try to send SMS automatically
              'android.intent.extra.PROCESS_TEXT': message,
              'exit_on_sent': true,
            },
            // These flags help with automatic sending
            flags: <int>[
              0x10000000, // FLAG_ACTIVITY_NEW_TASK
              0x00800000, // FLAG_ACTIVITY_NO_HISTORY
            ],
          );

          // Launch the intent
          await intent.launch();
          debugPrint('SMS intent launched for $phoneNumber');

          // Small delay to allow intent to process
          await Future.delayed(const Duration(milliseconds: 800));

          // Try to send a second intent to press the send button
          // This is a hack but sometimes works on certain devices
          final AndroidIntent sendIntent = AndroidIntent(
            action: 'android.intent.action.PROCESS_TEXT',
            arguments: <String, dynamic>{
              'android.intent.extra.PROCESS_TEXT': '',
            },
          );

          try {
            await sendIntent.launch();
            debugPrint('Send button press attempted');
          } catch (e) {
            // Ignore errors from the send button press attempt
            debugPrint('Send button press failed: $e');
          }
        } catch (e) {
          debugPrint('Error launching SMS intent: $e');
          allSent = false;
        }

        // Small delay between sending multiple SMS
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Failed to send SMS to $contact: $e');
        allSent = false;
      }
    }

    // Log the result
    if (allSent) {
      debugPrint(
          'All emergency alerts successfully sent to ${_contacts.length} contacts');
    } else {
      debugPrint('Some emergency alerts failed to send');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResQReact'),
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final currentTheme = Theme.of(context).brightness;
              final newThemeMode = currentTheme == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;

              // Find the ResQReactApp ancestor and update its theme
              final appState =
                  context.findAncestorStateOfType<_ResQReactAppState>();
              if (appState != null) {
                appState.setThemeMode(newThemeMode);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    userName: _userName,
                    contacts: _contacts,
                    fallThreshold: _fallThreshold,
                    smsCount: _smsCount,
                    smsIntervalMinutes: _smsIntervalMinutes,
                    onSettingsChanged:
                        (name, contacts, threshold, smsCount, smsInterval) {
                      setState(() {
                        _userName = name;
                        _contacts = contacts;
                        _fallThreshold = threshold;
                        _smsCount = smsCount;
                        _smsIntervalMinutes = smsInterval;
                      });
                      _saveUserData();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isCalibrating ? _buildCalibrationView() : _buildMonitoringView(),
    );
  }

  Widget _buildCalibrationView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sensors, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Calibrating Sensors',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Please remain still for $_countdownSeconds seconds',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          CircularProgressIndicator(
            value: (_countdownSeconds > 0) ? (3 - _countdownSeconds) / 3 : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Permissions Status Card - Only show if permissions are not granted
          if (!_allPermissionsGranted) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'App Permissions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.settings),
                          label: const Text('Manage'),
                          onPressed: () => _requestPermissions(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Make sure all permissions are granted for full functionality',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Status Card with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Card(
                  elevation: 8,
                  shadowColor: _isMonitoring
                      ? Colors.green.withOpacity(0.4)
                      : Colors.red.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Status Text with Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: Text(
                                _isMonitoring
                                    ? 'Monitoring Active'
                                    : 'Monitoring Inactive',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isMonitoring ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Shield Icon with Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.5, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    _isMonitoring
                                        ? Icons.shield
                                        : Icons.shield_outlined,
                                    size: 100,
                                    color: _isMonitoring
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  if (_isMonitoring)
                                    TweenAnimationBuilder<double>(
                                      tween:
                                          Tween<double>(begin: 0.7, end: 1.3),
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      curve: Curves.easeInOut,
                                      builder: (context, pulse, _) {
                                        return RepaintBoundary(
                                          child: CustomPaint(
                                            size: const Size(120, 120),
                                            painter: PulseEffectPainter(
                                              color:
                                                  Colors.green.withOpacity(0.3),
                                              radius: 50 * pulse,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 25),

                        // Acceleration Data with Animation
                        if (_isMonitoring)
                          AnimatedOpacity(
                            opacity: _isMonitoring ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                const Text(
                                  'Current Acceleration:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: _currentAcceleration,
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, value, _) {
                                    return Text(
                                      '${value.toStringAsFixed(2)} m/s²',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: value > _fallThreshold * 0.8
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 15),
                                Stack(
                                  children: [
                                    // Background track
                                    Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    // Animated progress
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0,
                                        end: _currentAcceleration /
                                            (_fallThreshold * 1.5),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 300),
                                      builder: (context, value, _) {
                                        return FractionallySizedBox(
                                          widthFactor: value.clamp(0.0, 1.0),
                                          child: Container(
                                            height: 12,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: _currentAcceleration >
                                                        _fallThreshold * 0.8
                                                    ? [
                                                        Colors.orange,
                                                        Colors.red
                                                      ]
                                                    : [
                                                        Colors.lightGreen,
                                                        Colors.green
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Threshold marker
                                    Positioned(
                                      left: (_fallThreshold /
                                              (_fallThreshold * 1.5) *
                                              100)
                                          .clamp(0.0, 100.0),
                                      child: Container(
                                        height: 20,
                                        width: 2,
                                        color: Colors.red[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Fall Threshold: ${_fallThreshold.toStringAsFixed(2)} m/s²',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // Control Buttons with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed:
                            _isMonitoring ? _stopMonitoring : _startMonitoring,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isMonitoring ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isMonitoring
                                ? Icons.stop_circle
                                : Icons.play_circle),
                            const SizedBox(width: 10),
                            Text(
                              _isMonitoring
                                  ? 'Stop Monitoring'
                                  : 'Start Monitoring',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _calibrateSystem,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.sensors),
                            SizedBox(width: 10),
                            Text('Calibrate System',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Warning Card with Animation
          if (_contacts.isEmpty)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(0.2)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.amber.shade900.withOpacity(0.3)
                                  : Colors.amber.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning,
                                color: Colors.amber, size: 24),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Text(
                              'No emergency contacts added. Please add contacts in settings.',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          const Spacer(),

          // Emergency Test Button with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 220, // Reduced width
                  child: ElevatedButton(
                    onPressed: _triggerEmergencyAlert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Color(0xFF8B0000) // Dark red for dark theme
                              : Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16), // Reduced padding
                      elevation: 4, // Reduced elevation
                      shadowColor: Colors.red.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Make row take minimum space
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            size: 20), // Smaller icon
                        SizedBox(width: 8), // Reduced spacing
                        Text(
                          'Test Emergency Alert',
                          style: TextStyle(
                            fontSize: 16, // Smaller font
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom painter for pulse effect animation
class PulseEffectPainter extends CustomPainter {
  final Color color;
  final double radius;

  PulseEffectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(PulseEffectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class SettingsScreen extends StatefulWidget {
  final String userName;
  final List<String> contacts;
  final double fallThreshold;
  final int smsCount;
  final int smsIntervalMinutes;
  final Function(String, List<String>, double, int, int) onSettingsChanged;

  const SettingsScreen({
    Key? key,
    required this.userName,
    required this.contacts,
    required this.fallThreshold,
    required this.smsCount,
    required this.smsIntervalMinutes,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late List<String> _contacts;
  late double _fallThreshold;
  late int _smsCount;
  late int _smsIntervalMinutes;
  final TextEditingController _newContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _contacts = List.from(widget.contacts);
    // Ensure _fallThreshold is within the allowed range (8.0 to 25.0)
    _fallThreshold = widget.fallThreshold.clamp(8.0, 25.0);
    _smsCount = widget.smsCount;
    _smsIntervalMinutes = widget.smsIntervalMinutes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newContactController.dispose();
    super.dispose();
  }

  void _addContact() {
    final contact = _newContactController.text.trim();
    if (contact.isNotEmpty) {
      setState(() {
        _contacts.add(contact);
        _newContactController.clear();
      });
    }
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  void _saveSettings() {
    widget.onSettingsChanged(
      _nameController.text.trim(),
      _contacts,
      _fallThreshold,
      _smsCount,
      _smsIntervalMinutes,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Fall Detection Sensitivity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lower values are more sensitive (more likely to trigger)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _fallThreshold,
              min: 8.0,
              max: 25.0,
              divisions: 17,
              label: _fallThreshold.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _fallThreshold = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('More Sensitive'),
                Text('Less Sensitive'),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.contact_phone),
                    title: Text(_contacts[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeContact(index),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newContactController,
                    decoration: const InputDecoration(
                      labelText: 'Add Contact (Phone or Email)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.add),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addContact,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'SMS Alert Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Number of SMS alerts to send',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _smsCount.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _smsCount.toString(),
              onChanged: (value) {
                setState(() {
                  _smsCount = value.toInt();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('1 SMS'),
                Text('5 SMS'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Interval between SMS alerts (minutes)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _smsIntervalMinutes.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _smsIntervalMinutes.toString(),
              onChanged: (value) {
                setState(() {
                  _smsIntervalMinutes = value.toInt();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('1 min'),
                Text('10 min'),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Permissions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPermissionTile(
              'Location',
              'Required for emergency alerts',
              Icons.location_on,
              () async {
                // Check current permission status
                PermissionStatus status =
                    await Permission.locationAlways.status;

                if (status.isPermanentlyDenied) {
                  // If permanently denied, open app settings
                  await openAppSettings();
                } else {
                  // Otherwise request permission normally
                  await Permission.locationAlways.request();
                }
              },
            ),
            _buildPermissionTile(
              'SMS',
              'For sending emergency messages',
              Icons.sms,
              () async {
                // Check current permission status
                PermissionStatus status = await Permission.sms.status;

                if (status.isPermanentlyDenied) {
                  // If permanently denied, open app settings
                  await openAppSettings();
                } else {
                  // Otherwise request permission normally
                  await Permission.sms.request();
                }
              },
            ),
            _buildPermissionTile(
              'Microphone',
              'Required for voice commands',
              Icons.mic,
              () async {
                // Check current permission status
                PermissionStatus status = await Permission.microphone.status;

                if (status.isPermanentlyDenied) {
                  // If permanently denied, open app settings
                  await openAppSettings();
                } else {
                  // Otherwise request permission normally
                  await Permission.microphone.request();
                }
              },
            ),
            const SizedBox(height: 32),
            // Animated "made by abhinav" text with theme adaptability
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  // Get appropriate color based on theme
                  final Color textColor =
                      Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFFB388FF) // Light purple for dark theme
                          : Color(0xFF6200EA); // Deep purple for light theme

                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.purple.withOpacity(0.15)
                              : Colors.purple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: textColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Made by Abhinav',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
      String title, String subtitle, IconData icon, Function() onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
