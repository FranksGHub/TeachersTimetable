import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../l10n/app_localizations.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  Future<String> _loadReadme(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final path = (lang == 'de') ? 'Readme_de.md' : 'Readme_en.md';
    return rootBundle.loadString(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${AppLocalizations.of(context)!.appTitle} - ${AppLocalizations.of(context)!.help}')),
      body: FutureBuilder<String>(
        future: _loadReadme(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final lang = Localizations.localeOf(context).languageCode;
            final msg = (lang == 'de') ? 'Fehler beim Laden der Hilfe.' : 'Error loading help.';
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(msg),
            );
          }
          final data = snapshot.data ?? '';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Markdown(data: data),
          );
        },
      ),
    );
  }
}