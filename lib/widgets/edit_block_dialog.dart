import 'package:flutter/material.dart';
import '../models/lesson_block.dart';
import '../l10n/app_localizations.dart';

class EditBlockDialog extends StatefulWidget {
  final LessonBlock block;
  final Function(LessonBlock) onSave;

  const EditBlockDialog({super.key, required this.block, required this.onSave});

  @override
  State<EditBlockDialog> createState() => _EditBlockDialogState();
}

class _EditBlockDialogState extends State<EditBlockDialog> {
  late Color selectedColor;
  late TextEditingController lessonNameController;
  late TextEditingController classNameController;
  late TextEditingController schoolNameController;

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
    lessonNameController = TextEditingController(text: widget.block.lessonName);
    classNameController = TextEditingController(text: widget.block.className);
    schoolNameController = TextEditingController(text: widget.block.schoolName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editBlock),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.color),
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
            TextField(controller: lessonNameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lessonName)),
            TextField(controller: classNameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.className)),
            TextField(controller: schoolNameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.schoolNameLabel)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(LessonBlock(
              color: selectedColor,
              lessonName: lessonNameController.text,
              className: classNameController.text,
              schoolName: schoolNameController.text,
            ));
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}