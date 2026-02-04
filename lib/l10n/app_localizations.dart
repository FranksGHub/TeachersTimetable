import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Teachers Timetable'**
  String get appTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Title'**
  String get editTitle;

  /// No description provided for @editDays.
  ///
  /// In en, this message translates to:
  /// **'Edit Days'**
  String get editDays;

  /// No description provided for @editTimes.
  ///
  /// In en, this message translates to:
  /// **'Edit Times'**
  String get editTimes;

  /// No description provided for @printPdf.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @dataImported.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get dataImported;

  /// No description provided for @failedToImportData.
  ///
  /// In en, this message translates to:
  /// **'Data import failed'**
  String get failedToImportData;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported to {path}'**
  String dataExported(Object path);

  /// No description provided for @dataExportedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data to {path}!'**
  String dataExportedError(Object path);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @lessonName.
  ///
  /// In en, this message translates to:
  /// **'Lesson Name'**
  String get lessonName;

  /// No description provided for @schoolName.
  ///
  /// In en, this message translates to:
  /// **'School Name'**
  String get schoolName;

  /// No description provided for @roomNumber.
  ///
  /// In en, this message translates to:
  /// **'Room Number'**
  String get roomNumber;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get times;

  /// No description provided for @editBlock.
  ///
  /// In en, this message translates to:
  /// **'Edit Block'**
  String get editBlock;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color:'**
  String get color;

  /// No description provided for @className.
  ///
  /// In en, this message translates to:
  /// **'Class Name'**
  String get className;

  /// No description provided for @schoolNameLabel.
  ///
  /// In en, this message translates to:
  /// **'School Name'**
  String get schoolNameLabel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'Language English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Language German'**
  String get languageGerman;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @restartToApply.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to apply the language change.'**
  String get restartToApply;

  /// No description provided for @saveTimetableData.
  ///
  /// In en, this message translates to:
  /// **'Save Timetable Data'**
  String get saveTimetableData;

  /// No description provided for @saveTimetableDataSubject.
  ///
  /// In en, this message translates to:
  /// **'Timetable Data Backup'**
  String get saveTimetableDataSubject;

  /// No description provided for @editText.
  ///
  /// In en, this message translates to:
  /// **'Edit Text'**
  String get editText;

  /// No description provided for @addItemLeft.
  ///
  /// In en, this message translates to:
  /// **'+ Task'**
  String get addItemLeft;

  /// No description provided for @addSubitemLeft.
  ///
  /// In en, this message translates to:
  /// **'+ Step'**
  String get addSubitemLeft;

  /// No description provided for @addItemRight.
  ///
  /// In en, this message translates to:
  /// **'+ Task'**
  String get addItemRight;

  /// No description provided for @addSubitemRight.
  ///
  /// In en, this message translates to:
  /// **'+ Step'**
  String get addSubitemRight;

  /// No description provided for @copyItemToLeft.
  ///
  /// In en, this message translates to:
  /// **'<= Task'**
  String get copyItemToLeft;

  /// No description provided for @copySubitemToLeft.
  ///
  /// In en, this message translates to:
  /// **'<= Step'**
  String get copySubitemToLeft;

  /// No description provided for @leftList.
  ///
  /// In en, this message translates to:
  /// **'Current Tasks'**
  String get leftList;

  /// No description provided for @rightList.
  ///
  /// In en, this message translates to:
  /// **'Suggestions from the curriculum'**
  String get rightList;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newItem;

  /// No description provided for @newSubitem.
  ///
  /// In en, this message translates to:
  /// **'- New Step'**
  String get newSubitem;

  /// No description provided for @failedToLoadLeftData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load curent task data'**
  String get failedToLoadLeftData;

  /// No description provided for @failedToLoadRightData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions data'**
  String get failedToLoadRightData;

  /// No description provided for @failedToSaveLeftData.
  ///
  /// In en, this message translates to:
  /// **'Failed to save curent task data'**
  String get failedToSaveLeftData;

  /// No description provided for @failedToSaveRightData.
  ///
  /// In en, this message translates to:
  /// **'Failed to save suggestions data'**
  String get failedToSaveRightData;

  /// No description provided for @failedToCreateZipFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to create zip file'**
  String get failedToCreateZipFile;

  /// No description provided for @timetableBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup all files into a zip file'**
  String get timetableBackup;

  /// No description provided for @timetableBackupImport.
  ///
  /// In en, this message translates to:
  /// **'Import all files from a backup zip file'**
  String get timetableBackupImport;

  /// No description provided for @failedToBackupInZipFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to export files'**
  String get failedToBackupInZipFile;

  /// No description provided for @backupInZipFileOk.
  ///
  /// In en, this message translates to:
  /// **'All files exported as ZIP'**
  String get backupInZipFileOk;

  /// No description provided for @failedToImportZipFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to import files'**
  String get failedToImportZipFile;

  /// No description provided for @importbackupZipFileOk.
  ///
  /// In en, this message translates to:
  /// **'All files imported successfully'**
  String get importbackupZipFileOk;

  /// No description provided for @importAllFilesZip.
  ///
  /// In en, this message translates to:
  /// **'Import all files from a backup'**
  String get importAllFilesZip;

  /// No description provided for @exportAllFilesZip.
  ///
  /// In en, this message translates to:
  /// **'Export all files as a backup (ZIP)'**
  String get exportAllFilesZip;

  /// No description provided for @noFilesToExportYet.
  ///
  /// In en, this message translates to:
  /// **'No files to backup yet'**
  String get noFilesToExportYet;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Source file not found'**
  String get fileNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
