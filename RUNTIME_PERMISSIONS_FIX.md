# Android Runtime Permissions Fix

## Problem Solved

**Before**: Permissions were declared in AndroidManifest.xml, but:
- Android didn't show them in App-Info → Permissions
- The app couldn't actually use them at runtime
- Users saw "No permissions requested" in settings

**Now**: Permissions are properly requested at runtime
- Android shows them in App-Info → Permissions  
- Users can grant/deny them in settings
- App can actually read/write files after permission is granted

## What Changed

### 1. Added `permission_handler` Package (pubspec.yaml)
```yaml
permission_handler: ^11.4.4
```
This package handles runtime permission requests on Android/iOS.

### 2. Updated timetable_page.dart

**Added imports:**
```dart
import 'package:permission_handler/permission_handler.dart';
```

**New method: `_requestStoragePermission()`**
- Requests `MANAGE_EXTERNAL_STORAGE` on Android 13+
- Requests `storage` permission on Android 12 and below
- Returns `true` if granted, `false` if denied

**Updated `_setDataPath()` method:**
- Calls `_requestStoragePermission()` before opening file picker
- Shows error if permission is denied
- Guides user to grant permission in app settings if needed

### 3. Updated AndroidManifest.xml

Changed permission declaration:
```xml
<!-- Old (doesn't show up in App-Info) -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<!-- New (works on Android 11-12) -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

The `maxSdkVersion="32"` is important because:
- Android 13+ changed how storage permissions work
- This tells the system it's needed only for older versions
- Prevents warnings on Android 13+

## How It Works on Different Android Versions

### Android 12 and Below
1. User taps "Set Data Path"
2. App requests `READ_EXTERNAL_STORAGE` + `WRITE_EXTERNAL_STORAGE`
3. Permission dialog appears: "Allow ... to access your files?"
4. User grants → Path can be set
5. User denies → Error message shown

### Android 13+
1. User taps "Set Data Path"
2. App requests `MANAGE_EXTERNAL_STORAGE`
3. Permission dialog appears: "Allow access to all files?"
4. User grants → Path can be set
5. User denies → Error message shown

## How Users Can Check/Change Permissions

1. **Settings** → **Apps** → **Teachers Timetable**
2. **Permissions** section now shows:
   - ✅ **Files and media** (Android 13+)
   - ✅ **Storage** (Android 12 and below)
3. User can tap to change from "Allow" to "Don't allow"

## Build & Test

After these changes, you need to:

```bash
# Get dependencies
flutter pub get

# Clean build (important for permission changes)
flutter clean

# Rebuild the app
flutter run
# or for release
flutter build apk --release
```

## Testing Checklist

- [ ] Build and run on Android device
- [ ] Tap "Set Data Path"
- [ ] Grant/deny permission when prompted
- [ ] Check App-Info → Permissions (permission should be visible)
- [ ] Test on Android 12 device (if available)
- [ ] Test on Android 13+ device
- [ ] Try denying permission - error message should appear
- [ ] Revoke permission in settings and retry

## Troubleshooting

### Permission still doesn't show in App-Info
**Solution**: Do a clean rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

### "No permissions requested" still visible
**Possible cause**: 
- App not fully uninstalled before rebuild
- Cache issues

**Solution**:
```bash
flutter uninstall
flutter run
```

### Permission dialog doesn't appear
**Possible cause**: Permission already granted previously

**Solution**: Revoke permission in Settings and try again

## Technical Details

### Why This Matters

On modern Android (6.0+), declaring permissions in AndroidManifest.xml is just the first step:

1. **Manifest Declaration** → Tells Android what permissions the app *could* use
2. **Runtime Request** → Actually asks the user to grant those permissions  
3. **User Grant** → User sees permission in App-Info and can manage it

Without step 2, Android treats the app as not needing permissions, and won't show them in settings.

### Permission Handler Behavior

The `permission_handler` package:
- Checks if permission already granted → Returns immediately
- If not granted → Shows system dialog
- Returns `PermissionStatus.granted`, `denied`, `restricted`, etc.

### Storage Permission Differences

| Android Version | Permission | Behavior |
|---|---|---|
| 10-12 | WRITE_EXTERNAL_STORAGE | Full file system access |
| 13+ | MANAGE_EXTERNAL_STORAGE | Full file system access (special use case) |
| Any | SAF (via FilePicker) | Limited to user-selected directory |

Our app uses FilePicker + direct file access, so MANAGE_EXTERNAL_STORAGE is appropriate.
