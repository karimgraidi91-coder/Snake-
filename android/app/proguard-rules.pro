# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads
-keep public class com.google.android.gms.ads.** {
   public *;
}
-keep public class com.google.ads.** {
    public *;
}

# Yandex Mobile Ads
-keep public class com.yandex.mobile.ads.** {
    public *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Firebase
-keep public class com.google.firebase.** {
    public *;
}

# AudioPlayers
-keep class com.google.android.exoplayer2.** {
    public *;
}

# Vibration
-keep class com.rnw.vibration.** {
    public *;
}

# Application classes
-keep class com.karim971210.snake_battle.** {
    public *;
}

# Suppress warnings
-dontwarn com.google.**
-dontwarn com.yandex.**
-dontwarn org.apache.**
-dontwarn com.android.vending.**
