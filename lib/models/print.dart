import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../models/lesson_block.dart';

class PrintPdf {
  List<List<LessonBlock>> timetable = List.generate(6, (_) => List.generate(5, (_) => LessonBlock()));
  late List<String> days;
  late List<String> times;
  late String title;
  late SharedPreferences prefs;

  Future<void> loadData() async {
    prefs = await SharedPreferences.getInstance();
    title = prefs.getString('title') != null ? prefs.getString('title')! : 'Lehrer Stundenplan';
    days[0] = prefs.getString('mon') != null ? prefs.getString('mon')! : 'Mo';
    days[1] = prefs.getString('tue') != null ? prefs.getString('tue')! : 'Di';
    days[2] = prefs.getString('wed') != null ? prefs.getString('wed')! : 'Mi';
    days[3] = prefs.getString('thu') != null ? prefs.getString('thu')! : 'Do';
    days[4] = prefs.getString('fri') != null ? prefs.getString('fri')! : 'Fr';

    times[0] = prefs.getString('time1') != null ? prefs.getString('time1')! : '   1';
    times[1] = prefs.getString('time2') != null ? prefs.getString('time2')! : '   2';
    times[2] = prefs.getString('time3') != null ? prefs.getString('time3')! : '   3';
    times[3] = prefs.getString('time4') != null ? prefs.getString('time4')! : '   4';
    times[4] = prefs.getString('time5') != null ? prefs.getString('time5')! : '   5';
    times[5] = prefs.getString('time6') != null ? prefs.getString('time6')! : '   6';

    String? timetableJson = prefs.getString('timetable');
    if (timetableJson != null) {
      List<dynamic> timetableData = jsonDecode(timetableJson);
      timetable = timetableData.map((row) => (row as List).map((block) => LessonBlock( 
        lessonName: block['lessonName'], 
        className: block['className'], 
        schoolName: block['schoolName'], 
        color: Color(block['color']),
      )).toList()).toList().cast<List<LessonBlock>>();
    }
  }

  Future<bool> PrintTimetable() async {
    await loadData();
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ),
              ]),
              
              pw.TableRow(children: [pw.Text('Time'), ...days.map((day) => pw.Text(day))],)]
              ...List.generate(6, (row) {
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
                          pw.Text(block.className, style: pw.TextStyle(color: isDark(block.color) ? PdfColors.white : PdfColors.black, fontSize: 8)),
                          pw.Text(block.schoolName, style: pw.TextStyle(color: isDark(block.color) ? PdfColors.white : PdfColors.black, fontSize: 8)),
                        ],
                      ),
                    );
                  }),
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
                            pw.Text(block.className, style: pw.TextStyle(color: isDark(block.color) ? PdfColors.white : PdfColors.black, fontSize: 8)),
                            pw.Text(block.schoolName, style: pw.TextStyle(color: isDark(block.color) ? PdfColors.white : PdfColors.black, fontSize: 8)),
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
    return true;
  }

}