plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.redecom.redecom_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

  defaultConfig {
    applicationId = "com.redecom.redecom_app"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName

    // Lee la clave desde gradle.properties o variable de entorno
    val mapsApiKey: String = (providers.gradleProperty("MAPS_API_KEY").orNull)
        ?: System.getenv("MAPS_API_KEY")
        ?: ""

    if (mapsApiKey.isBlank()) {
        logger.warn("⚠️ MAPS_API_KEY está vacío. Define MAPS_API_KEY en gradle.properties o como variable de entorno.")
    }

    // Kotlin DSL: usa paréntesis y strings
    resValue("string", "google_maps_api_key", mapsApiKey)
}


    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
