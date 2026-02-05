import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../l10n/app_localizations.dart';
import '../models/lesson_block.dart';

class PrintPdf {

  Future<bool> PrintTimetable(BuildContext context, String title, List<String> days, List<String> times, List<List<LessonBlock>> timetable) async {

    // Defensive checks: dimensions
    if (days.isEmpty || times.isEmpty) return false;
    if (timetable.length != times.length) return false;
    for (final row in timetable) {
      if (row.length != days.length) return false;
    }

    final pdf = pw.Document(title: AppLocalizations.of(context)!.appTitle, author: AppLocalizations.of(context)!.appNameWithSpaces, subject: title, keywords: 'stundenplan, timetable, print, pdf');

    // Page creation
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          // Column widths: first column (time) narrow, rest evenly distributed.
          final int colCount = days.length;
          final Map<int, pw.TableColumnWidth> colWidths = {
            0: const pw.FixedColumnWidth(60), // Zeit-Spalte
          };
          for (int i = 1; i <= colCount; i++) {
            colWidths[i] = const pw.FlexColumnWidth(1);
          }

          // Header (Title + Spacing)
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center( child: pw.Text( title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)) ),
              pw.SizedBox(height: 12),
              // Table: first row = empty left cell + days header
              pw.Table(
                columnWidths: colWidths,
                border: null, // pw.TableBorder.all(color: PdfColors.grey300, width: 0.0),  // no borders
                children: [
                  // Header row: left cell empty (for times) + days
                  pw.TableRow(
                    children: [
                      pw.Container(), // empty cell above the time column
                      for (final d in days)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 3),
                          alignment: pw.Alignment.center,
                          child: pw.Text( d, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal))
                        )
                    ],
                  ),
                  // Data rows: one row with time label for each time period + 5 blocks
                  for (int r = 0; r < times.length; r++)
                    pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        // Time column (left)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          alignment: pw.Alignment.center,
                          child: pw.Text( times[r], style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal))
                        ), 

                        // The cells for the days
                        for (int c = 0; c < days.length; c++)
                          pw.Container( padding: const pw.EdgeInsets.all(3), child: () {
                              final LessonBlock block = timetable[r][c];
                              return pw.Container(
                                height: 48,
                                decoration: pw.BoxDecoration(
                                  color: block.pdfColor,
                                  borderRadius: pw.BorderRadius.zero, // pw.BorderRadius.circular(4),
                                  border: pw.Border.all(color: PdfColors.black, width: 0.5),
                                ),
                                padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                child: pw.Column( mainAxisAlignment: pw.MainAxisAlignment.center, crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text( block.lessonName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black), maxLines: 1 )
                                    ), 
                                    
                                    pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text( block.className, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black), maxLines: 1 )
                                    ), 
                                    
                                    pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text( block.schoolName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal, color: PdfColors.black), maxLines: 1 )
                                    ), 
                                  ],
                                ),
                              );
                            }(),
                          ),
                      ],
                    ),
                ],
              ),
              // pw.Spacer(),
              // // Footer / Print notice (optional)
              pw.SizedBox(height: 12),  // Distance according to the table
              pw.Container( alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 6),
                child: pw.Text(AppLocalizations.of(context)!.printingFooter(DateTime.now().toLocal().toString().split('.').first), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey))
              )
            ],
          );
        },
      ),
    );

    try {
      // Open print dialog and transfer PDF
      await Printing.layoutPdf( onLayout: (PdfPageFormat format) async => pdf.save() );
      return true;
    } catch (e) {
      // Printing error / Cancel dialog
      return false;
    }
  }
}