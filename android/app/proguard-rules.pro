# Flutter Wrapper Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Drift / SQLite Native Libs
-keep class net.sqlcipher.** { *; }
-keep class io.simonbinder.sqlite3.** { *; }

# Ignore warnings for Play Core deferred components and Tink
-dontwarn com.google.android.play.core.**
-dontwarn com.google.crypto.tink.**

# Keep annotations
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
