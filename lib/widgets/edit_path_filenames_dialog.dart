import 'package:flutter/material.dart';
import '../models/lesson_block.dart';
import '../l10n/app_localizations.dart';

class EditPathFilenamesDialog extends StatefulWidget {
  final LessonBlock block;
  final Function(LessonBlock) onSave;

  const EditPathFilenamesDialog({super.key, required this.block, required this.onSave});

  @override
  State<EditPathFilenamesDialog> createState() => _EditPathFilenamesDialogState();
}

class _EditPathFilenamesDialogState extends State<EditPathFilenamesDialog> {
  late TextEditingController workplanFilenameController;
  late TextEditingController SuggestionsFilenameController;
  late TextEditingController notesFilenameController;
  late bool notesBeforeWorkplanController;

  @override
  void initState() {
    super.initState();
    notesBeforeWorkplanController = widget.block.showNotesBeforeWorkplan;
    workplanFilenameController = TextEditingController(text: widget.block.workplanFilename);
    SuggestionsFilenameController = TextEditingController(text: widget.block.suggestionsFilename);
    notesFilenameController = TextEditingController(text: widget.block.notesFilename);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editFilenames),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: workplanFilenameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.workplanFilename)),
            TextField(controller: SuggestionsFilenameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.suggestionsFilename)),
            TextField(controller: notesFilenameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.notesFilename)),
            CheckboxListTile(
              title: Text(AppLocalizations.of(context)!.showNotesBeforeWorkplan),
              value: notesBeforeWorkplanController,
              onChanged: (value) {
                setState(() {
                  notesBeforeWorkplanController = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(LessonBlock(
              showNotesBeforeWorkplan: notesBeforeWorkplanController,
              workplanFilename: workplanFilenameController.text,
              suggestionsFilename: SuggestionsFilenameController.text,
              notesFilename: notesFilenameController.text,
            ));
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}