plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sn.apnabatwa"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.sn.apnabatwa"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }


    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        if (buildType.name == "debug") {
            outputs.all {
                val output = this as? com.android.build.gradle.internal.api.ApkVariantOutputImpl
                output?.outputFileName = "ApnaBatwa.apk"
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
    }
}

flutter {
    source = "../.."
}

tasks.configureEach {
    if (name == "assembleDebug" || name.contains("FlutterApk") || name == "build") {
        doLast {
            val flutterApkDir = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
            flutterApkDir.mkdirs()
            val defaultApk = File(flutterApkDir, "app-debug.apk")
            val targetApk = File(flutterApkDir, "ApnaBatwa.apk")
            if (defaultApk.exists()) {
                defaultApk.copyTo(targetApk, overwrite = true)
                defaultApk.delete()
            }
            val agpApk = layout.buildDirectory.file("outputs/apk/debug/ApnaBatwa.apk").get().asFile
            if (agpApk.exists()) {
                agpApk.copyTo(targetApk, overwrite = true)
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}


