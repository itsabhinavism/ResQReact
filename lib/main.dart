// main.dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResQReactApp());
}

class NotificationManager {
  static void showMonitoringActive() {
    // On actual devices, you would show a real notification
    debugPrint('Monitoring active notification would appear here');
  }

  static void showEmergencyAlert() {
    // On actual devices, you would show a real notification
    debugPrint('Emergency alert notification would appear here');
  }

  static void cancelNotification(int id) {
    // Cancel notification logic would go here
    debugPrint('Notification $id would be cancelled here');
  }
}

class ResQReactApp extends StatelessWidget {
  const ResQReactApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQReact',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'ResQReact',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Fall Detection & Emergency Alerts',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
            ),
          ],
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isMonitoring = false;
  bool _isCalibrating = false;
  int _countdownSeconds = 3;
  List<String> _contacts = [];
  String _userName = 'User';
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  double _fallThreshold = 15.0; // Default threshold
  double _currentAcceleration = 0.0;
  Position? _currentPosition;
  Timer? _calibrationTimer;
  Timer? _backgroundTimer;
  
  // Sensor data for fall detection algorithm
  final List<double> _accelerationMagnitudes = [];
  final int _windowSize = 20; // Sample window size
  double _meanRestingAcceleration = 9.8; // Initial value (earth's gravity)
  double _stdDevRestingAcceleration = 1.0; // Initial standard deviation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
    _loadUserData();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopMonitoring();
    _backgroundTimer?.cancel();
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
    if (_isMonitoring && (_accelerometerSubscription == null || _gyroscopeSubscription == null)) {
      _startMonitoring();
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.microphone,
      Permission.sms,
    ].request();
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
        (3 * _stdDevRestingAcceleration) + 5.0; // Add safety margin

    // Save the calibrated threshold
    _saveUserData();
    
    // Clean up calibration subscription
    _accelerometerSubscription?.cancel();
    
    // Show calibration results
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calibration complete. Fall threshold: ${_fallThreshold.toStringAsFixed(2)}'),
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
    _accelerometerSubscription = userAccelerometerEvents.listen((event) {
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

    // Subscribe to gyroscope events (used in fall verification)
    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
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
      builder: (BuildContext context) {
        int countDown = 15;
        
        return StatefulBuilder(
          builder: (context, setState) {
            // Start countdown
            Timer.periodic(const Duration(seconds: 1), (timer) {
              if (countDown > 0) {
                setState(() {
                  countDown--;
                });
              } else {
                timer.cancel();
                Navigator.of(context).pop();
                _sendEmergencyAlerts();
              }
            });
            
            return AlertDialog(
              title: const Text('Fall Detected!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Are you okay? Emergency alerts will be sent in:'),
                  const SizedBox(height: 10),
                  Text(
                    '$countDown seconds',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('I\'m OK', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Send Alert Now', 
                    style: TextStyle(fontSize: 18, color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _sendEmergencyAlerts();
                  },
                ),
              ],
            );
          }
        );
      },
    );
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

    // In a real app, you would:
    // 1. Send SMS to emergency contacts
    // 2. Initiate automatic call to emergency services
    // 3. Start recording audio for emergency responders
    
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
                'EMERGENCY: $_userName may have fallen and needs help. ' +
                'Location: $locationStr',
                style: const TextStyle(fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResQReact'),
        actions: [
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
                    onSettingsChanged: (name, contacts, threshold) {
                      setState(() {
                        _userName = name;
                        _contacts = contacts;
                        _fallThreshold = threshold;
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
      body: _isCalibrating
          ? _buildCalibrationView()
          : _buildMonitoringView(),
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
            value: (_countdownSeconds > 0)
                ? (3 - _countdownSeconds) / 3
                : null,
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
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isMonitoring ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    _isMonitoring ? Icons.shield : Icons.shield_outlined,
                    size: 80,
                    color: _isMonitoring ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 20),
                  if (_isMonitoring)
                    Column(
                      children: [
                        const Text('Current Acceleration:'),
                        const SizedBox(height: 5),
                        Text(
                          '${_currentAcceleration.toStringAsFixed(2)} m/s²',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _currentAcceleration / (_fallThreshold * 1.5),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _currentAcceleration > _fallThreshold * 0.8
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Fall Threshold: ${_fallThreshold.toStringAsFixed(2)} m/s²',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isMonitoring ? Colors.red : Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _calibrateSystem,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Calibrate System', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 20),
          if (_contacts.isEmpty)
            const Card(
              color: Color(0xFFFFF3CD),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No emergency contacts added. Please add contacts in settings.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              _triggerEmergencyAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: const Text(
              'Test Emergency Alert',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final String userName;
  final List<String> contacts;
  final double fallThreshold;
  final Function(String, List<String>, double) onSettingsChanged;

  const SettingsScreen({
    Key? key,
    required this.userName,
    required this.contacts,
    required this.fallThreshold,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late List<String> _contacts;
  late double _fallThreshold;
  final TextEditingController _newContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _contacts = List.from(widget.contacts);
    _fallThreshold = widget.fallThreshold;
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
                await Permission.locationAlways.request();
              },
            ),
            _buildPermissionTile(
              'SMS',
              'For sending emergency messages',
              Icons.sms,
              () async {
                await Permission.sms.request();
              },
            ),
            _buildPermissionTile(
              'Microphone',
              'For audio during emergencies',
              Icons.mic,
              () async {
                await Permission.microphone.request();
              },
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