# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Drift (SQLite)
-keep class drift.** { *; }
-keep class * extends drift.Database { *; }

# Socket.IO
-keep class io.socket.** { *; }

# Keep annotation
-keepattributes *Annotation*
