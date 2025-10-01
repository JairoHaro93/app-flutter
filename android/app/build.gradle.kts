// android/app/build.gradle.kts

import java.util.Properties
import java.io.FileInputStream

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

// ---------- Firma (release) desde android/key.properties ----------
val keystoreProps = Properties()
val keystorePropsFile = rootProject.file("key.properties")
val hasReleaseSigning = if (keystorePropsFile.exists()) {
    FileInputStream(keystorePropsFile).use { keystoreProps.load(it) }
    true
} else {
    logger.warn("⚠️ No se encontró android/key.properties. Se usará firma debug para 'release'.")
    false
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

        // Exporta la API key como recurso string consumido por el AndroidManifest:
        // <meta-data android:name="com.google.android.geo.API_KEY" android:value="@string/google_maps_api_key"/>
        resValue("string", "google_maps_api_key", mapsApiKey)
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProps["storeFile"] as String)
                storePassword = keystoreProps["storePassword"] as String
                keyAlias = keystoreProps["keyAlias"] as String
                keyPassword = keystoreProps["keyPassword"] as String
            }
        }
        // 'debug' lo provee el plugin de Android/Flutter
    }

    buildTypes {
        getByName("release") {
            // Usa release si hay keystore, si no, cae a debug (permite `flutter run --release`)
            signingConfig = if (hasReleaseSigning)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")

            // Activa shrink si quieres reducir tamaño (requiere reglas si usas libs nativas)
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        // getByName("debug") { ... } // si necesitas ajustes específicos de debug
    }

    // (Opcional) Si alguna vez tienes conflictos de recursos, puedes añadir:
    // packagingOptions {
    //     resources.excludes.add("META-INF/*")
    // }
}

// Ruta del código Flutter
flutter {
    source = "../.."
}

// Dependencias adicionales si las necesitas
dependencies {
    // Si multiDexEnabled=true y minSdk <= 20, añade multidex:
    // implementation("androidx.multidex:multidex:2.0.1")
}
