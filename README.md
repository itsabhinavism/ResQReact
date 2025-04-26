# ResQReact [cite: 1, 2]

A Flutter application designed for fall detection and sending emergency alerts[cite: 1]. This app monitors sensor data to detect potential falls and can notify pre-configured emergency contacts with the user's location.

## Features [cite: 3]

* **Fall Detection:** Uses accelerometer and gyroscope data (`sensors_plus` package) to detect patterns indicative of a fall[cite: 1, 3].
* **Sensor Calibration:** Allows users to calibrate the sensor sensitivity based on their normal activity levels for more accurate detection[cite: 3].
* **Emergency Alerts:** Triggers a countdown timer upon detecting a potential fall, allowing the user to cancel if it's a false alarm[cite: 3].
* **Contact Notification:** If not canceled, sends alert messages (currently mocked via debug prints) including the user's last known location (`geolocator` package) to pre-defined emergency contacts[cite: 1, 3].
* **Settings & Configuration:**
    * Manage user name[cite: 3].
    * Add/Remove emergency contacts[cite: 3].
    * Adjust fall detection sensitivity threshold[cite: 3].
    * User data and settings are saved using `shared_preferences`[cite: 1, 3].
* **Permission Handling:** Requests necessary permissions (Location, SMS, Microphone) using `permission_handler`[cite: 1, 3].
* **Background Monitoring:** Aims to keep monitoring active even when the app is paused (basic implementation using `AppLifecycleState` and Timer)[cite: 3].

## Getting Started

This project is a Flutter application.

1.  **Ensure Flutter is installed:** Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).
2.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd ResQReact
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    * Make sure you have a connected device (emulator or physical device).
    * Run the command:
        ```bash
        flutter run
        ```

## Usage [cite: 3]

1.  **Launch the app:** A splash screen will appear briefly, followed by the main monitoring screen.
2.  **Configure Settings (Recommended):**
    * Tap the settings icon in the AppBar.
    * Enter your name.
    * Add emergency contacts (phone numbers or emails - *note: actual sending functionality via SMS/email needs implementation*).
    * Adjust the fall detection sensitivity slider if needed.
    * Grant necessary permissions when prompted or via the settings screen.
3.  **Calibrate System (Optional but Recommended):**
    * From the main screen, tap "Calibrate System".
    * Remain still for the countdown duration. This helps set a personalized fall detection threshold.
4.  **Start Monitoring:**
    * Tap the "Start Monitoring" button on the main screen. The app will now use device sensors to detect falls.
5.  **Fall Event:**
    * If a potential fall is detected, a dialog with a countdown will appear.
    * Tap "I'm OK" to cancel the alert.
    * Tap "Send Alert Now" or wait for the countdown to finish to trigger the (currently mocked) alert sending process.
6.  **Stop Monitoring:**
    * Tap the "Stop Monitoring" button on the main screen.

## Key Dependencies [cite: 1]

* `flutter`
* `sensors_plus`: For accessing accelerometer and gyroscope.
* `permission_handler`: For requesting device permissions.
* `geolocator`: For obtaining the device location.
* `shared_preferences`: For saving user settings locally.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Specify Your License Here - e.g., MIT License]


