plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.food_2_go"
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
        applicationId = "com.example.food_2_go"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "com.captainorder.dev"
            resValue("string", "app_name", "Captain Order Dev")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = "key" // غيّري حسب الـ alias اللي شايفاه
            keyPassword = "123456789" // كلمة المرور بتاعت الـ Key
            storeFile = file("key.jks") // تأكدي إن المسار صحيح من مجلد app
            storePassword = "123456789" // كلمة المرور بتاعت الـ Keystore
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // حذف minifyEnabled وshrinkResources لأنهم مش ضروريين دلوقتي
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-messaging")
}