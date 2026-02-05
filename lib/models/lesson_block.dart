import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

class LessonBlock {
  Color color;
  String lessonName;
  String className;
  String schoolName;

  LessonBlock({
    this.color = Colors.white,
    this.lessonName = '',
    this.className = '',
    this.schoolName = '',
  });

  /// Convert Flutter Color to PDF Color
  PdfColor get pdfColor => PdfColor.fromInt(color.toARGB32());
}