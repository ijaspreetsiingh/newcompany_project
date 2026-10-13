# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase / FCM
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Play Core (Flutter deferred components)
-dontwarn com.google.android.play.core.**

# Kotlin / coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Flutter local notifications + audioplayers + geolocator plugin keep rules
-keep class com.dexterous.flutternotifications.** { *; }
-keep class com.ryanheise.audioplayers.** { *; }
-keep class com.baseflow.geolocator.** { *; }

# flutter_secure_storage (Keystore)
-keep class com.it_nomads.fluttersecurestorage.** { *; }
