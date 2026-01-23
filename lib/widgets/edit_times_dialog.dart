import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EditTimesDialog extends StatefulWidget {
  final List<String> times;
  final Function(List<String>) onSave;

  const EditTimesDialog({super.key, required this.times, required this.onSave});

  @override
  State<EditTimesDialog> createState() => _EditTimesDialogState();
}

class _EditTimesDialogState extends State<EditTimesDialog> {
  late TextEditingController timesController;

  @override
  void initState() {
    super.initState();
    timesController = TextEditingController(text: widget.times.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editTimes),
      content: TextField(
        controller: timesController,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.times),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(timesController.text.split(', '));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}