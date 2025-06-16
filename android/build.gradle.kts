allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    // Başka plugin'lerin varsa burada dursun ama
    // com.google.gms.google-services plugin'ini BURADAN kaldır!
    // id("com.google.gms.google-services") version "4.4.2" apply false ❌ kaldır
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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

// Bu kısmı da tamamen kaldır:
buildscript {
    dependencies {
        // classpath("com.google.gms:google-services:4.4.2") ❌ kaldır
    }
}
