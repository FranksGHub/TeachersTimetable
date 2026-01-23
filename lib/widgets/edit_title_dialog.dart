import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EditTitleDialog extends StatefulWidget {
  final String currentTitle;
  final Function(String) onSave;

  const EditTitleDialog({super.key, required this.currentTitle, required this.onSave});

  @override
  State<EditTitleDialog> createState() => _EditTitleDialogState();
}

class _EditTitleDialogState extends State<EditTitleDialog> {
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.currentTitle);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editTitle),
      content: TextField(
        controller: titleController,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.title),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(titleController.text);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}