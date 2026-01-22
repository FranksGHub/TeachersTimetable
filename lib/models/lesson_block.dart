import 'package:flutter/material.dart';

class LessonBlock {
  Color color;
  String lessonName;
  String schoolName;
  String roomNumber;

  LessonBlock({
    this.color = Colors.white,
    this.lessonName = '',
    this.schoolName = '',
    this.roomNumber = '',
  });
}