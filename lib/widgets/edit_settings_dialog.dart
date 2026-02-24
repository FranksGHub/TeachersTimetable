import 'package:flutter/material.dart';
import '../models/lesson_block.dart';
import '../l10n/app_localizations.dart';

class EditSettingsDialog extends StatefulWidget {
  final LessonBlock block;
  final Function(LessonBlock) onSave;

  const EditSettingsDialog({super.key, required this.block, required this.onSave});

  @override
  State<EditSettingsDialog> createState() => _EditSettingsDialogState();
}

class _EditSettingsDialogState extends State<EditSettingsDialog> {
  late Color selectedColor;
  late bool showNotesBeforeWorkplan;
  late TextEditingController lessonNameController;
  late TextEditingController classNameController;
  late TextEditingController schoolNameController;
  late TextEditingController leftListFilenameController;
  late TextEditingController rightListFilenameController;
  late TextEditingController notesFilenameController;

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
    showNotesBeforeWorkplan = widget.block.showNotesBeforeWorkplan;
    lessonNameController = TextEditingController(text: widget.block.lessonName);
    classNameController = TextEditingController(text: widget.block.className);
    schoolNameController = TextEditingController(text: widget.block.schoolName);
    leftListFilenameController = TextEditingController(text: widget.block.workplanFilename);
    rightListFilenameController = TextEditingController(text: widget.block.suggestionsFilename);
    notesFilenameController = TextEditingController(text: widget.block.notesFilename);
  }

  @override
  void dispose() {
    lessonNameController.dispose();
    classNameController.dispose();
    schoolNameController.dispose();
    leftListFilenameController.dispose();
    rightListFilenameController.dispose();
    notesFilenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( title: Text(AppLocalizations.of(context)!.editBlock)), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Setting 1
            Text(AppLocalizations.of(context)!.lessonName),
            TextField(
              controller: lessonNameController,
              decoration: const InputDecoration( border: OutlineInputBorder()),
            ),

            const SizedBox(height: 8),

            // Setting 2
            Text(AppLocalizations.of(context)!.className),
            TextField(
              controller: classNameController,
              decoration: const InputDecoration( border: OutlineInputBorder()),
            ),

            const SizedBox(height: 8),

            // Setting 3
            Text(AppLocalizations.of(context)!.schoolName),
            TextField(
              controller: schoolNameController,
              decoration: const InputDecoration( border: OutlineInputBorder()),
            ),
            
            const SizedBox(height: 8),

            // Setting 4
            Text(AppLocalizations.of(context)!.workplanFilename),
            TextField(
              controller: leftListFilenameController,
              decoration: const InputDecoration( border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            // Setting 5
            Text(AppLocalizations.of(context)!.suggestionsFilename),
            TextField(
              controller: rightListFilenameController,
              decoration: const InputDecoration( border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            // Setting 6
            Text(AppLocalizations.of(context)!.notesFilename),
            TextField(
              controller: notesFilenameController,
              decoration: const InputDecoration( border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            // Checkbox Setting
            Row(
              children: [
                Checkbox(
                  value: showNotesBeforeWorkplan,
                  onChanged: (value) {
                    setState(() {
                      showNotesBeforeWorkplan = value ?? false;
                    });
                  },
                ),
                Text(AppLocalizations.of(context)!.showNotesBeforeWorkplan),
              ],
            ),
          ],
        ),
      ),
    );
  }
}