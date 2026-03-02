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

  void copy(LessonBlock block) {
    color = block.color;
    lessonName = block.lessonName;
    className = block.className;
    schoolName = block.schoolName;
    hideLeftList = block.hideLeftList;
    hideRightList = block.hideRightList;
    showNotesBeforeWorkplan = block.showNotesBeforeWorkplan;
    workplanFilename = block.workplanFilename;
    suggestionsFilename = block.suggestionsFilename;
    notesFilename = block.notesFilename;
  }
  
}