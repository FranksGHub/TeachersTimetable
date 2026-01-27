import 'package:flutter/material.dart';

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
}