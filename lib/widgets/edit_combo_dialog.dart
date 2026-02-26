import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EditComboDialog extends StatefulWidget {
  final int currentValue;
  final String dialogTitle;
  final String dialogText;
  final Function(int) onSave;

  const EditComboDialog({super.key, required this.currentValue, required this.dialogTitle, required this.dialogText, required this.onSave});

  @override
  State<EditComboDialog> createState() => _EditComboDialogState();
}

class _EditComboDialogState extends State<EditComboDialog> {
  late int newValue = widget.currentValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.dialogText),
          const SizedBox(height: 6),
          StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<int>(
                value: newValue,
                items: List.generate(
                  9, (i) => DropdownMenuItem( value: i + 1, child: Text('${i + 1}') ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => newValue = value);
                  }
                },
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
          onPressed: () {
            widget.onSave(newValue);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

}