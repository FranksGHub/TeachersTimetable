# Android File Access Fixes

## Issues Resolved

### Problem 1: Automatic Load/Save Not Working on Android
- **Root Cause**: Missing Android permissions for file system access
- **Symptoms**: Manual export/import worked, but automatic save to user-selected directory failed silently

### Problem 2: No Error Feedback to User
- **Root Cause**: Silent error handling made it impossible to debug what went wrong
- **Symptoms**: Users didn't know why files weren't being saved

### Problem 3: Dialog Not Closing Properly on Web
- **Root Cause**: Missing error handling and proper callback sequencing

## Changes Made

### 1. AndroidManifest.xml
Added the following permissions for file system access:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

These permissions allow the app to:
- Read files from user-selected directories (Documents, etc.)
- Write files to user-selected directories
- Manage external storage on Android 11+ (scoped storage)

### 2. lesson_detail_page.dart
Added comprehensive error handling to all file operations:

#### saveLeftData() & saveRightData()
- ✅ Check if data path is set before attempting save
- ✅ Wrap file operations in try-catch
- ✅ Show user-friendly error messages
- ✅ Prevents app crashes from permission issues

#### loadLeftData() & loadRightData()
- ✅ Silent fail if data path not set (doesn't bother user on initial load)
- ✅ Try-catch blocks for robust error handling
- ✅ Shows errors only when they occur during actual file access

#### New _showError() Method
- ✅ Centralized error notification
- ✅ Red background to indicate failure
- ✅ 4-second display duration for error messages

### 3. timetable_page.dart
Improved _setDataPath() method:
- ✅ Added try-catch for robustness
- ✅ Await the prefs.setString() call (was missing)
- ✅ Use localized success message (dataPathSet)
- ✅ Green background for success feedback
- ✅ Error handling with user notification

## How It Works on Android

1. **User selects data path**: Taps Menu → "Set Data Path"
   - Opens system file picker
   - User navigates to Documents/MyFolder
   - Path is saved to SharedPreferences

2. **Automatic save on edit**: User edits a lesson detail item
   - `saveLeftData()` / `saveRightData()` called
   - Files written to user's selected directory
   - Success/error feedback shown to user

3. **Automatic load on open**: User taps on a lesson block
   - `loadLeftData()` / `loadRightData()` called
   - JSON files loaded from user's directory
   - UI updated with saved data

## Error Messages Users Will See

| Scenario | Message |
|----------|---------|
| Data path not set | "Data path not set. Please set it in the menu." |
| Permission denied | "Failed to save left/right data: PlatformException(...)" |
| Directory deleted | "Failed to load left/right data: FileSystemException(...)" |
| Path set successfully | "Data path set to /storage/emulated/0/Documents/MyFolder" |

## Testing Checklist

- [ ] Test setting data path from Documents folder
- [ ] Edit a lesson item and verify files are saved
- [ ] Reopen the lesson and verify data loads
- [ ] Try on Android 11+ (scoped storage)
- [ ] Try on Android 10 and below
- [ ] Test with invalid/deleted path
- [ ] Test permission denial scenarios
- [ ] Verify export/import still works

## Technical Notes

### Android Permission Levels
- **WRITE_EXTERNAL_STORAGE**: Required for Android 10 and below
- **MANAGE_EXTERNAL_STORAGE**: Required for Android 11+ (special use case)
- **READ_EXTERNAL_STORAGE**: Implicit, but good practice to declare

### Scoped Storage (Android 11+)
- Users select directories via system picker (already handled by FilePicker)
- App gets read/write access to selected directories via Uri
- Direct File() operations work after user selection (Android's SAF handles it)

### Why Export/Import Worked Before
- Share.share() uses system intent (runs in system permission context)
- FilePicker.getDirectoryPath() grants broad access via SAF
- Our file operations now properly use those granted paths
