# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep sensor libraries
-keep class com.google.android.gms.** { *; }
-keep class androidx.** { *; }

# Keep permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep geolocator
-keep class com.baseflow.geolocator.** { *; }

# Keep shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep Play Core libraries
-keep class com.google.android.play.core.** { *; }

# Ignore missing Play Store classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep device info plus
-keep class dev.fluttercommunity.plus.device_info.** { *; }
