import 'package:flutter/material.dart';

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
      title: const Text('Edit Days'),
      content: TextField(
        controller: daysController,
        decoration: const InputDecoration(labelText: 'Days'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            widget.onSave(daysController.text.split(', '));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}