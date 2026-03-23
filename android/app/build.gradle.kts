plugins {
    id("com.android.application")
    id("kotlin-android")
    // يجب تطبيق محرك فلاتر بعد إضافات أندرويد وكوتلن
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.task_manager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // تفعيل دعم المكتبات الحديثة للأجهزة القديمة
        isCoreLibraryDesugaringEnabled = true

        // يفضل استخدام 1_8 لضمان التوافق التام مع مكتبة التنبيهات
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.task_manager"
        //SdkVersion يتم جلبها تلقائياً من إعدادات فلاتر
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // المكتبة المسؤولة عن تحويل كود Java الحديث ليعمل على الأنظمة القديمة
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}