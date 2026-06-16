import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:path/path.dart' as path;

import '../models/export_import_files.dart';
import '../models/filename_helper.dart';
import '../models/lesson_block.dart';
import '../l10n/app_localizations.dart';

class EditSettingsDialog extends StatefulWidget {
  final LessonBlock block;
  final int col;
  final Function(LessonBlock) onSave;

  const EditSettingsDialog({super.key, required this.block, required this.col, required this.onSave});

  @override
  State<EditSettingsDialog> createState() => _EditSettingsDialogState();
}

class _EditSettingsDialogState extends State<EditSettingsDialog> {
  late Color selectedColor;
  late bool showNotesBeforeWorkplan;
  late TextEditingController lessonNameController;
  late TextEditingController classNameController;
  late TextEditingController schoolNameController;
  late TextEditingController leftListFilenameController;
  late TextEditingController rightListFilenameController;
  late TextEditingController notesFilenameController;
  Timer? _debounce;

  final List<Color> colors = [
    Colors.white,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.lightBlue,
    Colors.blue,
    Colors.purple,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.block.color;
    showNotesBeforeWorkplan = widget.block.showNotesBeforeWorkplan;
    lessonNameController = TextEditingController(text: widget.block.lessonName);
    classNameController = TextEditingController(text: widget.block.className);
    schoolNameController = TextEditingController(text: widget.block.schoolName);
    leftListFilenameController = TextEditingController(text: widget.block.workplanFilename.length == 0 ? FilenameHelper.getDefaultLeftFilename(widget.block, false) : widget.block.workplanFilename);
    rightListFilenameController = TextEditingController(text: widget.block.suggestionsFilename.length == 0 ? FilenameHelper.getDefaultRightFilename(widget.block, false) : widget.block.suggestionsFilename);
    notesFilenameController = TextEditingController(text: widget.block.notesFilename.length == 0 ? FilenameHelper.getDefaultNotesFilename(widget.col, false) : widget.block.notesFilename);
    lessonNameController.addListener(() { _onSettingChanged(); });
    classNameController.addListener(() { _onSettingChanged(); });
    schoolNameController.addListener(() { _onSettingChanged(); });
    leftListFilenameController.addListener(() { _onSettingChanged(); });
    rightListFilenameController.addListener(() { _onSettingChanged(); });
    notesFilenameController.addListener(() { _onSettingChanged(); });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    lessonNameController.dispose();
    classNameController.dispose();
    schoolNameController.dispose();
    leftListFilenameController.dispose();
    rightListFilenameController.dispose();
    notesFilenameController.dispose();
    super.dispose();
  }

  void _onSettingChanged() { 
    if (_debounce?.isActive ?? false) _debounce!.cancel(); 
    _debounce = Timer(const Duration(milliseconds: 900), () { 
      // this happens after the timer elapsed
      // e.g. validiate, store, setState, and so on })
      _debounce!.cancel();
      bool changed = false;
      String defaultLeftFilename = FilenameHelper.getDefaultLeftFilename(widget.block, false);
      String defaultRightFilename = FilenameHelper.getDefaultRightFilename(widget.block, false);
      String leftFilename = leftListFilenameController.text;
      String rightFilename = rightListFilenameController.text;
      if(leftFilename.endsWith('.json')) { leftFilename = leftFilename.replaceAll('.json', ''); }
      if(rightFilename.endsWith('.json')) { rightFilename = rightFilename.replaceAll('.json', ''); }
      
      if(widget.block.lessonName != lessonNameController.text ||
         widget.block.className != classNameController.text   ||
         widget.block.schoolName != schoolNameController.text) { 

        changed = true;
        widget.block.lessonName = lessonNameController.text;
        widget.block.className = classNameController.text; 
        widget.block.schoolName = schoolNameController.text; 

        // check if we have to change the default filenames too
        // get the new default filenames, if we had the defaults, before changing the lesson, class or school name
        if( defaultLeftFilename == leftFilename)   { leftFilename = FilenameHelper.getDefaultLeftFilename(widget.block, false); }
        if( defaultRightFilename == rightFilename) { rightFilename = FilenameHelper.getDefaultRightFilename(widget.block, false); }
        // update the defaults
        defaultLeftFilename = FilenameHelper.getDefaultLeftFilename(widget.block, false);
        defaultRightFilename = FilenameHelper.getDefaultRightFilename(widget.block, false);
      }

      if(widget.block.workplanFilename != leftFilename) { 
        if( defaultLeftFilename == leftFilename) {
          if(widget.block.workplanFilename.length != 0) { changed = true; widget.block.workplanFilename = ''; }
          } else { changed = true; widget.block.workplanFilename = leftFilename; }
      }
      
      if(widget.block.suggestionsFilename != rightFilename) { 
        if( defaultRightFilename == rightFilename) {
          if(widget.block.suggestionsFilename.length != 0) { changed = true; widget.block.suggestionsFilename = ''; }
          } else { changed = true; widget.block.suggestionsFilename = rightFilename; }
      }
      
      
      String notesFilename = notesFilenameController.text;
      if(notesFilename.endsWith('.json')) { notesFilename = notesFilename.replaceAll('.json', ''); }
      if(widget.block.notesFilename != notesFilename) { 
        if( FilenameHelper.getDefaultNotesFilename(widget.col, false) == notesFilename) {
          if(widget.block.notesFilename.length != 0) { changed = true; widget.block.notesFilename = ''; }
          } else { changed = true; widget.block.notesFilename = notesFilename; }
      }
      
      if(changed) {
        setState(() {});
        widget.onSave(widget.block);
      }
    });
  }

