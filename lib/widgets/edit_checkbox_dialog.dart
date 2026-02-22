import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EditCheckboxDialog extends StatefulWidget {
  final bool checkValue;
  final String dialogTitle;
  final String dialogText;
  final Function(bool) onSave;

  const EditCheckboxDialog({super.key, required this.checkValue, required this.dialogTitle, required this.dialogText, required this.onSave});

  @override
  State<EditCheckboxDialog> createState() => _EditCheckboxDialogState();
}

class _EditCheckboxDialogState extends State<EditCheckboxDialog> {
  late bool notesBeforeWorkplanController;

  @override
  void initState() {
    super.initState();
    notesBeforeWorkplanController = widget.checkValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text(widget.dialogText),
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
            widget.onSave( notesBeforeWorkplanController);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}