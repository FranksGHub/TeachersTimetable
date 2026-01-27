import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EditDaysDialog extends StatefulWidget {
  final List<String> days;
  final Function(List<String>) onSave;

  const EditDaysDialog({super.key, required this.days, required this.onSave});

  @override
  State<EditDaysDialog> createState() => _EditDaysDialogState();
}

class _EditDaysDialogState extends State<EditDaysDialog> {
  late TextEditingController daysController;

  @override
  void initState() {
    super.initState();
    daysController = TextEditingController(text: widget.days.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editDays),
      content: TextField(
        controller: daysController,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.days),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(daysController.text.split(', '));
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}