  void _onSettingChangedDirectly() { 
    bool changed = false;
    if(widget.block.color != selectedColor) { changed = true; widget.block.color = selectedColor; }
    if(widget.block.showNotesBeforeWorkplan != showNotesBeforeWorkplan) { changed = true; widget.block.showNotesBeforeWorkplan = showNotesBeforeWorkplan; }
    if(changed) {
      setState(() {});
      widget.onSave(widget.block);
    }
  }

  Widget _buildSettingRow({ required String label, required TextEditingController controller,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 6),
          SizedBox( width: 120, child: Text(label)),
          //Expanded( flex: 2, child: Text(label)),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true, // macht das TextField kompakter
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSettingRow({required String label, required TextEditingController controller, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 6),
          SizedBox( width: 120, child: Text(label)),
          //Expanded( flex: 2, child: Text(label)),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true, // macht das TextField kompakter
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // File picker button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.folder_open),
              onPressed: () => _pickJsonFile(controller, title),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickJsonFile(TextEditingController controller, String title) async {
    try {
      final privateDirPath = await ExportImportFiles.getPrivateDirectoryPath();
      final directory = Directory(privateDirPath);
      final jsonFiles = directory
        .listSync()
        .whereType<File>()
        .where((file) => (file.path.toLowerCase().endsWith('.json') && !file.path.toLowerCase().endsWith('timetable_settings.json')))
        .toList();

      if (jsonFiles.isEmpty) {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.noFilesFoundInAppDirTitle),
            content: Text(AppLocalizations.of(context)!.noFilesFoundInAppDir),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          ),
        );
        return;
      }

      final displayedFilenames = jsonFiles.map((file) => path.basenameWithoutExtension(file.path)).toList()..sort();
      // final displayedFilenames = filenames.length > 30 ? filenames.sublist(0, 30) : filenames;

      String? selectedFilename;

      final result = await showDialog<String>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              height: 320,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: displayedFilenames.length,
                itemBuilder: (context, index) {
                  final filename = displayedFilenames[index];
                  final isSelected = selectedFilename == filename;
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(filename),
                    selected: isSelected,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.3),
                    onTap: () {
                      setState(() {
                        selectedFilename = filename;
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: selectedFilename != null ? () => _deleteJsonFile(privateDirPath, selectedFilename, displayedFilenames, setState) : null,
                child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red.withValues(alpha: selectedFilename != null ? 0.9 : 0.3))),
              ),
              TextButton(
                onPressed: selectedFilename != null ? () => Navigator.pop(context, selectedFilename) : null,
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        ),
      );

      if (result == null) return;
      controller.text = result;
    } catch (e) {
      debugPrint('JSON file selection failed: $e');
    }
  }


  void _deleteJsonFile(String privateDirPath, String? selectedFilename, List<String> displayedFilenames, Function(VoidCallback) setState) {
    if (selectedFilename == null) return;
    try {
      // Delete the file from the directory
      final filePath = '$privateDirPath${Platform.pathSeparator}$selectedFilename.json';
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }

      // Update the dialog state
      setState(() {
        displayedFilenames.remove(selectedFilename);
      });
    } catch (e) {
      debugPrint('Failed to delete file: $e');
    }
  }
  
  Widget _buildColorRow({ required String label }) {
    // Color display
    return Row(
      children: [
        const SizedBox(width: 6),
        SizedBox( width: 122, child: Text(label)),
        Wrap(
          children: 
            colors.map((color) {
            return GestureDetector(
              onTap: () { selectedColor = color; _onSettingChangedDirectly(); },
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  border: selectedColor == color ? Border.all(color: Colors.black, width: 3) : Border.all(color: Colors.black, width: 1),
                ),
              ),
            );
          }).toList(),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( title: Text(AppLocalizations.of(context)!.editBlock)), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 

            // Color setting
            _buildColorRow( label: AppLocalizations.of(context)!.color),

            // 6 Text lines
            _buildSettingRow(
              label: AppLocalizations.of(context)!.lessonName,
              controller: lessonNameController,
            ),
            _buildSettingRow(
              label: AppLocalizations.of(context)!.className,
              controller: classNameController,
            ),
            _buildSettingRow(
              label: AppLocalizations.of(context)!.schoolName,
              controller: schoolNameController,
            ),
            _buildFileSettingRow(
              label: AppLocalizations.of(context)!.workplanFilename,
              controller: leftListFilenameController, title: AppLocalizations.of(context)!.myFilePickerTitleWorkPlan,
            ),
            _buildFileSettingRow(
              label: AppLocalizations.of(context)!.suggestionsFilename,
              controller: rightListFilenameController, title: AppLocalizations.of(context)!.myFilePickerTitleSuggestions,
            ),
            _buildFileSettingRow(
              label: AppLocalizations.of(context)!.notesFilename,
              controller: notesFilenameController, title: AppLocalizations.of(context)!.myFilePickerTitleNotes,
            ),

            //const SizedBox(height: 8),

            // Checkbox for notes setting
            Row(
              children: [
                const SizedBox(width: 122),
                Checkbox(
                  value: showNotesBeforeWorkplan,
                  onChanged: (value) { showNotesBeforeWorkplan = value ?? false; _onSettingChangedDirectly(); }
                ),
                Text(AppLocalizations.of(context)!.showNotesBeforeWorkplan),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}