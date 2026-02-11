import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

class LessonBlock {
  Color color;
  String lessonName;
  String className;
  String schoolName;
  bool hideLeftList;
  bool hideRightList;
  bool showNotesBeforeWorkplan;
  String workplanFilename;
  String suggestionsFilename;
  String notesFilename;
  

  LessonBlock({
    this.color = Colors.white,
    this.lessonName = '',
    this.className = '',
    this.schoolName = '',
    this.hideLeftList = false,
    this.hideRightList = false,
    this.showNotesBeforeWorkplan = false,
    this.workplanFilename = '',
    this.suggestionsFilename = '',
    this.notesFilename = '',
  });

  /// Convert Flutter Color to PDF Color
  PdfColor get pdfColor => PdfColor.fromInt(color.toARGB32());
}