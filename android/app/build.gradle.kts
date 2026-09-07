import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val quranSigningFile = rootProject.file("key.properties")
val quranSigning = Properties()
if (quranSigningFile.exists()) {
    quranSigningFile.inputStream().use { quranSigning.load(it) }
    check(listOf("storeFile", "storePassword", "keyAlias", "keyPassword").all {
        !quranSigning.getProperty(it).isNullOrBlank()
    }) { "Quran Haven: key.properties must contain all four signing fields." }
}
// Test signing is an explicit per-build choice, never the production fallback.
val quranTestSigning = providers.environmentVariable("QURAN_HAVEN_TEST_SIGNING").orNull == "true"
val quranAppProject = project
gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any {
        it.project == quranAppProject && it.name.contains("Release")
    }
    check(!buildsRelease || quranSigningFile.exists() || quranTestSigning) {
        "Quran Haven: configure private android/key.properties for a store release. " +
        "For a local TEST APK only, set QURAN_HAVEN_TEST_SIGNING=true."
    }
}

android {
    namespace = "org.quranflutter.quran_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Preserve the installed app's identity and its existing local data.
        applicationId = "org.quranflutter.quran_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (quranSigningFile.exists()) {
            create("quranRelease") {
                storeFile = rootProject.file(quranSigning.getProperty("storeFile"))
                storePassword = quranSigning.getProperty("storePassword")
                keyAlias = quranSigning.getProperty("keyAlias")
                keyPassword = quranSigning.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                quranSigningFile.exists() -> signingConfigs.getByName("quranRelease")
                quranTestSigning -> signingConfigs.getByName("debug")
                else -> null
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
