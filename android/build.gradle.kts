allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ensure all Android modules use compileSdk 36 to satisfy AAR metadata checks
plugins.withId("com.android.application") {
    // no-op here; handled per-subproject below
}

subprojects {
    plugins.withId("com.android.library") {
        try {
            val libExt = extensions.findByName("android")
            if (libExt != null) {
                val androidLib = libExt as com.android.build.api.dsl.LibraryExtension
                androidLib.compileSdk = 36
            }
        } catch (e: Exception) {
            // ignore if extension not present
        }
    }
    plugins.withId("com.android.application") {
        try {
            val appExt = extensions.findByName("android")
            if (appExt != null) {
                val androidApp = appExt as com.android.build.api.dsl.ApplicationExtension
                androidApp.compileSdk = 36
            }
        } catch (e: Exception) {
            // ignore if extension not present
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
