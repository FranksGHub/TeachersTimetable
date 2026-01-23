import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/lesson_block.dart';
import 'edit_block_dialog.dart';
import 'edit_title_dialog.dart';
import 'edit_days_dialog.dart';
import 'edit_times_dialog.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  List<List<LessonBlock>> timetable = List.generate(6, (_) => List.generate(5, (_) => LessonBlock()));
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  List<String> times = ['   1', '   2', '   3', '   4', '   5', '   6'];
  String title = 'Teachers Timetable';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    prefs = await SharedPreferences.getInstance();
    String? titleJson = prefs.getString('title');
    if (titleJson != null) {
      setState(() {
        title = titleJson;
      });
    }
    days[0] = prefs.getString('mon') != null ? prefs.getString('mon')! : 'Mon';
    days[1] = prefs.getString('tue') != null ? prefs.getString('tue')! : 'Tue';
    days[2] = prefs.getString('wed') != null ? prefs.getString('wed')! : 'Wed';
    days[3] = prefs.getString('thu') != null ? prefs.getString('thu')! : 'Thu';
    days[4] = prefs.getString('fri') != null ? prefs.getString('fri')! : 'Fri';
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
          roomNumber: block['roomNumber'],
          schoolName: block['schoolName'],
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
      'schoolName': block.schoolName,
      'roomNumber': block.roomNumber,
    }).toList()).toList()));
  }

  bool isDark(Color color) {
    double luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    return luminance < 0.5;
  }

  void _editBlock(int row, int col) {
    showDialog(
      context: context,
      builder: (context) => EditBlockDialog(
        block: timetable[row][col],
        onSave: (updatedBlock) {
          setState(() {
            timetable[row][col] = updatedBlock;
          });
          saveData();
        },
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

  void _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                children: [
                  pw.Text('Time'),
                  ...days.map((day) => pw.Text(day)),
                ],
              ),
              ...List.generate(6, (row) {
                return pw.TableRow(
                  children: [
                    pw.Text(times[row]),
                    ...List.generate(5, (col) {
                      final block = timetable[row][col];
                      return pw.Container(
                        decoration: pw.BoxDecoration(
                          color: PdfColor(block.color.r / 255, block.color.g / 255, block.color.b / 255),
                          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                        ),
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(block.lessonName, style: pw.TextStyle(color: isDark(block.color) ? PdfColors.white : PdfColors.black, fontSize: 8)),
                            pw.Text(block.schoolName, style: pw.TextStyle(color: isDark(block.color) ? PdfColors.white : PdfColors.black, fontSize: 8)),
                            pw.Text(block.roomNumber, style: pw.TextStyle(color: isDark(block.color) ? PdfColors.white : PdfColors.black, fontSize: 8)),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void _exportData() async {
    Map<String, dynamic> data = {};
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      data[key] = prefs.get(key);
    }
    String jsonData = jsonEncode(data);

    if (Platform.isAndroid) {
      // Share on Android
      await Share.share(jsonData, subject: 'Timetable Data');
    } else {
      // Save to file on Windows/Web
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Timetable Data',
        fileName: 'timetable_data.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (outputFile != null) {
        File file = File(outputFile);
        await file.writeAsString(jsonData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to $outputFile')),
        );
      }
    }
  }

  void _importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String jsonData = await file.readAsString();
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
      loadData(); // Reload data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('      ' + title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTitle,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editDays,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTimes,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _generatePdf,
          ),
        ],
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
                                Text(block.schoolName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(block.roomNumber, style: const TextStyle(fontSize: 16)),
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
    );
  }
}