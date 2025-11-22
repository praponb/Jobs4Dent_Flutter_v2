import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
}

// Load keystore properties from key.properties file if it exists
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "bavonparadon.prapon.jobs4dent"
    compileSdk = flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
        freeCompilerArgs = freeCompilerArgs + listOf(
            "-Xlint:-options",
            "-Xlint:-deprecation",
            "-Xsuppress-version-warnings"
        )
    }

    // Build features configuration
    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "bavonparadon.prapon.jobs4dent"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            val keyAlias = keystoreProperties.getProperty("keyAlias")
            val keyPassword = keystoreProperties.getProperty("keyPassword")
            val storeFile = keystoreProperties.getProperty("storeFile")
            val storePassword = keystoreProperties.getProperty("storePassword")

            if (keyAlias != null && keyPassword != null && storeFile != null && storePassword != null) {
                create("release") {
                    this.keyAlias = keyAlias
                    this.keyPassword = keyPassword
                    this.storeFile = file(storeFile)
                    this.storePassword = storePassword
                }
            }
        }
    }

    buildTypes {
        release {
            if (signingConfigs.findByName("release") != null) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Fallback to debug signing for first upload (Google Play App Signing will handle re-signing)
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

// Add compiler args to suppress warnings for all build types
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.addAll(listOf("-Xlint:none", "-nowarn"))
    options.isDeprecation = false
    options.isWarnings = false
}

// Suppress warnings in Kotlin compilation for all build types
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions.suppressWarnings = true
}

flutter {
    source = "../.."
}
