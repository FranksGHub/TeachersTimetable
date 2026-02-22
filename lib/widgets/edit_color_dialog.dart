import 'package:flutter/material.dart';
import '../models/lesson_block.dart';
import '../l10n/app_localizations.dart';

class EditColorDialog extends StatefulWidget {
  final LessonBlock block;
  final Function(LessonBlock) onSave;

  const EditColorDialog({super.key, required this.block, required this.onSave});

  @override
  State<EditColorDialog> createState() => _EditColorDialogState();
}

class _EditColorDialogState extends State<EditColorDialog> {
  late Color selectedColor;

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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editBlockColor),
      scrollable: true,
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
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(LessonBlock(color: selectedColor));
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}