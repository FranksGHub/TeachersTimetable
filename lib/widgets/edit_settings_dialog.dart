import 'package:flutter/material.dart';
import 'package:teachers_timetable/models/export_import_files.dart';
import '../models/lesson_block.dart';
import '../l10n/app_localizations.dart';

class EditSettingsDialog extends StatefulWidget {
  final LessonBlock block;
  final int col;
  final Function(LessonBlock) onSave;

  const EditSettingsDialog({super.key, required this.block, required this.col, required this.onSave});

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
    leftListFilenameController = TextEditingController(text: widget.block.workplanFilename.length == 0 ? ExportImportFiles.GetSaveFilename(getDefaultLeftFilename()) : widget.block.workplanFilename);
    rightListFilenameController = TextEditingController(text: widget.block.suggestionsFilename.length == 0 ? ExportImportFiles.GetSaveFilename(getDefaultRightFilename()) : widget.block.suggestionsFilename);
    notesFilenameController = TextEditingController(text: widget.block.notesFilename.length == 0 ? ExportImportFiles.GetSaveFilename(getDefaultNotesFilename()) : widget.block.notesFilename);
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

  String getDefaultLeftFilename() { 
    return '${widget.block.lessonName}_${widget.block.className}_${widget.block.schoolName}.json';
  }

  String getDefaultRightFilename() { 
    return '${widget.block.lessonName}.json';
  }

  String getDefaultNotesFilename() { 
    return 'notes_col_${widget.col}.json';
  }

  Widget buildSettingRow({ required String label, required TextEditingController controller,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 6),
          SizedBox( width: 120, child: Text(label)),
          //Expanded( flex: 2, child: Text(label)),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true, // macht das TextField kompakter
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildColorRow({ required String label }) {
    // Color display
    return Row(
      children: [
        const SizedBox(width: 6),
        SizedBox( width: 122, child: Text(label)),
        Wrap(
          children: 
            colors.map((color) {
            return GestureDetector(
              onTap: () => setState(() => selectedColor = color),
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  border: selectedColor == color ? Border.all(color: Colors.black, width: 3) : Border.all(color: Colors.black, width: 1),
                ),
              ),
            );
          }).toList(),
        ),
      ]
    );
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

            // Color setting
            buildColorRow( label: AppLocalizations.of(context)!.color),

            // 6 Text lines
            buildSettingRow(
              label: AppLocalizations.of(context)!.lessonName,
              controller: lessonNameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.className,
              controller: classNameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.schoolName,
              controller: schoolNameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.workplanFilename,
              controller: leftListFilenameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.suggestionsFilename,
              controller: rightListFilenameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.notesFilename,
              controller: notesFilenameController,
            ),

            //const SizedBox(height: 8),

            // Checkbox for notes setting
            Row(
              children: [
                const SizedBox(width: 122),
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