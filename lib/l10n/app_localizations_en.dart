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
  String get menu => 'Menu';

  @override
  String get editTitle => 'Edit Title';

  @override
  String get editDays => 'Edit Days';

  @override
  String get editTimes => 'Edit Times';

  @override
  String get printPdf => 'Print PDF';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get dataImported => 'Data imported successfully';

  @override
  String dataExported(Object path) {
    return 'Data exported to $path';
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
  String get editText => 'Edit Text';

  @override
  String get addItemLeft => 'Add Item Left';

  @override
  String get addSubitemLeft => 'Add Subitem Left';

  @override
  String get addItemRight => 'Add Item Right';

  @override
  String get addSubitemRight => 'Add Subitem Right';

  @override
  String get copyItemToLeft => 'Copy Item to Left';

  @override
  String get copySubitemToLeft => 'Copy Subitem to Left';

  @override
  String get leftList => 'Left List';

  @override
  String get rightList => 'Right List';

  @override
  String get setDataPath => 'Set Data Path';

  @override
  String dataPathSet(Object path) {
    return 'Data path set to $path';
  }
}
