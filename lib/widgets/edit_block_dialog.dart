import 'package:flutter/material.dart';
import '../models/lesson_block.dart';

class EditBlockDialog extends StatefulWidget {
  final LessonBlock block;
  final Function(LessonBlock) onSave;

  const EditBlockDialog({super.key, required this.block, required this.onSave});

  @override
  State<EditBlockDialog> createState() => _EditBlockDialogState();
}

class _EditBlockDialogState extends State<EditBlockDialog> {
  late Color selectedColor;
  late TextEditingController lessonController;
  late TextEditingController schoolController;
  late TextEditingController roomController;

  final List<Color> colors = [
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.block.color;
    lessonController = TextEditingController(text: widget.block.lessonName);
    schoolController = TextEditingController(text: widget.block.schoolName);
    roomController = TextEditingController(text: widget.block.roomNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Block'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Color:'),
            Wrap(
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      border: selectedColor == color ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            TextField(controller: lessonController, decoration: const InputDecoration(labelText: 'Lesson Name')),
            TextField(controller: schoolController, decoration: const InputDecoration(labelText: 'Class Name')),
            TextField(controller: roomController, decoration: const InputDecoration(labelText: 'School Name')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            widget.onSave(LessonBlock(
              color: selectedColor,
              lessonName: lessonController.text,
              schoolName: schoolController.text,
              roomNumber: roomController.text,
            ));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}