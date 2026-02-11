import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/src/shared_preferences_legacy.dart';
import '../l10n/app_localizations.dart';

class ExportImportFiles {
  static String _prefsSettingsFilename = 'timetable_settings.json';
  static String _prefsSettingsBackupFilename = 'timetable_settings.json.bak';

  static String DatedFileName(String originalPath) { 
    final base = p.basenameWithoutExtension(originalPath); 
    final ext = p.extension(originalPath); 
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now()); 
    return '$base\_$stamp$ext'; 
  }

  static String GetSaveFilename(String originalFilename) { 
    return originalFilename.replaceAll(RegExp(r'[\\/:*?" <>|]'), '_');
  }

  static Future<String> GetPrivateDirectoryPath() async {
    // Get applications private data directory
    final directory = await getApplicationDocumentsDirectory();
    final timetablePath = p.join(directory.path, 'Timetable');
    final timetableDir = Directory(timetablePath);
    if (!await timetableDir.exists()) await timetableDir.create(recursive: true);
    return timetablePath;
  }

  Future<bool> CopyFile(BuildContext context, String sourcePathFilename, String destPathFilename) async { 
    final source = File(sourcePathFilename); 
    if (!await source.exists()) throw Exception(AppLocalizations.of(context)!.fileNotFound); 
    // Zielverzeichnis sicherstellen 
    // final destDir = p.dirname(destPathFilename);
    // final dir = Directory(destDir); 
    // if (!await dir.exists()) await dir.create(recursive: true); 
    
    // Dateiname aus dem Quellpfad übernehmen 
    // final fileName = p.basename(sourcePathFilename); 
    // final destPath = p.join(destDir, fileName); 
    try { 
      final copied = await source.copy(destPathFilename); 
      return copied.exists();
    } catch (e) { 
      // Fehlerbehandlung (z. B. Berechtigungen, Datei in Benutzung) 
      return false;
    }
  }

  Future<bool> SaveOrShareFile(BuildContext context, String filename) async {
    if (Platform.isAndroid) {
      // Share on Android
      await SharePlus.instance.share(ShareParams(files: [XFile(filename)], subject: AppLocalizations.of(context)!.saveTimetableDataSubject, title: AppLocalizations.of(context)!.saveTimetableData));
      return true;
    }

    // Save to file on Windows/Web
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: AppLocalizations.of(context)!.saveTimetableData,
      fileName: p.basename(filename),
      type: FileType.custom,
      allowedExtensions: [p.extension(filename)],
    );

    if (outputFile != null && await CopyFile(context, filename, outputFile)) {
      return true;
    }
    return false;
  }


  Future<void> SavePrefsData(BuildContext context, SharedPreferences prefs, bool silent) async {
    // get the prefs data as strings
    Map<String, dynamic> data = {};
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      data[key] = prefs.get(key);
    }
    // make it a json string
    String jsonData = jsonEncode(data);

    // Save the data into the private data path
    // Get or create target directory
    final timetablePath = await GetPrivateDirectoryPath();
    final targetFilePathName = p.join(timetablePath, _prefsSettingsFilename);
    final targetFile = File(targetFilePathName); 
    final backupFilePathName = p.join(timetablePath, _prefsSettingsBackupFilename);
    final backupFile = File(backupFilePathName);
    try { 
      // if target is existing prepare a backup, overwrite existing backup file
      if (await targetFile.exists()) { 
        if (await backupFile.exists()) { await backupFile.delete(); }
        await targetFile.copy(backupFilePathName); 
        await targetFile.delete(); 
      } 
      // copy the new data file
      await targetFile.writeAsString(jsonData); 
    } 
    catch (e) { 
      // Optional: if errors, restore the Backup???
      // rethrow; 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.dataExportedError(targetFilePathName)), backgroundColor: Colors.red));
      return;
    }
    
    if(!silent) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.dataExported(targetFilePathName)), backgroundColor: Colors.green));
  }

  Future<bool> ImportPrefsData(BuildContext context, SharedPreferences prefs) async {
    try {
      // Get or create target directory
      final timetablePath = await GetPrivateDirectoryPath();
      final sourceFilePathName = p.join(timetablePath, _prefsSettingsFilename);
      final sourceFile = File(sourceFilePathName); 
      String jsonData = await sourceFile.readAsString();
      Map<String, dynamic> data = jsonDecode(jsonData);
      for (String key in data.keys) {
        var value = data[key];
        if (value is String) {
          prefs.setString(key, value);
        } else if (value is int) {
          prefs.setInt(key, value);
        } else if (value is double) {
          prefs.setDouble(key, value);
        } else if (value is bool) {
          prefs.setBool(key, value);
        } else if (value is List) {
          prefs.setStringList(key, value.cast<String>());
        }
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<void> ExportAllFilesAsZip(BuildContext context, SharedPreferences prefs) async {
    try {
      // Get or create target directory
      final timetablePath = await GetPrivateDirectoryPath();
      final timetableDir = Directory(timetablePath);

      await SavePrefsData(context, prefs, false);

      // Get all files in the Timetable directory
      final files = timetableDir.listSync();
      if (files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noFilesToExportYet), backgroundColor: Colors.orange));
        return;
      }

      // Create archive
      final archive = Archive();
      for (var file in files) {
        if (file is File) {
          final bytes = await file.readAsBytes();
          final fileNameParts = file.path.split( file.path.contains(Platform.pathSeparator) ? Platform.pathSeparator : '/');
          final fileName = fileNameParts.last;
          archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
        }
      }

      // Encode the archive as zip
      final zipData = ZipEncoder().encode(archive);

      // Save zip file in temporary directory with date/time stamp
      final tempDir = Directory.systemTemp;
      final datedZipFilePathName = p.join(tempDir.path, DatedFileName('teachers_timetable_backup.zip'));
      final zipFile = File(datedZipFilePathName);
      await zipFile.writeAsBytes(zipData);

      // Share the zip file if running on android, or copy it at a user defined location on other platforms
      await SaveOrShareFile(context, zipFile.path);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.backupInZipFileOk), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToBackupInZipFile + ': $e'), backgroundColor: Colors.red) );
    }
  }

  Future<bool> ImportAllFilesFromZip(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);

      if (result == null) return false; // User canceled the picker

      final zipFilePath = result.files.single.path!;
      final zipFile = File(zipFilePath);
      final zipBytes = await zipFile.readAsBytes();

      // Decode the archive
      final archive = ZipDecoder().decodeBytes(zipBytes);

      // Get or create target directory
      final timetablePath = await GetPrivateDirectoryPath();
      final timetableDir = Directory(timetablePath);

      // Extract all files
      for (final file in archive) {
        if (!file.isFile) continue;

        final outputFilePathName = p.join(timetableDir.path, file.name);
        final outputFile = File(outputFilePathName);

        // Create parent directory if needed
        await outputFile.parent.create(recursive: true);

        // Write the file
        await outputFile.writeAsBytes(file.content as List<int>);
      }

    } catch (e) {
      return false;
    }
    return true;
  }
}