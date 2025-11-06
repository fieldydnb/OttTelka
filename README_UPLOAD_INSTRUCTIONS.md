OttTelka - flattened upload package
----------------------------------
This archive contains the source files flattened into the root so you can upload them
one-by-one from a mobile browser (GitHub web) using Create new file and paths shown below.

Recommended GitHub workflow on mobile:
1) In your repo, click 'Add file' -> 'Create new file'.
2) In the filename field type the full path (e.g. `lib/main.dart`) and paste the file content from the corresponding flattened file below.
3) Commit changes. Repeat for all files.

File mapping (filename in this zip -> GitHub path to create):
- main.dart  -> lib/main.dart
- pubspec.yaml -> pubspec.yaml
- android_manifest.xml -> android/app/src/main/AndroidManifest.xml
- android_build_gradle.txt -> android/build.gradle
- android_app_build_gradle.txt -> android/app/build.gradle
- android_settings_gradle.txt -> android/settings.gradle
- android_gradle_properties.txt -> android/gradle.properties
- README_PROJECT.md -> README.md

After you create these files in the repo, Codemagic should detect the Flutter project.
If Codemagic asks for project path, set it to `.` (root).
