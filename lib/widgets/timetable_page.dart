import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teachers_timetable/models/print.dart';
import 'package:teachers_timetable/widgets/edit_combo_dialog.dart';
import 'package:teachers_timetable/widgets/edit_settings_dialog.dart';
import 'package:teachers_timetable/widgets/edit_text_dialog.dart';
import 'package:teachers_timetable/widgets/help_page.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../models/lesson_block.dart';
import '../models/export_import_files.dart';
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
  List<List<LessonBlock>> timetable = List.generate(9, (_) => List.generate(5, (_) => LessonBlock()));
  List<String> days = ['Mo', 'Di', 'Mi', 'Do', 'Fr'];
  List<String> times = ['   1', '   2', '   3', '   4', '   5', '   6', '   7', '   8', '   9'];
  String title = 'Lehrer Stundenplan';
  int countOfBlocksPerDay = 6;  // 1..9 lesson blocks each day in vertical direction
  late SharedPreferences prefs;
  late FocusNode _focusNode;
  LessonBlock? clipboardLessonBlock = null;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadData();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    prefs = await SharedPreferences.getInstance();
    String? titleJson = prefs.getString('title');
    if (titleJson != null) {
      setState(() {
        title = titleJson;
      });
    }

    int? count = prefs.getInt('countOfBlocksPerDay');
    if (count != null && count != countOfBlocksPerDay && count > 0 && count < 10) {
      setState(() {
        countOfBlocksPerDay = count;
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
    times[6] = prefs.getString('time7') != null ? prefs.getString('time7')! : '   7';
    times[7] = prefs.getString('time8') != null ? prefs.getString('time8')! : '   8';
    times[8] = prefs.getString('time9') != null ? prefs.getString('time9')! : '   9';
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
          hideLeftList: block['hideLeftList'] ?? false,
          hideRightList: block['hideRightList'] ?? false,
          showNotesBeforeWorkplan: block['showNotesBeforeWorkplan'] ?? false,
          workplanFilename: block['workplanFilename'] ?? '',
          suggestionsFilename: block['suggestionsFilename'] ?? '',
          notesFilename: block['notesFilename'] ?? '',
        )).toList()).toList();

        while(timetable.length < 9) {
          timetable.add(List.generate(5, (_) => LessonBlock()));
        }
      });
    }
  }

  void _saveData() {
    prefs.setString('title', title);
    prefs.setInt('countOfBlocksPerDay', countOfBlocksPerDay);
    prefs.setString('mon', days[0]);  prefs.setString('tue', days[1]);  prefs.setString('wed', days[2]);  
    prefs.setString('thu', days[3]);  prefs.setString('fri', days[4]);
    prefs.setString('time1', times[0]);  prefs.setString('time2', times[1]);  prefs.setString('time3', times[2]);
    prefs.setString('time4', times[3]);  prefs.setString('time5', times[4]);  prefs.setString('time6', times[5]);
    prefs.setString('time7', times[6]);  prefs.setString('time8', times[7]);  prefs.setString('time9', times[8]);
    prefs.setString('timetable', jsonEncode(timetable.map((row) => row.map((block) => {
      'color': block.color.toARGB32(),
      'lessonName': block.lessonName,
      'schoolName': block.className,
      'roomNumber': block.schoolName,
      'hideLeftList': block.hideLeftList,
      'hideRightList': block.hideRightList,
      'showNotesBeforeWorkplan': block.showNotesBeforeWorkplan,
      'workplanFilename': block.workplanFilename,
      'suggestionsFilename': block.suggestionsFilename,
      'notesFilename': block.notesFilename,
    }).toList()).toList()));

    // save into file as well
    ExportImportFiles().savePrefsData(context, prefs, true);
  }

  bool isDark(Color color) {
    double luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    return luminance < 0.5;
  }

  void _showBlockDetails(int row, int col) {
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
            _saveData();
          },
        ),
      ),
    );
  }

  void _showBlockSettings(int row, int col) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSettingsDialog(
          block: timetable[row][col],
          col: col,
          onSave: (updatedBlock) {
            setState(() {
              timetable[row][col] = updatedBlock;
            });
            _saveData();
          },
        ),
      ),
    );
  }

  void _editTitle() {
    showDialog(
      context: context,
      builder: (context) => EditTextDialog(
        currentTextValue: title,
        dialogTitle: AppLocalizations.of(context)!.editTitle,
        dialogText: '',
        onSave: (newTitle) {
          setState(() {
            title = newTitle;
          });
          _saveData();
        },
      ),
    );
  }

  void _editDays() {
    showDialog(
      context: context,
      builder: (context) => EditTextDialog(
        currentTextValue: days.join(', '),
        dialogTitle: AppLocalizations.of(context)!.editDays,
        dialogText: '',
        onSave: (newDays) {
          setState(() {
            days = newDays.split(', ');
          });
          _saveData();
        },
      ),
    );
  }

  void _editTimes() {
    showDialog(
      context: context,
      builder: (context) => EditTextDialog(
        currentTextValue: times.join(', '),
        dialogTitle: AppLocalizations.of(context)!.editTimes,
        dialogText: '',
        onSave: (newTimes) {
          setState(() {
            times = newTimes.split(', ');
          });
          _saveData();
        },
      ),
    );
  }

  void _editBlocksPerDay() {
    showDialog(
      context: context,
      builder: (context) => EditComboDialog(
        currentValue: countOfBlocksPerDay,
        dialogTitle: AppLocalizations.of(context)!.editBlocksPerDay,
        dialogText: AppLocalizations.of(context)!.editBlocksPerDayText,
        onSave: (newCount) {
          setState(() {
            countOfBlocksPerDay = newCount;
          });
          _saveData();
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
    ReturnValue ret = await ExportImportFiles().importAllFilesFromZip(context);
    if( ret == ReturnValue.Ok) {
      if( await ExportImportFiles().importPrefsData(context, prefs)) {
        await _loadData(); // Reload data
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.importbackupZipFileOk), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToImportData), backgroundColor: Colors.red));
      }
    } else if (ret == ReturnValue.Errors) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToImportZipFile), backgroundColor: Colors.red));
    }
  }

  void _showInfo(String message) {
    if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 2)));}
  }

  // Zentrale Funktion zum Anzeigen des Menüs
  void _showContextMenu(BuildContext context, Offset offset, int row, int col) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final String? selectedAction = await showMenu<String>(
      context: context,
      // Positioniert das Menü genau dort, wo geklickt/gedrückt wurde
      position: RelativeRect.fromRect( Rect.fromLTWH(offset.dx, offset.dy, 0, 0), Offset.zero & overlay.size, ),
      items: [
        PopupMenuItem( value: 'settings', child: ListTile( leading: Icon(Icons.settings, size: 20), title: Text(AppLocalizations.of(context)!.editBlock),),),
        PopupMenuItem( value: 'copy', child: ListTile( leading: Icon(Icons.copy, size: 20), title: Text(AppLocalizations.of(context)!.copy),),),
        if(clipboardLessonBlock != null) PopupMenuItem( value: 'paste', child: ListTile( leading: Icon(Icons.paste, size: 20), title: Text(AppLocalizations.of(context)!.paste),),),
        PopupMenuItem( value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red, size: 20), title: Text(AppLocalizations.of(context)!.reset, style: TextStyle(color: Colors.red)),),),
      ],
    );

    // Logik für die gewählte Aktion
    if (selectedAction == 'copy') {
      clipboardLessonBlock = timetable[row][col];
      _showInfo('Einstellungen wurden kopiert');
    }
    else if (selectedAction == 'paste' && clipboardLessonBlock != null) {
      setState(() {
        timetable[row][col].copy(clipboardLessonBlock as LessonBlock);
      });
      _saveData();
      _showInfo('Einstellungen wurden eingefügt');
    }
    else if (selectedAction == 'delete') {
      setState(() {
        timetable[row][col] = new LessonBlock();
      });
      _saveData();
      _showInfo('Einstellungen wurden zurückgesetzt');
    }
    else if (selectedAction == 'settings') {
      _showBlockSettings(row, col);
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
                leading: const Icon(Icons.help),
                title: Text(AppLocalizations.of(context)!.help),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpPage()),
                  );
                },
              ),
              
              const Divider(),
              
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
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.editBlocksPerDay),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _editBlocksPerDay();
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.print),
                title: Text(AppLocalizations.of(context)!.printPdf),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  PrintPdf().printTimetable(context, title, days, times, countOfBlocksPerDay, timetable);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: Text(AppLocalizations.of(context)!.exportAllFilesZip),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  ExportImportFiles().exportAllFilesAsZip(context, prefs);
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

              SizedBox(height: 80,) // on some devices the last menu line is otherwise not touchable
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
              itemCount: countOfBlocksPerDay,
              itemBuilder: (context, row) {
                return Row(
                  children: [
                    SizedBox(width: 50, child: Text(times[row])),
                    ...List.generate(5, (col) {
                      final block = timetable[row][col];
                      return Expanded(
                        child: GestureDetector(
                          // for Android and Windows Touch -> react on short press
                          onTap: () => _showBlockDetails(row, col), 
                          // for Android and Windows Touch -> react on long press
                          onLongPressStart: (details) => _showContextMenu(context, details.globalPosition, row, col),
                          // for Windows desktop -> react on right mouse click
                          onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition, row, col),

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