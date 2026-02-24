import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:teachers_timetable/models/print.dart';
import 'package:path/path.dart' as p;
import 'package:teachers_timetable/widgets/edit_checkbox_dialog.dart';
import 'package:teachers_timetable/widgets/edit_color_dialog.dart';
import 'package:teachers_timetable/widgets/edit_settings_dialog.dart';
import 'package:teachers_timetable/widgets/edit_text_dialog.dart';
import 'dart:convert';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/lesson_block.dart';
import '../models/export_import_files.dart';
import '../models/lesson_item.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';

class LessonDetailPage extends StatefulWidget {
  final LessonBlock block;
  final int row;
  final int col;
  final Function(LessonBlock) onSave;

  const LessonDetailPage({super.key, required this.block, required this.row, required this.col, required this.onSave});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> with WidgetsBindingObserver {
  late String dataPath;
  List<LessonItem> leftItems = <LessonItem>[];
  List<LessonItem> rightItems = <LessonItem>[];
  List<bool> leftExpanded = <bool>[];
  List<bool> rightExpanded = <bool>[];
  int? selectedLeftIndex;
  int? selectedRightIndex;
  int? selectedRightSubIndex;
  bool isLoading = false;
  bool isPreview = false;
  bool showNotesIsActive = false;
  bool hasNoteChanges = false;
  bool notesLoaded = false;
  bool listDataLoaded = false;
  quill.QuillController controllerQuill = quill.QuillController.basic();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadPrefsAndData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); 
    controllerQuill.dispose();
    super.dispose();
  }

  @override void didChangeAppLifecycleState(AppLifecycleState state) { 
    if (hasNoteChanges && (state == AppLifecycleState.detached || state == AppLifecycleState.inactive)) { 
      _saveNotesData();
    } 
  }

  Future<void> loadPrefsAndData() async {
    // get or create data path
    dataPath = await ExportImportFiles.GetPrivateDirectoryPath();
    
    if(widget.block.className.isEmpty && widget.block.schoolName.isEmpty && widget.block.lessonName.isEmpty) {
      _editBlockColor();
    }

    if(widget.block.showNotesBeforeWorkplan) { showNotesIsActive = true; _loadNotesData(); } 
    else { _loadWorkplanData(); }
  }

  String getFilePath(String fileName) {
    return p.join(dataPath, ExportImportFiles.GetSaveFilename(fileName));
  }

  String getDefaultLeftFilename() { 
    return '${widget.block.lessonName}_${widget.block.className}_${widget.block.schoolName}.json';
  }

  String getDefaultRightFilename() { 
    return '${widget.block.lessonName}.json';
  }

  String getDefaultNotesFilename() { 
    return 'notes_col_${widget.col}.json';
  }

  void _loadNotesData() {
    setState(() => isLoading = true);

    try {
      String filePath = widget.block.notesFilename.length == 0 ? getFilePath(getDefaultNotesFilename()) : getFilePath(widget.block.notesFilename + '.json');
      if (File(filePath).existsSync()) {
        final content = File(filePath).readAsStringSync();
        final jsonData = jsonDecode(content);
        final doc = quill.Document.fromJson(jsonData["document"]);
        controllerQuill = quill.QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
      } else {
        controllerQuill = quill.QuillController.basic();
      }
    } catch (e) {
        controllerQuill = quill.QuillController.basic();
      _showError(AppLocalizations.of(context)!.failedToLoadNotesData + ': $e');
    }

    // set listener to track changes for auto-saving when app is closed
    // the listener has to set AFTER loading the quill document, otherwise it would trigger on the old, not visible, document!
    controllerQuill.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        hasNoteChanges = true;
      }
    });

    hasNoteChanges = false;
    notesLoaded = true;
    setState(() => isLoading = false);
    // setState(() {});
  }

  void _emptyList(bool rightList, bool leftList) {
    setState(() {
      if (rightList) {
        rightItems.clear();
        rightExpanded.clear();
        selectedRightIndex = null;
        selectedRightSubIndex = null;
      }
      if (leftList) {
        leftItems.clear();
        leftExpanded.clear();
        selectedLeftIndex = null;
      }
    });
  }

  void _loadWorkplanData() {
    // load the right list data from file
    try {
      String filePath = widget.block.suggestionsFilename.length == 0 ? getFilePath(getDefaultRightFilename()) : getFilePath(widget.block.suggestionsFilename + '.json');
      if (File(filePath).existsSync()) {
        String json = File(filePath).readAsStringSync();
        List<dynamic> data = jsonDecode(json);
        setState(() {
          rightItems = List<LessonItem>.from(
            data.map((e) => LessonItem.fromJson(e))
          );
          rightExpanded = rightItems.map((_) => false).toList();
        });
      }
      else {  // empty list if no file exists
        _emptyList(true, false);
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToLoadRightData + ': $e');
      _emptyList(true, false);
    }

    // load the left list data from file
    try {
      String filePath = (widget.block.workplanFilename.length == 0 ? getFilePath(getDefaultLeftFilename()) : getFilePath(widget.block.workplanFilename)) + '.json';
      if (File(filePath).existsSync()) {
        String json = File(filePath).readAsStringSync();
        List<dynamic> data = jsonDecode(json);
        setState(() {
          leftItems = List<LessonItem>.from(
            data.map((e) => LessonItem.fromJson(e))
          );
          leftExpanded = leftItems.map((item) => !item.subitems.every((s) => s.status == '(F)')).toList();
        });
      }
      else {  // empty list if no file exists
        _emptyList(false, true);
      } 
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToLoadLeftData + ': $e');
      _emptyList(false, true);
    }

    listDataLoaded = true;
    setState(() {});
  }

  void _saveNotesData() {
    try {
      final filePath = widget.block.notesFilename.length == 0 ? getFilePath(getDefaultNotesFilename()) : getFilePath(widget.block.notesFilename + '.json');
      final jsonData = {"document": controllerQuill.document.toDelta().toJson()};
      final jsonString = jsonEncode(jsonData);
      File(filePath).writeAsStringSync(jsonString);
      hasNoteChanges = false;
      _showInfo(AppLocalizations.of(context)!.savedNotesData);
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToSaveNotesData + ': $e');
    }
  }

  Future<void> _printNotes() async {
    // Erstellt ein PDF-Dokument aus dem Quill-Inhalt
    try {
      final pw.Font fontRegular = pw.Font.ttf(await rootBundle.load('lib/assets/NotoSans_Regular.ttf')); 
      final pw.Font fontBold = pw.Font.ttf(await rootBundle.load('lib/assets/NotoSans_Bold.ttf'));
      final pw.Font fontItalic = pw.Font.ttf(await rootBundle.load('lib/assets/NotoSans_Italic.ttf'));

      final pw.ThemeData theme = pw.ThemeData.withFont( base: fontRegular, bold: fontBold, italic: fontItalic);

      final Delta delta = controllerQuill.document.toDelta();
      final converter = await PDFConverter(pageFormat: PDFPageFormat.a4, document: delta, themeData: theme, fallbacks: []);

      final doc = await converter.createDocument();

      if(doc != null) {
        final printDoc = await doc.save();
        if( await PrintPdf().PrintNotes(context, printDoc) == false) {
          _showError(AppLocalizations.of(context)!.printingFailed);
          return;
        }
        _showInfo(AppLocalizations.of(context)!.printingSuccess);
      }
    } catch (e) {
      _showError('Failed to load fonts: $e');
      return;
    }
  }

  void _saveRightData() {
    try {
      String filePath = widget.block.suggestionsFilename.length == 0 ? getFilePath(getDefaultRightFilename()) : getFilePath(widget.block.suggestionsFilename + '.json');
      String json = jsonEncode(rightItems.map((e) => e.toJson()).toList());
      File(filePath).writeAsStringSync(json);
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToSaveRightData + ': $e');
    }
  }

  void _saveLeftData() {
    try {
      String filePath = (widget.block.workplanFilename.length == 0 ? getFilePath(getDefaultLeftFilename()) : getFilePath(widget.block.workplanFilename)) + '.json';
      String json = jsonEncode(leftItems.map((e) => e.toJson()).toList());
      File(filePath).writeAsStringSync(json);
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToSaveLeftData + ': $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 4)));
  }

  void _editText(String currentText, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editText),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _switchListVisibility(bool leftList) {
    setState(() {
      if (leftList) {
        widget.block.hideLeftList = !widget.block.hideLeftList;
        if (!widget.block.hideLeftList && !listDataLoaded) { _loadWorkplanData(); }
      } else {
        widget.block.hideRightList = !widget.block.hideRightList;
        if (!widget.block.hideRightList && !listDataLoaded) { _loadWorkplanData(); }
      }
    });
    widget.onSave(widget.block);
  }

  void _switchNotesVisibility() {
    showNotesIsActive = !showNotesIsActive;
    if(showNotesIsActive && !notesLoaded) { _loadNotesData(); } 
    if(!showNotesIsActive && hasNoteChanges) { _saveNotesData(); }
    if(!showNotesIsActive && !listDataLoaded) { _loadWorkplanData(); }
    setState(() {});
  }

  void _editSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSettingsDialog(
          block: widget.block,
          col: widget.col,
          onSave: (updatedBlock) {
            bool changed = false;
            if(widget.block.color != updatedBlock.color) { changed = true; widget.block.color = updatedBlock.color; }
            if(widget.block.lessonName != updatedBlock.lessonName) { changed = true; widget.block.lessonName = updatedBlock.lessonName; }
            if(widget.block.className != updatedBlock.className) { changed = true; widget.block.className = updatedBlock.className; }
            if(widget.block.schoolName != updatedBlock.schoolName) { changed = true; widget.block.schoolName = updatedBlock.schoolName; }
            if(widget.block.workplanFilename != updatedBlock.workplanFilename) { changed = true; widget.block.workplanFilename = updatedBlock.workplanFilename; }
            if(widget.block.suggestionsFilename != updatedBlock.suggestionsFilename) { changed = true; widget.block.suggestionsFilename = updatedBlock.suggestionsFilename; }
            if(widget.block.notesFilename != updatedBlock.notesFilename) { changed = true; widget.block.notesFilename = updatedBlock.notesFilename; }
            if(widget.block.showNotesBeforeWorkplan != updatedBlock.showNotesBeforeWorkplan) { changed = true; widget.block.showNotesBeforeWorkplan = updatedBlock.showNotesBeforeWorkplan; }
            if(changed) {
              setState(() {});
              widget.onSave(widget.block);
            }
          },
        ),
      ),
    );
  }


  void _editBlockText(String tag) {
    final dialogTitle = AppLocalizations.of(context)!.editText; 
    final currentTextValue;
    final dialogText;
    switch(tag) {
      case 'lessonName':
        currentTextValue = widget.block.lessonName;
        dialogText = AppLocalizations.of(context)!.lessonName;
        break;
      case 'className':
        currentTextValue = widget.block.className;
        dialogText = AppLocalizations.of(context)!.className;
        break;
      case 'schoolName':
        currentTextValue = widget.block.schoolName;
        dialogText = AppLocalizations.of(context)!.schoolNameLabel;
        break;
      case 'workplanFilename':
        currentTextValue = widget.block.workplanFilename.length == 0 ? ExportImportFiles.GetSaveFilename(getDefaultLeftFilename()) : widget.block.workplanFilename;
        dialogText = AppLocalizations.of(context)!.workplanFilename;
        break;
      case 'suggestionsFilename':
        currentTextValue = widget.block.suggestionsFilename.length == 0 ? ExportImportFiles.GetSaveFilename(getDefaultRightFilename()) : widget.block.suggestionsFilename;
        dialogText = AppLocalizations.of(context)!.suggestionsFilename;
        break;
      case 'notesFilename':
        currentTextValue = widget.block.notesFilename.length == 0 ? ExportImportFiles.GetSaveFilename(getDefaultNotesFilename()) : widget.block.notesFilename;
        dialogText = AppLocalizations.of(context)!.notesFilename;
        break;
      default:
        _showError('Invalid Tag: ' + tag);
        return; // invalid tag
    }
    showDialog(
      context: context,
      builder: (context) => EditTextDialog(
        dialogTitle: dialogTitle,
        dialogText: dialogText,
        currentTextValue: currentTextValue,

        onSave: (currentTextValue) {
          switch(tag) {
            case 'lessonName':
              if(widget.block.lessonName != currentTextValue) { 
                widget.block.lessonName = currentTextValue;
                widget.onSave(widget.block);
              }
              break;
            case 'className':
              if(widget.block.className != currentTextValue) { 
                widget.block.className = currentTextValue;
                widget.onSave(widget.block);
              }
              break;
            case 'schoolName':
              if(widget.block.schoolName != currentTextValue) {
                widget.block.schoolName = currentTextValue;
                widget.onSave(widget.block);
              }
              break;
              case 'workplanFilename':
              if(widget.block.workplanFilename != currentTextValue) {
                widget.block.workplanFilename = (currentTextValue == getDefaultLeftFilename() || currentTextValue.length == 0) ? '' : currentTextValue;
                widget.onSave(widget.block);
              }
              break;
              case 'suggestionsFilename':
              if(widget.block.suggestionsFilename != currentTextValue) {
                widget.block.suggestionsFilename = (currentTextValue == getDefaultRightFilename() || currentTextValue.length == 0) ? '' : currentTextValue;
                widget.onSave(widget.block);
              }
              break;
              case 'notesFilename':
              if(widget.block.notesFilename != currentTextValue) {
                widget.block.notesFilename = (currentTextValue == getDefaultNotesFilename() || currentTextValue.length == 0) ? '' : currentTextValue;
                widget.onSave(widget.block);
              }
              break;
          }
        }
      ),
    );

    setState(() {});
            
    // reload data with new names, if data are already visible
    if (listDataLoaded) { _loadWorkplanData(); }
    if (notesLoaded) { _loadNotesData(); }
  }

  void _editBlockColor() {
    showDialog(
      context: context,
      builder: (context) => EditColorDialog(
        block: widget.block,
        onSave: (updatedBlock) {
          // Reload if names changed
          if( widget.block.color != updatedBlock.color) {
            setState(() {
              widget.block.color = updatedBlock.color;
            });
            widget.onSave(widget.block);
          }
        },
      ),
    );
  }

  void _editCheckbox(String tag) {
    showDialog(
      context: context,
      builder: (context) => EditCheckboxDialog(
        checkValue: widget.block.showNotesBeforeWorkplan, 
        dialogTitle: AppLocalizations.of(context)!.editShowNotesBeforeWorkplan, 
        dialogText: AppLocalizations.of(context)!.showNotesBeforeWorkplan,

        onSave: (checkValue) {
          // Reload if names changed
          if( widget.block.showNotesBeforeWorkplan != checkValue) { 
            setState(() {
              widget.block.showNotesBeforeWorkplan = checkValue;
              widget.onSave(widget.block);
            });

            
            // reload data with new names, if data are already visible
            if (listDataLoaded) { _loadWorkplanData(); }
            if (notesLoaded) { _loadNotesData(); }
          }
        }, 
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // page may be closed
      onPopInvokedWithResult: (didPop, result) async {
        if(hasNoteChanges) { _saveNotesData(); }
      },
      child: Scaffold(
      appBar: AppBar(
        title: showNotesIsActive ? 
          Text(AppLocalizations.of(context)!.notesTitle + ':   ' + widget.block.lessonName + ' - ' + widget.block.className + ' - ' + widget.block.schoolName) : 
          Text(AppLocalizations.of(context)!.workplan + ':   ' + widget.block.lessonName + ' - ' + widget.block.className + ' - ' + widget.block.schoolName),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 80,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text(
                  AppLocalizations.of(context)!.menu,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: widget.block.hideLeftList ? const Icon(Icons.switch_left) : const Icon(Icons.switch_right),
              title: Text((widget.block.hideLeftList ? AppLocalizations.of(context)!.show : AppLocalizations.of(context)!.hide) + ' ' + AppLocalizations.of(context)!.leftListShort),
              onTap: () {
                Navigator.pop(context);
                _switchListVisibility(true);
              },
            ),
            ListTile(
              leading: widget.block.hideRightList ? const Icon(Icons.switch_right) : const Icon(Icons.switch_left),
              title: Text((widget.block.hideRightList ? AppLocalizations.of(context)!.show : AppLocalizations.of(context)!.hide) + ' ' + AppLocalizations.of(context)!.rightListShort),
              onTap: () {
                Navigator.pop(context);
                _switchListVisibility(false);
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.print),
              title: Text(showNotesIsActive ? AppLocalizations.of(context)!.printNotes : AppLocalizations.of(context)!.printWorkplan),
              onTap: () {
                Navigator.pop(context);
                if(showNotesIsActive)
                  _printNotes();
                else
                  PrintPdf().PrintBlockDetails(context, widget.block);
              },
            ),

            const Divider(),
            ListTile(
              leading: showNotesIsActive ? const Icon(Icons.work) : const Icon(Icons.notes),
              title: Text(showNotesIsActive ? AppLocalizations.of(context)!.showWorkplan : AppLocalizations.of(context)!.showNotes),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _switchNotesVisibility();
                });
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editBlockColor),
              onTap: () {
                Navigator.pop(context);
                _editBlockColor();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editLessonName),
              onTap: () {
                Navigator.pop(context);
                _editBlockText('lessonName');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editClassName),
              onTap: () {
                Navigator.pop(context);
                _editBlockText('className');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editSchoolName),
              onTap: () {
                Navigator.pop(context);
                _editBlockText('schoolName');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editWorkplanFilename),
              onTap: () {
                Navigator.pop(context);
                _editBlockText('workplanFilename');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editSuggestionsFilename),
              onTap: () {
                Navigator.pop(context);
                _editBlockText('suggestionsFilename');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editNotesFilename),
              onTap: () {
                Navigator.pop(context);
                _editBlockText('notesFilename');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editShowNotesBeforeWorkplan),
              onTap: () {
                Navigator.pop(context);
                _editCheckbox('showNotesBeforeWorkplan');
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.editBlock),
              onTap: () {
                Navigator.pop(context);
                _editSettings();
              },
            ),

            SizedBox(height: 80,) // on some devices the last menu line is otherwise not touchable
          ],
        ),
      ),
      
      body: Column(
        children: [
            // Button row
            Row(
              children: [

                //if(showNotesIsActive)
                  //ElevatedButton(
                    //onPressed: () {
                      //_saveNotesData();
                    //},
                    //child: Text(AppLocalizations.of(context)!.saveNotesButton),
                  //),

                // Help Text, if booth lists are hidden
                if(!showNotesIsActive && widget.block.hideRightList && widget.block.hideLeftList)
                  Text('     ' + AppLocalizations.of(context)!.bothListsHidden, style: TextStyle(color: Colors.red, fontSize: 20), textAlign: TextAlign.center),

                // Left list buttons Add Item, Add Subitem
                if(!widget.block.hideLeftList && !showNotesIsActive)
                  ElevatedButton(
                    onPressed: () {
                      final newItemText = AppLocalizations.of(context)!.newItem;
                      setState(() {
                        leftItems.add(LessonItem(text: newItemText));
                        leftExpanded.add(true);
                      });
                      _saveLeftData();
                    },
                    child: Text(AppLocalizations.of(context)!.addItemLeft),
                  ),
                if(!widget.block.hideLeftList && !showNotesIsActive)
                  ElevatedButton(
                    onPressed: selectedLeftIndex != null ? () {
                      final newSubitemText = AppLocalizations.of(context)!.newSubitem;
                      setState(() {
                        leftItems[selectedLeftIndex!].subitems.add(LessonItem(text: newSubitemText));
                      });
                      _saveLeftData();
                    } : null,
                    child: Text(AppLocalizations.of(context)!.addSubitemLeft),
                  ),
                if(!widget.block.hideLeftList && !showNotesIsActive)
                  const Spacer(),

                // Copy from right list buttons
                if(!widget.block.hideRightList && !showNotesIsActive)
                  ElevatedButton(
                    onPressed: selectedRightIndex != null ? () {
                      var item = rightItems[selectedRightIndex!];
                      var newItem = LessonItem(text: item.text, subitems: item.subitems.map((s) => LessonItem(text: s.text)).toList(), status: '(P)');
                      setState(() {
                        leftItems.add(newItem);
                        leftExpanded.add(true);
                      });
                      _saveLeftData();
                    } : null,
                    child: Text(AppLocalizations.of(context)!.copyItemToLeft),
                  ),
                if(!widget.block.hideRightList && !widget.block.hideLeftList && !showNotesIsActive)
                  ElevatedButton(
                    onPressed: selectedRightIndex != null && selectedRightSubIndex != null && selectedLeftIndex != null ? () {
                      final sub = rightItems[selectedRightIndex!].subitems[selectedRightSubIndex!];
                        setState(() {
                          leftItems[selectedLeftIndex!].subitems.add(LessonItem(text: sub.text));
                        });
                        _saveLeftData();
                      } : null,
                    child: Text(AppLocalizations.of(context)!.copySubitemToLeft),
                  ),
                if(!widget.block.hideRightList && !showNotesIsActive)
                  const Spacer(),

                // Right list buttons Add Item, Add Subitem
                if(!widget.block.hideRightList && !showNotesIsActive)
                  ElevatedButton(
                    onPressed: () {
                      final newItemText = AppLocalizations.of(context)!.newItem;
                      setState(() {
                        rightItems.add(LessonItem(text: newItemText));
                        rightExpanded.add(true);
                      });
                      _saveRightData();
                    },
                    child: Text(AppLocalizations.of(context)!.addItemRight),
                  ),
                if(!widget.block.hideRightList && !showNotesIsActive)
                  ElevatedButton(
                    onPressed: selectedRightIndex != null ? () {
                      final newSubitemText = AppLocalizations.of(context)!.newSubitem;
                      setState(() {
                        rightItems[selectedRightIndex!].subitems.add(LessonItem(text: newSubitemText));
                      });
                      _saveRightData();
                    } : null,
                    child: Text(AppLocalizations.of(context)!.addSubitemRight),
                  ),
                
              ],
            ),

          Expanded(
            child: Row(
              children: [
                if(!widget.block.hideLeftList && !showNotesIsActive) 
                  Expanded(
                    child: Column(
                      children: [
                        Text(' ', style: const TextStyle(fontSize: 12)),
                        Text(AppLocalizations.of(context)!.leftList, style: const TextStyle(height: 1.5, fontSize: 20, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            itemCount: leftItems.length,
                            itemBuilder: (context, index) {
                              var item = leftItems[index];
                              return ExpansionTile(
                                initiallyExpanded: leftExpanded[index],
                                backgroundColor: selectedLeftIndex == index ? const Color.fromARGB(255, 136, 134, 121) : null,
                                collapsedBackgroundColor: selectedLeftIndex == index ? const Color.fromARGB(255, 136, 134, 121) : null,
                                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                childrenPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedLeftIndex = index;
                                      // selectedRightIndex = null;
                                      // selectedRightSubIndex = null;
                                    });
                                  },
                                  onDoubleTap: () => _editText(item.text, (newText) {
                                    setState(() => item.text = newText);
                                    _saveLeftData();
                                  }),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item.text, style: const TextStyle(height: 1.0, fontSize: 16, fontWeight: FontWeight.bold))),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 22, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            leftItems.removeAt(index);
                                            leftExpanded.removeAt(index);
                                            if (selectedLeftIndex == index) selectedLeftIndex = null;
                                          });
                                          _saveLeftData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_upward, size: 22),
                                        onPressed: index > 0 ? () {
                                          setState(() {
                                            var temp = leftItems[index];
                                            leftItems[index] = leftItems[index - 1];
                                            leftItems[index - 1] = temp;
                                            var tempExp = leftExpanded[index];
                                            leftExpanded[index] = leftExpanded[index - 1];
                                            leftExpanded[index - 1] = tempExp;
                                            selectedLeftIndex = index - 1;
                                          });
                                          _saveLeftData();
                                        } : null,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_downward, size: 22),
                                        onPressed: index < leftItems.length - 1 ? () {
                                          setState(() {
                                            var temp = leftItems[index];
                                            leftItems[index] = leftItems[index + 1];
                                            leftItems[index + 1] = temp;
                                            var tempExp = leftExpanded[index];
                                            leftExpanded[index] = leftExpanded[index + 1];
                                            leftExpanded[index + 1] = tempExp;
                                            selectedLeftIndex = index + 1;
                                          });
                                          _saveLeftData();
                                        } : null,
                                      ),
                                    ],
                                  ),
                                ),
                                children: item.subitems.map((sub) => ListTile(
                                  tileColor: null,  // selectedLeftIndex == index ? Color.fromARGB(255, 136, 134, 121) : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                  visualDensity: VisualDensity(vertical: -4),
                                  title: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.circle, size: 16, color: sub.status == '(F)' ? Colors.green : Colors.yellow),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),  // reduziert die Mindestgröße
                                        splashRadius: 48,
                                        onPressed: () {
                                          setState(() {
                                            if (sub.status == '(P)') {
                                              sub.status = '(W)';
                                            } else if (sub.status == '(W)') {
                                              sub.status = '(F)';
                                            } else {
                                              sub.status = '(P)';
                                            }
                                          });
                                          _saveLeftData();
                                        },
                                      ),
                                      
                                      Text(sub.status ?? '(P)', style: const TextStyle(height: 1.0, fontSize: 14)),
                                      const SizedBox(width: 8, height: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onDoubleTap: () => _editText(sub.text, (newText) {
                                            setState(() => sub.text = newText);
                                            _saveLeftData();
                                          }),
                                          child: Text(sub.text, style: const TextStyle(height: 1.0, fontSize: 16)),
                                        ),
                                      ),
                                    ],
                                  ),

                                  onTap: () {
                                    setState(() {
                                    selectedLeftIndex = index;
                                    // selectedRightIndex = null;
                                    // selectedRightSubIndex = null;
                                    });
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.red),
                                        onPressed: () {
                                          int subIndex = item.subitems.indexOf(sub);
                                          setState(() {
                                            item.subitems.removeAt(subIndex);
                                          });
                                          _saveLeftData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_upward, size: 20),
                                        onPressed: () {
                                          int subIndex = item.subitems.indexOf(sub);
                                          if (subIndex > 0) {
                                            setState(() {
                                              var temp = item.subitems[subIndex];
                                              item.subitems[subIndex] = item.subitems[subIndex - 1];
                                              item.subitems[subIndex - 1] = temp;
                                            });
                                            _saveLeftData();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_downward, size: 20),
                                        onPressed: () {
                                          int subIndex = item.subitems.indexOf(sub);
                                          if (subIndex < item.subitems.length - 1) {
                                            setState(() {
                                              var temp = item.subitems[subIndex];
                                              item.subitems[subIndex] = item.subitems[subIndex + 1];
                                              item.subitems[subIndex + 1] = temp;
                                            });
                                            _saveLeftData();
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 31, height: 8), 
                                    ],
                                  ),
                                )).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                
                
                if(!widget.block.hideRightList && !showNotesIsActive)
                  Expanded(
                    child: Column(
                      children: [
                        Text(' ', style: const TextStyle(fontSize: 12)),
                        Text(AppLocalizations.of(context)!.rightList, style: const TextStyle(height: 1.5, fontSize: 20, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rightItems.length,
                            itemBuilder: (context, index) {
                              var item = rightItems[index];
                              return ExpansionTile(
                                initiallyExpanded: rightExpanded[index],
                                backgroundColor: selectedRightIndex == index ? const Color.fromARGB(255, 136, 134, 121) : null,
                                collapsedBackgroundColor: selectedRightIndex == index ? const Color.fromARGB(255, 136, 134, 121) : null,
                                tilePadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
                                childrenPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRightIndex = index;
                                      selectedRightSubIndex = null;
                                      // selectedLeftIndex = null;
                                    });
                                  },
                                  onDoubleTap: () => _editText(item.text, (newText) {
                                    setState(() => item.text = newText);
                                    _saveRightData();
                                  }),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item.text, style: const TextStyle(height: 1.0, fontSize: 16, fontWeight: FontWeight.bold))),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 22, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            rightItems.removeAt(index);
                                            rightExpanded.removeAt(index);
                                            if (selectedRightIndex == index) selectedRightIndex = null;
                                          });
                                          _saveRightData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_upward, size: 22),
                                        onPressed: index > 0 ? () {
                                          setState(() {
                                            var temp = rightItems[index];
                                            rightItems[index] = rightItems[index - 1];
                                            rightItems[index - 1] = temp;
                                            var tempExp = rightExpanded[index];
                                            rightExpanded[index] = rightExpanded[index - 1];
                                            rightExpanded[index - 1] = tempExp;
                                            selectedRightIndex = index - 1;
                                          });
                                          _saveRightData();
                                        } : null,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_downward, size: 22),
                                        onPressed: index < rightItems.length - 1 ? () {
                                          setState(() {
                                            var temp = rightItems[index];
                                            rightItems[index] = rightItems[index + 1];
                                            rightItems[index + 1] = temp;
                                            var tempExp = rightExpanded[index];
                                            rightExpanded[index] = rightExpanded[index + 1];
                                            rightExpanded[index + 1] = tempExp;
                                            selectedRightIndex = index + 1;
                                          });
                                          _saveRightData();
                                        } : null,
                                      ),
                                    ],
                                  ),
                                ),
                                children: item.subitems.map((sub) => ListTile(
                                  tileColor: selectedRightIndex == index && selectedRightSubIndex == item.subitems.indexOf(sub) ? Color.fromARGB(255, 136, 134, 121) : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 70, vertical: 0),
                                  visualDensity: VisualDensity(vertical: -4),
                                  title: GestureDetector(
                                    onDoubleTap: () => _editText(sub.text, (newText) {
                                      setState(() => sub.text = newText);
                                      _saveRightData();
                                    }),
                                    child: Text(sub.text, style: const TextStyle(height: 1.0, fontSize: 16)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedRightIndex = index;
                                      selectedRightSubIndex = item.subitems.indexOf(sub);
                                      // selectedLeftIndex = null;
                                    });
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.red),
                                        onPressed: () {
                                          int subIndex = item.subitems.indexOf(sub);
                                          setState(() {
                                            item.subitems.removeAt(subIndex);
                                          });
                                          _saveRightData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_upward, size: 20),
                                        onPressed: () {
                                          int subIndex = item.subitems.indexOf(sub);
                                          if (subIndex > 0) {
                                            setState(() {
                                              var temp = item.subitems[subIndex];
                                              item.subitems[subIndex] = item.subitems[subIndex - 1];
                                              item.subitems[subIndex - 1] = temp;
                                            });
                                            _saveRightData();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_downward, size: 20),
                                        onPressed: () {
                                          int subIndex = item.subitems.indexOf(sub);
                                          if (subIndex < item.subitems.length - 1) {
                                            setState(() {
                                              var temp = item.subitems[subIndex];
                                              item.subitems[subIndex] = item.subitems[subIndex + 1];
                                              item.subitems[subIndex + 1] = temp;
                                            });
                                            _saveRightData();
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 20, height: 8), 
                                    ],
                                  ),
                                )).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                if(showNotesIsActive)
                Expanded(
                  child: Column(
                    children: [
                      // Die Toolbar mit allen Buttons
                      SizedBox( width: double.infinity, // to fill the whole line and make the editor show up in the next line
                        child: quill.QuillSimpleToolbar(
                          controller: controllerQuill,
                          config: const quill.QuillSimpleToolbarConfig( multiRowsDisplay: true, showDividers: false, toolbarRunSpacing: 2, showSmallButton: false,
                                                                        showUndo: true, showRedo: true, showFontFamily: false, showFontSize: true,
                                                                        showBoldButton: true, showItalicButton: true, showUnderLineButton: true, showStrikeThrough: true,
                                                                        showSubscript: false, showSuperscript: false, showInlineCode: false,
                                                                        showColorButton: true, showBackgroundColorButton: true, showClearFormat: false,
                                                                        showAlignmentButtons: true, showLeftAlignment: false, showCenterAlignment: true, 
                                                                        showRightAlignment: true, showJustifyAlignment: true,
                                                                        showHeaderStyle: false, showListNumbers: true, showListBullets: true, showListCheck: true, 
                                                                        showCodeBlock: false, showQuote: false, showIndent: true,
                                                                        showLink: true, showSearchButton: true,
                                                                        showClipboardCopy: false, showClipboardCut: false, showClipboardPaste: false,
                                                                        showLineHeightButton: false, showDirection: false )
                        ),
                      ),
                    // Der eigentliche Editor
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: quill.QuillEditor.basic(
                          controller: controllerQuill,
                          config: const quill.QuillEditorConfig( placeholder: 'Schreibe etwas...'),
                        ),
                      ),
                    )
                  ],
                )),
              ]
          ),
          )
        ]
      )
    )
   );
  }
}