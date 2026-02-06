import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

class LessonBlock {
  Color color;
  String lessonName;
  String className;
  String schoolName;
  bool hideLeftList;
  bool hideRightList;
  

  LessonBlock({
    this.color = Colors.white,
    this.lessonName = '',
    this.className = '',
    this.schoolName = '',
    this.hideLeftList = false,
    this.hideRightList = false,
  });

  /// Convert Flutter Color to PDF Color
  PdfColor get pdfColor => PdfColor.fromInt(color.toARGB32());
}