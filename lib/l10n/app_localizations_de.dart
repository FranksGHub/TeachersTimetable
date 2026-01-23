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
  String get menu => 'Menü';

  @override
  String get editTitle => 'Titel bearbeiten';

  @override
  String get editDays => 'Tage bearbeiten';

  @override
  String get editTimes => 'Zeiten bearbeiten';

  @override
  String get printPdf => 'PDF drucken';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get dataImported => 'Daten erfolgreich importiert';

  @override
  String dataExported(Object path) {
    return 'Daten exportiert nach $path';
  }

  @override
  String get time => 'Zeit';

  @override
  String get lessonName => 'Unterrichtsname';

  @override
  String get schoolName => 'Schulname';

  @override
  String get roomNumber => 'Raumnummer';

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
  String get className => 'Klassenname';

  @override
  String get schoolNameLabel => 'Schulname';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get restartToApply =>
      'Starten Sie die App neu, um die Sprachänderung anzuwenden.';
}
