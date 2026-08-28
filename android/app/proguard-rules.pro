# Flutter and its plugins are reached reflectively from the engine, so R8
# cannot see the references and would otherwise strip them.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_local_notifications deserialises scheduled notifications from disk
# via Gson, which needs the generic signatures intact.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Firebase and Play Services resolve classes by name at runtime.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter's engine references Play Core's split-install API for deferred
# components. This app doesn't use deferred components, so that library isn't
# on the classpath and R8 sees dangling references. The code paths are never
# reached, so the references are safe to ignore rather than to satisfy.
-dontwarn com.google.android.play.core.**
