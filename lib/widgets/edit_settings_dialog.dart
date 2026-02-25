import 'package:flutter/material.dart';
import '../models/lesson_block.dart';
import '../models/filename_helper.dart';
import '../l10n/app_localizations.dart';
import 'dart:async';

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
      if(widget.block.color != selectedColor) { changed = true; widget.block.color = selectedColor; }
      
      if(widget.block.lessonName != lessonNameController.text) { 
        changed = true;
        // check if we change the filenames too
        bool leftFileNameDefault = FilenameHelper.getDefaultLeftFilename(widget.block, false) == leftListFilenameController.text;
        bool rightFileNameDefault = FilenameHelper.getDefaultRightFilename(widget.block, false) == rightListFilenameController.text;
        widget.block.lessonName = lessonNameController.text; 
        if( leftFileNameDefault) {  leftListFilenameController.text = FilenameHelper.getDefaultLeftFilename(widget.block, false); }
        if( rightFileNameDefault) { rightListFilenameController.text = FilenameHelper.getDefaultRightFilename(widget.block, false); }
      }

      if(widget.block.className != classNameController.text) { 
        changed = true; 
        // check if we change the filename too
        bool leftFileNameDefault = FilenameHelper.getDefaultLeftFilename(widget.block, false) == leftListFilenameController.text;
        widget.block.className = classNameController.text; 
        if( leftFileNameDefault) {  leftListFilenameController.text = FilenameHelper.getDefaultLeftFilename(widget.block, false); }
      }

      if(widget.block.schoolName != schoolNameController.text) { 
        changed = true; 
        // check if we change the filename too
        bool leftFileNameDefault = FilenameHelper.getDefaultLeftFilename(widget.block, false) == leftListFilenameController.text;
        widget.block.schoolName = schoolNameController.text; 
        if( leftFileNameDefault) {  leftListFilenameController.text = FilenameHelper.getDefaultLeftFilename(widget.block, false); }
      }
      
      if(widget.block.workplanFilename != leftListFilenameController.text) { 
        if( FilenameHelper.getDefaultLeftFilename(widget.block, false) == leftListFilenameController.text) {
          if(widget.block.workplanFilename.length != 0) { changed = true; widget.block.workplanFilename = ''; }
          } else { 
          changed = true; widget.block.workplanFilename = leftListFilenameController.text; 
        }
      }
      
      if(widget.block.suggestionsFilename != rightListFilenameController.text) { 
        if( FilenameHelper.getDefaultRightFilename(widget.block, false) == rightListFilenameController.text) {
          if(widget.block.suggestionsFilename.length != 0) { changed = true; widget.block.suggestionsFilename = ''; }
          } else { 
          changed = true; widget.block.suggestionsFilename = rightListFilenameController.text; 
        }
      }
      
      if(widget.block.notesFilename != notesFilenameController.text) { 
        if( FilenameHelper.getDefaultNotesFilename(widget.col, false) == notesFilenameController.text) {
          if(widget.block.notesFilename.length != 0) { changed = true; widget.block.notesFilename = ''; }
          } else { 
          changed = true; widget.block.notesFilename = notesFilenameController.text;
        }
      }
      
      if(widget.block.showNotesBeforeWorkplan != showNotesBeforeWorkplan) { 
        changed = true; widget.block.showNotesBeforeWorkplan = showNotesBeforeWorkplan; 
      }
      
      if(changed) {
        setState(() {});
        widget.onSave(widget.block);
      }
    });
  }

  Widget buildSettingRow({ required String label, required TextEditingController controller,}) {
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

  Widget buildColorRow({ required String label }) {
    // Color display
    return Row(
      children: [
        const SizedBox(width: 6),
        SizedBox( width: 122, child: Text(label)),
        Wrap(
          children: 
            colors.map((color) {
            return GestureDetector(
              onTap: () { selectedColor = color; _onSettingChanged(); },
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
            buildColorRow( label: AppLocalizations.of(context)!.color),

            // 6 Text lines
            buildSettingRow(
              label: AppLocalizations.of(context)!.lessonName,
              controller: lessonNameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.className,
              controller: classNameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.schoolName,
              controller: schoolNameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.workplanFilename,
              controller: leftListFilenameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.suggestionsFilename,
              controller: rightListFilenameController,
            ),
            buildSettingRow(
              label: AppLocalizations.of(context)!.notesFilename,
              controller: notesFilenameController,
            ),

            //const SizedBox(height: 8),

            // Checkbox for notes setting
            Row(
              children: [
                const SizedBox(width: 122),
                Checkbox(
                  value: showNotesBeforeWorkplan,
                  onChanged: (value) { showNotesBeforeWorkplan = value ?? false; _onSettingChanged(); }
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