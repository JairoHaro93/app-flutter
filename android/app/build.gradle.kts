// android/app/build.gradle.kts

import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe ir después de los de Android y Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

// Cargar propiedades locales (no versionadas) como MAPS_API_KEY
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

// Prioridad: local.properties > gradle.properties > variable de entorno
val mapsApiKey: String = localProps.getProperty("MAPS_API_KEY")
    ?: providers.gradleProperty("MAPS_API_KEY").orNull
    ?: System.getenv("MAPS_API_KEY")
    ?: ""

if (mapsApiKey.isBlank()) {
    logger.warn("⚠️ MAPS_API_KEY está vacío. Define MAPS_API_KEY en local.properties, gradle.properties o como variable de entorno.")
}

android {
    namespace = "com.redecom.redecom_app"

    // Usa los valores que expone el plugin de Flutter
    compileSdk = flutter.compileSdkVersion
    // Mantén esta línea si tu entorno requiere ndk específico (opcional)
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
        multiDexEnabled = true

        // Exporta la API key como recurso string consumido por el AndroidManifest
        // <meta-data android:name="com.google.android.geo.API_KEY" android:value="@string/google_maps_api_key"/>
        resValue("string", "google_maps_api_key", mapsApiKey)
    }

    buildTypes {
        getByName("release") {
            // Firma con debug para poder instalar `flutter run --release` (cámbialo por tu signingConfig real en producción)
            signingConfig = signingConfigs.getByName("debug")
            // isMinifyEnabled = false // habilítalo y configura proguard si lo necesitas
        }
        // getByName("debug") { ... } // si necesitas ajustes de debug
    }

    // (Opcional) Si alguna vez tienes conflictos de recursos, puedes añadir packagingOptions:
    // packagingOptions {
    //     resources.excludes.add("META-INF/*")
    // }
}

// Ruta del código Flutter
flutter {
    source = "../.."
}

// Dependencias adicionales si las necesitas (normalmente Flutter las gestiona)
// dependencies {
//     implementation("org.jetbrains.kotlin:kot
