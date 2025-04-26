# ✨ ResQReact ✨

**A Flutter application designed for fall detection and sending emergency alerts.** 🆘

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)]()
[![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D2.17.0-blue)](https://flutter.dev)
[![GitHub issues](https://img.shields.io/github/issues/YourUsername/ResQReact)](https://github.com/YourUsername/ResQReact/issues) [![GitHub stars](https://img.shields.io/github/stars/YourUsername/ResQReact)](https://github.com/YourUsername/ResQReact/stargazers) ---

ResQReact monitors device sensor data to detect potential falls and can notify pre-configured emergency contacts with the user's location, providing peace of mind.

## 🚀 Features

* 🤸 **Fall Detection:** Uses accelerometer and gyroscope data (`sensors_plus`) to detect fall patterns.
* 🔧 **Sensor Calibration:** Personalize sensitivity via calibration for improved accuracy.
* ⏰ **Emergency Alerts:** Countdown timer upon fall detection allows users to cancel false alarms.
* 📲 **Contact Notification:** Sends (currently mocked) alerts with location (`geolocator`) to emergency contacts.
* ⚙️ **Settings & Configuration:**
    * 👤 Manage user name.
    * 📞 Add/Remove emergency contacts.
    * 🎚️ Adjust fall detection sensitivity.
    * 💾 Settings saved locally (`shared_preferences`).
* 🔒 **Permission Handling:** Smoothly requests necessary permissions (`permission_handler`).
* 🏃 **Background Monitoring:** Basic capability to keep monitoring active when the app is paused.

---

## 🏁 Getting Started

This project is built with Flutter.

1.  **Install Flutter:** Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).
2.  **Clone:**
    ```bash
    git clone [https://github.com/YourUsername/ResQReact.git](https://github.com/YourUsername/ResQReact.git) # Replace YourUsername
    cd ResQReact
    ```
3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run:**
    * Connect a device or start an emulator.
    * Execute:
        ```bash
        flutter run
        ```

---

## 🛠️ Usage

1.  **Launch:** Open the ResQReact app.
2.  **Configure (Recommended):**
    * Navigate to `Settings` (⚙️ icon).
    * Set your name, add contacts, adjust sensitivity.
    * Grant permissions when prompted.
3.  **Calibrate (Optional):**
    * On the main screen, tap `Calibrate System`.
    * Stay still during the countdown.
4.  **Monitor:**
    * Tap `Start Monitoring`.
5.  **Fall Event:**
    * Dialog appears -> Tap `I'm OK` or let the timer run out / tap `Send Alert Now`.
6.  **Stop:**
    * Tap `Stop Monitoring`.

---

## 📦 Key Dependencies

* `flutter`: The core framework.
* `sensors_plus`: Accelerometer & Gyroscope access.
* `permission_handler`: Requesting device permissions.
* `geolocator`: Fetching location data.
* `shared_preferences`: Local data persistence.

---

## 🤝 Contributing

Contributions make the open-source community amazing! Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📜 License

Distributed under the [Specify License Name Here] License. See `LICENSE` file for more information.

*(Example: Distributed under the MIT License. See `LICENSE` for more information.)*

---
