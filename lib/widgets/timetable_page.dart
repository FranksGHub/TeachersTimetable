import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teachers_timetable/models/print.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../models/lesson_block.dart';
import '../models/export_import_files.dart';
import 'edit_title_dialog.dart';
import 'edit_days_dialog.dart';
import 'edit_times_dialog.dart';
import 'lesson_detail_page.dart';
import 'version_menu.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key, this.onLocaleChange, this.currentLocale});

  final Function(Locale)? onLocaleChange;
  final Locale? currentLocale;

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  List<List<LessonBlock>> timetable = List.generate(6, (_) => List.generate(5, (_) => LessonBlock()));
  List<String> days = ['Mo', 'Di', 'Mi', 'Do', 'Fr'];
  List<String> times = ['   1', '   2', '   3', '   4', '   5', '   6'];
  String title = 'Lehrer Stundenplan';
  late SharedPreferences prefs;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    loadData();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    prefs = await SharedPreferences.getInstance();
    String? titleJson = prefs.getString('title');
    if (titleJson != null) {
      setState(() {
        title = titleJson;
      });
    }
    days[0] = prefs.getString('mon') != null ? prefs.getString('mon')! : 'Mo';
    days[1] = prefs.getString('tue') != null ? prefs.getString('tue')! : 'Di';
    days[2] = prefs.getString('wed') != null ? prefs.getString('wed')! : 'Mi';
    days[3] = prefs.getString('thu') != null ? prefs.getString('thu')! : 'Do';
    days[4] = prefs.getString('fri') != null ? prefs.getString('fri')! : 'Fr';
    setState(() {
      days = days;
    });

    times[0] = prefs.getString('time1') != null ? prefs.getString('time1')! : '   1';
    times[1] = prefs.getString('time2') != null ? prefs.getString('time2')! : '   2';
    times[2] = prefs.getString('time3') != null ? prefs.getString('time3')! : '   3';
    times[3] = prefs.getString('time4') != null ? prefs.getString('time4')! : '   4';
    times[4] = prefs.getString('time5') != null ? prefs.getString('time5')! : '   5';
    times[5] = prefs.getString('time6') != null ? prefs.getString('time6')! : '   6';
    setState(() {
      times = times;
    });

    String? timetableJson = prefs.getString('timetable');
    if (timetableJson != null) {
      List<dynamic> timetableData = jsonDecode(timetableJson);
      setState(() {
        timetable = timetableData.map((row) => (row as List).map((block) => LessonBlock(
          color: Color((block as Map)['color']),
          lessonName: block['lessonName'],
          schoolName: block['roomNumber'],
          className: block['schoolName'],
        )).toList()).toList();
      });
    }
  }

  void saveData() {
    prefs.setString('title', title);
    prefs.setString('mon', days[0]);  prefs.setString('tue', days[1]);  prefs.setString('wed', days[2]);  
    prefs.setString('thu', days[3]);  prefs.setString('fri', days[4]);
    prefs.setString('time1', times[0]);  prefs.setString('time2', times[1]);  prefs.setString('time3', times[2]);
    prefs.setString('time4', times[3]);  prefs.setString('time5', times[4]);  prefs.setString('time6', times[5]);
    prefs.setString('timetable', jsonEncode(timetable.map((row) => row.map((block) => {
      'color': block.color.toARGB32(),
      'lessonName': block.lessonName,
      'schoolName': block.className,
      'roomNumber': block.schoolName,
    }).toList()).toList()));

    // save into file as well
    ExportImportFiles().SavePrefsData(context, prefs, true);
  }

  bool isDark(Color color) {
    double luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    return luminance < 0.5;
  }

  void _editBlock(int row, int col) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailPage(
          block: timetable[row][col],
          row: row,
          col: col,
          onSave: (updatedBlock) {
            setState(() {
              timetable[row][col] = updatedBlock;
            });
            saveData();
          },
        ),
      ),
    );
  }

  void _editTitle() {
    showDialog(
      context: context,
      builder: (context) => EditTitleDialog(
        currentTitle: title,
        onSave: (newTitle) {
          setState(() {
            title = newTitle;
          });
          saveData();
        },
      ),
    );
  }

  void _editDays() {
    showDialog(
      context: context,
      builder: (context) => EditDaysDialog(
        days: days,
        onSave: (newDays) {
          setState(() {
            days = newDays;
          });
          saveData();
        },
      ),
    );
  }

  void _editTimes() {
    showDialog(
      context: context,
      builder: (context) => EditTimesDialog(
        times: times,
        onSave: (newTimes) {
          setState(() {
            times = newTimes;
          });
          saveData();
        },
      ),
    );
  }

  void _showLanguage(String langCode) {
    Locale newLocale = langCode == 'en' ? const Locale('en') : const Locale('de');
    if(widget.currentLocale == newLocale){
      return; // No change needed
    }
    if (widget.onLocaleChange != null) {
      widget.onLocaleChange!(newLocale);
      //Navigator.pop(context);
    }
  }

  Future<void> _importData() async {
    if(await ExportImportFiles().ImportAllFilesFromZip(context)) {
      if( await ExportImportFiles().ImportPrefsData(context, prefs)) {
        await loadData(); // Reload data
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.importbackupZipFileOk), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToImportData), backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToImportZipFile), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) {
        // Consume the event to prevent duplicate key press errors
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('      ' + title),
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 80, // Reduced height to 50% of typical DrawerHeader height
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.menu,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              VersionMenu(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.editTitle),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _editTitle();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.editDays),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _editDays();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.editTimes),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _editTimes();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.print),
                title: Text(AppLocalizations.of(context)!.printPdf),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  PrintPdf().PrintTimetable(context, title, days, times, timetable);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: Text(AppLocalizations.of(context)!.exportAllFilesZip),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  ExportImportFiles().ExportAllFilesAsZip(context, prefs);
                },
              ),
              ListTile(
                leading: const Icon(Icons.unarchive),
                title: Text(AppLocalizations.of(context)!.importAllFilesZip),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _importData();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.languageGerman),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _showLanguage('de');
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.languageEnglish),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _showLanguage('en');
                },
              ),
            ],
          ),
        ),
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 50, child: Text(' ')),
              ...days.map((day) => Expanded(child: Text(day, textAlign: TextAlign.center))),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, row) {
                return Row(
                  children: [
                    SizedBox(width: 50, child: Text(times[row])),
                    ...List.generate(5, (col) {
                      final block = timetable[row][col];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _editBlock(row, col),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            height: 80,
                            decoration: BoxDecoration(
                              color: block.color,
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(block.lessonName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text(block.className, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(block.schoolName, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

}