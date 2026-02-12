import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path/path.dart' as p;
import '../l10n/app_localizations.dart';
import '../models/lesson_block.dart';
import '../models/lesson_item.dart';
import '../models/export_import_files.dart';
import 'dart:io';
import 'dart:convert';

class PrintPdf {

  Future<bool> PrintNotes(BuildContext context, String markdowntext) async {
    // Printing: convert HTML to PDF and open print dialog
    try {
      // Erzeuge einfache Markdown-Blocks (wir nutzen die markdown lib nur für Zeilenaufteilung)
      final lines = const LineSplitter().convert(markdowntext);

        // Erstelle PDF-Dokument
        final doc = pw.Document();

        doc.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            build: (context) {
              // Konvertiere Markdown-Lines in pw-Widgets
              final widgets = <pw.Widget>[];
              final buffer = <String>[]; // für List- oder Paragraph-Puffer
              String? currentListType; // 'ul' oder 'ol'
              bool inCodeBlock = false;
              final codeBuffer = <String>[];

              void flushParagraph() {
                if (buffer.isEmpty) return;
                final text = buffer.join('\n').trim();
                if (text.isNotEmpty) {
                  widgets.add(_paragraphToPw(text));
                }
                buffer.clear();
              }

              void flushList() {
                if (buffer.isEmpty) return;
                final items = buffer.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                if (items.isNotEmpty) {
                  widgets.add(pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: items.map((it) => pw.Bullet(text: _inlineMarkdownToPlain(it))).toList(),
                  ));
                }
                buffer.clear();
                currentListType = null;
              }

              for (var raw in lines) {
                final line = raw.replaceAll('\t', '    ');
                // Codeblock fence
                if (line.startsWith('```')) {
                  if (inCodeBlock) {
                    // Ende Codeblock
                    widgets.add(
                      pw.Container(
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(codeBuffer.join('\n'), style: pw.TextStyle(font: pw.Font.courier())),
                      ),
                    );
                    codeBuffer.clear();
                    inCodeBlock = false;
                  } else {
                    // Start Codeblock
                    flushParagraph();
                    flushList();
                    inCodeBlock = true;
                  }
                  continue;
                }

                if (inCodeBlock) {
                  codeBuffer.add(line);
                  continue;
                }

                // Überschriften
                final hMatch = RegExp(r'^(#{1,6})\s+(.*)').firstMatch(line);
                if (hMatch != null) {
                  flushParagraph();
                  flushList();
                  final level = hMatch.group(1)!.length;
                  final text = hMatch.group(2) ?? '';
                  widgets.add(_headingToPw(level, _inlineMarkdownToPlain(text)));
                  continue;
                }

                // Unordered list
                final ulMatch = RegExp(r'^\s*[-\*\+]\s+(.*)').firstMatch(line);
                if (ulMatch != null) {
                  final item = ulMatch.group(1) ?? '';
                  if (currentListType != 'ul') {
                    flushParagraph();
                    flushList();
                    currentListType = 'ul';
                  }
                  buffer.add(item);
                  continue;
                }

                // Ordered list
                final olMatch = RegExp(r'^\s*\d+\.\s+(.*)').firstMatch(line);
                if (olMatch != null) {
                  final item = olMatch.group(1) ?? '';
                  if (currentListType != 'ol') {
                    flushParagraph();
                    flushList();
                    currentListType = 'ol';
                  }
                  buffer.add(item);
                  continue;
                }

                // Leerzeile -> Absatzende
                if (line.trim().isEmpty) {
                  flushParagraph();
                  flushList();
                  continue;
                }

                // normale Textzeile -> Puffer
                buffer.add(line);
              }

              // Flush am Ende
              if (inCodeBlock) {
                widgets.add(
                  pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(codeBuffer.join('\n'), style: pw.TextStyle(font: pw.Font.courier())),
                  ),
                );
              } else {
                flushParagraph();
                flushList();
              }

              // Falls keine Widgets, füge leeren Text hinzu
              if (widgets.isEmpty) {
                widgets.add(pw.Text(''));
              }

              return widgets;
            },
          ),
        );

        // Speichern und Drucken
        final pdfBytes = await doc.save();
        await Printing.layoutPdf(onLayout: (format) async => pdfBytes);

    } catch (e) {
      return false;
    }

    return true;
  }

  // Hilfsfunktionen

  pw.Widget _headingToPw(int level, String text) {
    final sizes = {1: 22.0, 2: 18.0, 3: 16.0, 4: 14.0, 5: 12.0, 6: 11.0};
    final size = sizes[level] ?? 12.0;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: size, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _paragraphToPw(String text) {
    // Ersetze Inline-Markdown (**bold**, *italic*, `code`) durch einfache pw.RichText
    final spans = _buildTextSpans(text);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.RichText(text: pw.TextSpan(children: spans)),
    );
  }

  String _inlineMarkdownToPlain(String s) {
    // Entfernt einfache Markdown-Markierungen für Listeneinträge
    var out = s.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1) ?? '');
    out = out.replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m.group(1) ?? '');
    out = out.replaceAll('`', '');
    return out;
  }

  List<pw.TextSpan> _buildTextSpans(String text) {
    final spans = <pw.TextSpan>[];
    var remaining = text;

    // Einfacher Parser: **bold**, *italic*, `code`
    final pattern = RegExp(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)', dotAll: true);
    final matches = pattern.allMatches(remaining).toList();

    if (matches.isEmpty) {
      spans.add(pw.TextSpan(text: remaining));
      return spans;
    }

    var lastIndex = 0;
    for (final m in matches) {
      if (m.start > lastIndex) {
        spans.add(pw.TextSpan(text: remaining.substring(lastIndex, m.start)));
      }
      final token = remaining.substring(m.start, m.end);
      if (token.startsWith('**') && token.endsWith('**')) {
        final inner = token.substring(2, token.length - 2);
        spans.add(pw.TextSpan(text: inner, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
      } else if (token.startsWith('*') && token.endsWith('*')) {
        final inner = token.substring(1, token.length - 1);
        spans.add(pw.TextSpan(text: inner, style: pw.TextStyle(fontStyle: pw.FontStyle.italic)));
      } else if (token.startsWith('`') && token.endsWith('`')) {
        final inner = token.substring(1, token.length - 1);
        spans.add(pw.TextSpan(text: inner, style: pw.TextStyle(font: pw.Font.courier())));
      } else {
        spans.add(pw.TextSpan(text: token));
      }
      lastIndex = m.end;
    }
    if (lastIndex < remaining.length) {
      spans.add(pw.TextSpan(text: remaining.substring(lastIndex)));
    }
    return spans;
  }


  Future<bool> PrintBlockDetails(BuildContext context, LessonBlock block) async {
    // Header title
    String title = '${block.lessonName} - ${block.className} - ${block.schoolName}';
    // try to load list data
    String dataPath = await ExportImportFiles.GetPrivateDirectoryPath();
    String filePathName = p.join(dataPath, ExportImportFiles.GetSaveFilename('${block.lessonName}_${block.className}_${block.schoolName}.json'));
    List<LessonItem> leftItems = <LessonItem>[];
    try {
      if (File(filePathName).existsSync()) {
        String json = File(filePathName).readAsStringSync();
        List<dynamic> data = jsonDecode(json);
        leftItems = List<LessonItem>.from(data.map((e) => LessonItem.fromJson(e)));
      }
    } catch (e) {
      return false;
    }
    if (leftItems.isEmpty) return false;

    final pdf = pw.Document(title: AppLocalizations.of(context)!.appTitle, author: AppLocalizations.of(context)!.appNameWithSpaces, subject: title, keywords: 'stundenplan, timetable, worklist, print, pdf');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          return <pw.Widget>[

            // Titel
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(AppLocalizations.of(context)!.workplan + ':   ' + title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.black), textAlign: pw.TextAlign.left),
            ),
            pw.SizedBox(height: 12),

            // Items
            for (final item in leftItems) ...[
              // Item-Text (linksbündig, etwas Abstand nach unten)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text( item.text, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.left),
              ),

              // Subitems: eingerückt, jede in einer Zeile mit Icon, Status-Text und Subitem-Text
              for (final sub in item.subitems)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Status Icon: kleiner Kreis, grün wenn "(F)" sonst gelb
                      pw.Container( width: 8, height: 8,
                        decoration: pw.BoxDecoration(
                          color: sub.status == "(F)" ? PdfColors.green : PdfColors.yellow,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 4),

                      // Status Text
                      pw.Text( sub.status ?? '', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal)),
                      pw.SizedBox(width: 8),

                      // Subitem Text (nimmt restlichen Platz)
                      pw.Expanded(child: pw.Text( sub.text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal)) ),
                    ],
                  ),
                ),

              // Abstand zwischen Items
              pw.SizedBox(height: 8),
            ],

            // pw.Spacer(),
            // // Footer / Print notice (optional)
            pw.SizedBox(height: 12),  // Distance according to the table
            pw.Container( alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 6),
              child: pw.Text(AppLocalizations.of(context)!.printingFooter(DateTime.now().toLocal().toString().split('.').first), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey))
            )

          ];
        },
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
      return true;
    } catch (e) {
      return false;
    }
  }


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