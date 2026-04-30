## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }

## flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

## Keep annotations
-keepattributes *Annotation*

## Google Play Core (Fixes R8 Missing class com.google.android.play.core.*)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

## Ignore warnings from Flutter's deferred components embedding
-dontwarn io.flutter.embedding.**
