# Simple Permission
This plugin provides a cross-platform (iOS, Android) API to request permissions and check their status. You can also open the device's app settings so users can grant a permission.

[comment]: <> ([![pub package]&#40;https://img.shields.io/pub/v/simple_setting.svg&#41;]&#40;https://pub.dev/packages/simple_setting&#41;)

[comment]: <> (A package for internationalizing flutter apps by simple way.)

## Setup

While the permissions are being requested during runtime, you'll still need to tell the OS which permissions your app might potentially use. That requires adding permission configuration to Android- and iOS-specific files.

<details>
<summary>Android</summary>

**Upgrade pre 1.12 Android projects**

Since version 4.4.0 this plugin is implemented using the Flutter 1.12 Android plugin APIs. Unfortunately this means App developers also need to migrate their Apps to support the new Android infrastructure. You can do so by following the [Upgrading pre 1.12 Android projects](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects) migration guide. Failing to do so might result in unexpected behaviour. Most common known error is the permission_handler not returning after calling the `.request()` method on a permission.

**AndroidX**

As of version 3.1.0 the <kbd>permission_handler</kbd> plugin switched to the AndroidX version of the Android Support Libraries. This means you need to make sure your Android project is also upgraded to support AndroidX. Detailed instructions can be found [here](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility).

The TL;DR version is:

1. Add the following to your "gradle.properties" file:

```properties
android.useAndroidX=true
android.enableJetifier=true
```

1. Make sure you set the `compileSdkVersion` in your "android/app/build.gradle" file to 33:

```gradle
android {
  compileSdkVersion 33
  ...
}
```

1. Make sure you replace all the `android.` dependencies to their AndroidX counterparts (a full list can be found [here](https://developer.android.com/jetpack/androidx/migrate)).

Add permissions to your `AndroidManifest.xml` file.
There's a `debug`, `main` and `profile` version which are chosen depending on how you start your app.
In general, it's sufficient to add permission only to the `main` version.
[Here](https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler/example/android/app/src/main/AndroidManifest.xml)'s an example `AndroidManifest.xml` with a complete list of all possible permissions.

</details>

<details>
<summary>iOS</summary>

Add permission to your `Info.plist` file.
[Here](https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler/example/ios/Runner/Info.plist)'s an example `Info.plist` with a complete list of all possible permissions.

> IMPORTANT: ~~You will have to include all permission options when you want to submit your App.~~ This is because the `permission_handler` plugin touches all different SDKs and because the static code analyser (run by Apple upon App submission) detects this and will assert if it cannot find a matching permission option in the `Info.plist`. More information about this can be found [here](https://github.com/Baseflow/flutter-permission-handler/issues/26).

The <kbd>permission_handler</kbd> plugin use [macros](https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler_apple/ios/Classes/PermissionHandlerEnums.h) to control whether a permission is enabled.

You must list permission you want to use in your application :

1. Add the following to your `Podfile` file:

   ```ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       ... # Here are some configurations automatically generated by flutter
  
       # Start of the permission_handler configuration
       target.build_configurations.each do |config|
   
         # You can enable the permissions needed here. For example to enable camera
         # permission, just remove the `#` character in front so it looks like this:
         #
         # ## dart: PermissionGroup.camera
         # 'PERMISSION_CAMERA=1'
         #
         #  Preprocessor definitions can be found in: https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler_apple/ios/Classes/PermissionHandlerEnums.h
         config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
           '$(inherited)',
  
           ## dart: PermissionGroup.calendar
           # 'PERMISSION_EVENTS=1',
  
           ## dart: PermissionGroup.reminders
           # 'PERMISSION_REMINDERS=1',
  
           ## dart: PermissionGroup.contacts
           # 'PERMISSION_CONTACTS=1',
  
           ## dart: PermissionGroup.camera
           # 'PERMISSION_CAMERA=1',
  
           ## dart: PermissionGroup.microphone
           # 'PERMISSION_MICROPHONE=1',
  
           ## dart: PermissionGroup.speech
           # 'PERMISSION_SPEECH_RECOGNIZER=1',
  
           ## dart: PermissionGroup.photos
           # 'PERMISSION_PHOTOS=1',
  
           ## dart: [PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse]
           # 'PERMISSION_LOCATION=1',
          
           ## dart: PermissionGroup.notification
           # 'PERMISSION_NOTIFICATIONS=1',
  
           ## dart: PermissionGroup.mediaLibrary
           # 'PERMISSION_MEDIA_LIBRARY=1',
  
           ## dart: PermissionGroup.sensors
           # 'PERMISSION_SENSORS=1',   
           
           ## dart: PermissionGroup.bluetooth
           # 'PERMISSION_BLUETOOTH=1',
   
           ## dart: PermissionGroup.appTrackingTransparency
           # 'PERMISSION_APP_TRACKING_TRANSPARENCY=1',
   
           ## dart: PermissionGroup.criticalAlerts
           # 'PERMISSION_CRITICAL_ALERTS=1'
         ]
  
       end 
       # End of the permission_handler configuration
     end
   end
   ```

2. Remove the `#` character in front of the permission you do want to use. For example if you need access to the calendar make sure the code looks like this:

   ```ruby
           ## dart: PermissionGroup.calendar
           'PERMISSION_EVENTS=1',
   ```

3. Delete the corresponding permission description in `Info.plist`
   e.g. when you don't need camera permission, just delete 'NSCameraUsageDescription'
   The following lists the relationship between `Permission` and `The key of Info.plist`:

   | Permission                                                                                  | Info.plist                                                                                                    | Macro                                |
      | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
   | PermissionGroup.calendar                                                                    | NSCalendarsUsageDescription                                                                                   | PERMISSION_EVENTS                    |
   | PermissionGroup.reminders                                                                   | NSRemindersUsageDescription                                                                                   | PERMISSION_REMINDERS                 |
   | PermissionGroup.contacts                                                                    | NSContactsUsageDescription                                                                                    | PERMISSION_CONTACTS                  |
   | PermissionGroup.camera                                                                      | NSCameraUsageDescription                                                                                      | PERMISSION_CAMERA                    |
   | PermissionGroup.microphone                                                                  | NSMicrophoneUsageDescription                                                                                  | PERMISSION_MICROPHONE                |
   | PermissionGroup.speech                                                                      | NSSpeechRecognitionUsageDescription                                                                           | PERMISSION_SPEECH_RECOGNIZER         |
   | PermissionGroup.photos                                                                      | NSPhotoLibraryUsageDescription                                                                                | PERMISSION_PHOTOS                    |
   | PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse | NSLocationUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription, NSLocationWhenInUseUsageDescription | PERMISSION_LOCATION                  |
   | PermissionGroup.notification                                                                | PermissionGroupNotification                                                                                   | PERMISSION_NOTIFICATIONS             |
   | PermissionGroup.mediaLibrary                                                                | NSAppleMusicUsageDescription, kTCCServiceMediaLibrary                                                         | PERMISSION_MEDIA_LIBRARY             |
   | PermissionGroup.sensors                                                                     | NSMotionUsageDescription                                                                                      | PERMISSION_SENSORS                   |
   | PermissionGroup.bluetooth                                                                   | NSBluetoothAlwaysUsageDescription, NSBluetoothPeripheralUsageDescription                                      | PERMISSION_BLUETOOTH                 |
   | PermissionGroup.appTrackingTransparency                                                     | NSUserTrackingUsageDescription                                                                                | PERMISSION_APP_TRACKING_TRANSPARENCY |  
   | PermissionGroup.criticalAlerts                                                              | PermissionGroupCriticalAlerts                                                                                 | PERMISSION_CRITICAL_ALERTS           |
4. Clean & Rebuild

</details>

## Usage
To use this plugin, add `simple_permission` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

```yaml
  vnpt_permission:
    git:
      url: https://scm.devops.vnpt.vn/it.si.mobile/base-project-flutter
      ref: vnpt_permission
```
    
### Step 0
Import package
```dart
import 'package:permission_handler/permission_handler.dart';
import 'package:vnpt_permission/vnpt_permission.dart';
```

### Step 1
Define a controller, ex:
```dart
final PermissionController _permissionController = PermissionController();
```

### Step 2
Use `PermissionWidget`
```dart
PermissionWidget(
  grantedWidget: const Container(),
  deniedWidget: ElevatedButton(
    child: const Text("Request permission"),
    onPressed: () {
      _permissionController.request();
    },
  ),
  permission: Permission.camera,
  controller: _permissionController,
  onGranted: (checkTime) {
    debugPrint("onGranted: $checkTime");
  },
  onDenied: (checkTime) {
    debugPrint("onDenied: $checkTime");
  },
  onPermanentlyDenied: (checkTime) {
    debugPrint("onPermanentlyDenied: $checkTime");
    _permissionController.openAppSetting();
  },
)
```

- `grantedWidget`: widget sẽ được hiển thị khi xin quyền thành công
- `deniedWidget`: widget sẽ được hiển thị khi quyền bị từ chối
- `permission`: quyền muốn xin
- `controller`: permisson controller
- `onGranted`: callback khi quyền được chấp nhận
- `onDenied`: callback khi quyền bị từ chối
- `onPermanentlyDenied`: callback khi quyền bị từ chối mãi mãi (bắt buộc phải vào settings của thiết bị để enable)
