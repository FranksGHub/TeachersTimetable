// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Teachers Timetable';

  @override
  String get workplan => 'Work plan';

  @override
  String get showTimetable => 'Open the timetable';

  @override
  String get showNotes => 'Open the notes';

  @override
  String get showWorkplan => 'Open the work plan';

  @override
  String get menu => 'Menu';

  @override
  String get help => 'Help';

  @override
  String get editTitle => 'Edit Title';

  @override
  String get editDays => 'Edit Days';

  @override
  String get editTimes => 'Edit Times';

  @override
  String get printPdf => 'Print timetable';

  @override
  String get printWorkplan => 'Print work plan';

  @override
  String get dataImported => 'Data imported successfully';

  @override
  String get failedToImportData => 'Data import failed';

  @override
  String dataExported(Object path) {
    return 'Data exported to $path';
  }

  @override
  String dataExportedError(Object path) {
    return 'Failed to export data to $path!';
  }

  @override
  String get time => 'Time';

  @override
  String get lessonName => 'Lesson Name';

  @override
  String get schoolName => 'School Name';

  @override
  String get roomNumber => 'Room Number';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get title => 'Title';

  @override
  String get days => 'Days';

  @override
  String get times => 'Times';

  @override
  String get editBlock => 'Edit Block';

  @override
  String get editFilenames => 'Edit filenames';

  @override
  String get workplanFilename => 'Work plan filename only';

  @override
  String get suggestionsFilename => 'Suggestions filename only';

  @override
  String get notesFilename => 'Notes filename only';

  @override
  String get showNotesBeforeWorkplan => 'Always show notes before work plan';

  @override
  String get color => 'Color:';

  @override
  String get className => 'Class Name';

  @override
  String get schoolNameLabel => 'School Name';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'Language English';

  @override
  String get languageGerman => 'Language German';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get restartToApply => 'Restart the app to apply the language change.';

  @override
  String get saveTimetableData => 'Save Timetable Data';

  @override
  String get saveTimetableDataSubject => 'Timetable Data Backup';

  @override
  String get editText => 'Edit Text';

  @override
  String get addItemLeft => '+ Task';

  @override
  String get addSubitemLeft => '+ Step';

  @override
  String get addItemRight => '+ Task';

  @override
  String get addSubitemRight => '+ Step';

  @override
  String get copyItemToLeft => '<= Task';

  @override
  String get copySubitemToLeft => '<= Step';

  @override
  String get leftList => 'Current Tasks';

  @override
  String get rightList => 'Suggestions from the curriculum';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get leftListShort => 'left list';

  @override
  String get rightListShort => 'right list';

  @override
  String get newItem => 'New Task';

  @override
  String get newSubitem => '- New Step';

  @override
  String get failedToLoadNotesData => 'Failed to load notes data';

  @override
  String get failedToLoadLeftData => 'Failed to load curent task data';

  @override
  String get failedToLoadRightData => 'Failed to load suggestions data';

  @override
  String get failedToSaveLeftData => 'Failed to save curent task data';

  @override
  String get failedToSaveRightData => 'Failed to save suggestions data';

  @override
  String get failedToCreateZipFile => 'Failed to create zip file';

  @override
  String get timetableBackup => 'Backup all files into a zip file';

  @override
  String get timetableBackupImport => 'Import all files from a backup zip file';

  @override
  String get failedToBackupInZipFile => 'Failed to export files';

  @override
  String get backupInZipFileOk => 'All files exported as ZIP';

  @override
  String get failedToImportZipFile => 'Failed to import files';

  @override
  String get importbackupZipFileOk => 'All files imported successfully';

  @override
  String get importAllFilesZip => 'Import all files from a backup (ZIP)';

  @override
  String get exportAllFilesZip => 'Export all files as a backup (ZIP)';

  @override
  String get noFilesToExportYet => 'No files to backup yet';

  @override
  String get fileNotFound => 'Source file not found';

  @override
  String get appNameWithSpaces => 'Teachers Timetable App';

  @override
  String printingFooter(Object date) {
    return 'Created with the Teachers Timetable app at $date';
  }

  @override
  String get bothListsHidden =>
      'Please make one list visible again (top right)!';
}
