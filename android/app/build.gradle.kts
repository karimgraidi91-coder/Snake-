plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.karim971210.snake_battle"
    // Use a minimum compileSdk of 36 to satisfy plugin AAR metadata requirements
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        buildConfig = true
        resValues = true
    }

    defaultConfig {
        applicationId = "com.karim971210.snake_battle"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    flavorDimensions += listOf("version")

    productFlavors {
        create("noads") {
            dimension = "version"
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            buildConfigField("String", "AD_TYPE", "\"NONE\"")
            buildConfigField("boolean", "ENABLE_ADMOB", "false")
            buildConfigField("boolean", "ENABLE_YANDEX", "false")
        }
        create("yandex") {
            dimension = "version"
            applicationIdSuffix = ".yandex"
            versionNameSuffix = "-yandex"
            buildConfigField("String", "AD_TYPE", "\"YANDEX\"")
            buildConfigField("boolean", "ENABLE_ADMOB", "false")
            buildConfigField("boolean", "ENABLE_YANDEX", "true")
            resValue("string", "yandex_app_id", "269350095")
        }
        create("admob") {
            dimension = "version"
            applicationIdSuffix = ".admob"
            versionNameSuffix = "-admob"
            buildConfigField("String", "AD_TYPE", "\"ADMOB\"")
            buildConfigField("boolean", "ENABLE_ADMOB", "true")
            buildConfigField("boolean", "ENABLE_YANDEX", "false")
        }
    }

    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "snake_battle_keystore"
            keyAlias = System.getenv("KEY_ALIAS") ?: "snake_battle_key"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "snake_battle_key_password"
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable = true
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    // Yandex Mobile Ads removed due to Android build compatibility issues
    implementation("com.google.firebase:firebase-analytics:21.2.2")
    implementation("com.google.firebase:firebase-core:21.1.1")
    implementation("androidx.multidex:multidex:2.0.1")
}
