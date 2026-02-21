import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EditTextDialog extends StatefulWidget {
  final String currentTextValue;
  final String dialogTitle;
  final String dialogText;
  final Function(String) onSave;

  const EditTextDialog({super.key, required this.currentTextValue, required this.dialogTitle, required this.dialogText, required this.onSave});

  @override
  State<EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<EditTextDialog> {
  late TextEditingController textValueController;

  @override
  void initState() {
    super.initState();
    textValueController = TextEditingController(text: widget.currentTextValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle), 
      content: TextField(controller: textValueController, decoration: InputDecoration(labelText: widget.dialogText)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(textValueController.text);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}