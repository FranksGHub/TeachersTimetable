// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lehrer Stundenplan';

  @override
  String get workplan => 'Arbeitsplan';

  @override
  String get showTimetable => 'Öffne den Stundenplan';

  @override
  String get showNotes => 'Öffne die Notizen';

  @override
  String get showWorkplan => 'Öffne den Arbeitsplan';

  @override
  String get notesTitle => 'Notizen';

  @override
  String get menu => 'Menü';

  @override
  String get help => 'Hilfe';

  @override
  String get editTitle => 'Titel bearbeiten';

  @override
  String get editDays => 'Tage bearbeiten';

  @override
  String get editTimes => 'Zeiten bearbeiten';

  @override
  String get printPdf => 'Stundenplan Drucken';

  @override
  String get printWorkplan => 'Arbeitsplan drucken';

  @override
  String get printNotes => 'Notizen drucken';

  @override
  String get dataImported => 'Daten erfolgreich importiert';

  @override
  String get failedToImportData => 'Fehler beim Daten Import';

  @override
  String dataExported(Object path) {
    return 'Daten exportiert nach $path';
  }

  @override
  String dataExportedError(Object path) {
    return 'Fehler beim Daten Export nach $path!';
  }

  @override
  String get time => 'Zeit';

  @override
  String get lessonName => 'Unterrichtsname';

  @override
  String get schoolName => 'Schulname';

  @override
  String get className => 'Klassenname';

  @override
  String get editLessonName => 'Unterrichtsname bearbeiten';

  @override
  String get editClassName => 'Klasse bearbeiten';

  @override
  String get editSchoolName => 'Schulname bearbeiten';

  @override
  String get editBlockColor => 'Hintergrund Farbe ändern';

  @override
  String get editWorkplanFilename => 'Arbeitsplan Dateinamen bearbeiten';

  @override
  String get editSuggestionsFilename => 'Vorschlags Dateinamen bearbeiten';

  @override
  String get editNotesFilename => 'Notizen Dateinamen bearbeiten';

  @override
  String get workplanFilename => 'Dateiname des Arbeitsplans';

  @override
  String get suggestionsFilename => 'Dateiname der Vorschläge';

  @override
  String get notesFilename => 'Dateiname der Notizen';

  @override
  String get editFilenames => 'Dateinamen bearbeiten';

  @override
  String get showNotesBeforeWorkplan =>
      'Zeige Notizen immer vor dem Arbeitsplan';

  @override
  String get editShowNotesBeforeWorkplan => 'Notizen oder Arbeitsplan zuerst?';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get title => 'Titel';

  @override
  String get days => 'Tage';

  @override
  String get times => 'Zeiten';

  @override
  String get editBlock => 'Block bearbeiten';

  @override
  String get color => 'Farbe:';

  @override
  String get schoolNameLabel => 'Schulname';

  @override
  String get language => 'Sprache';

  @override
  String get languageEnglish => 'Sprache Englisch';

  @override
  String get languageGerman => 'Sprache Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get restartToApply =>
      'Starten Sie die App neu, um die Sprachänderung anzuwenden.';

  @override
  String get saveTimetableData => 'Speichern der Stundenplan Daten';

  @override
  String get saveTimetableDataSubject => 'Stundenplan Daten Backup';

  @override
  String get editText => 'Text bearbeiten';

  @override
  String get addItemLeft => '+ Aufgabe';

  @override
  String get addSubitemLeft => '+ Arbeitsschritt';

  @override
  String get addItemRight => '+ Aufgabe';

  @override
  String get addSubitemRight => '+ Arbeitsschritt';

  @override
  String get copyItemToLeft => '<= Aufgabe';

  @override
  String get copySubitemToLeft => '<= Schritt';

  @override
  String get leftList => 'Aktuelle Aufgaben';

  @override
  String get rightList => 'Vorschläge aus dem Lehrplan';

  @override
  String get show => 'Zeige';

  @override
  String get hide => 'Verstecke';

  @override
  String get leftListShort => 'linke Liste';

  @override
  String get rightListShort => 'rechte Liste';

  @override
  String get newItem => 'Aufgabe';

  @override
  String get newSubitem => '- Arbeitsschritt';

  @override
  String get failedToLoadNotesData =>
      'Laden der Notiz Daten ist fehlgeschlagen';

  @override
  String get failedToLoadLeftData =>
      'Laden der Aufgaben Daten ist fehlgeschlagen';

  @override
  String get failedToLoadRightData => 'Laden der Vorschläge ist fehlgeschlagen';

  @override
  String get failedToSaveLeftData =>
      'Speichern der aktuellen Aufgaben ist fehlgeschlagen';

  @override
  String get failedToSaveRightData =>
      'Speichern der Vorschläge ist fehlgeschlagen';

  @override
  String get saveNotesButton => 'Speichern';

  @override
  String get savedNotesData => 'Die Notiz Daten wurden gespeichert';

  @override
  String get failedToSaveNotesData =>
      'Speichern der Notiz Daten ist fehlgeschlagen';

  @override
  String get failedToCreateZipFile => 'Fehler beim erzeugen der ZIP-Datei';

  @override
  String get timetableBackup => 'Backup alle Dateien in eine ZIP-Datei';

  @override
  String get timetableBackupImport =>
      'Importiere alle Dateien aus einer Backup ZIP-Datei';

  @override
  String get failedToBackupInZipFile => 'Fehler beim Backup der Dateien';

  @override
  String get backupInZipFileOk => 'Alle Dateien wurden gesichert';

  @override
  String get failedToImportZipFile => 'Fehler beim Import der Dateien';

  @override
  String get importbackupZipFileOk => 'Alle Dateien wurden importiert';

  @override
  String get importAllFilesZip =>
      'Importiere alle Dateien aus einem Backup (ZIP)';

  @override
  String get exportAllFilesZip => 'Exportiere alle Dateien als Backup (ZIP)';

  @override
  String get noFilesToExportYet => 'Keine Dateien zum Backup gefunden';

  @override
  String get fileNotFound => 'Quelldatei existiert nicht';

  @override
  String get appNameWithSpaces => 'Teachers Timetable App';

  @override
  String printingFooter(Object date) {
    return 'Erstellt mit der Teachers Timetable App am $date';
  }

  @override
  String get bothListsHidden =>
      'Bitte eine Liste wieder sichtbar machen (oben rechts)!';

  @override
  String get printingFailed => 'Printing failed';

  @override
  String get printingSuccess => 'Printing started';
}
