import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const helpContent = '''
      # Teachers Timetable

      ## Überblick
      Die Lehrer Stundenplan-Anwendung wurde...
    ''';

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.help)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(helpContent),
        ),
      ),
    );
  }
}