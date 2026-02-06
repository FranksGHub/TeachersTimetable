import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:teachers_timetable/models/print.dart';
import '../models/export_import_files.dart';
import '../models/lesson_block.dart';
import '../models/lesson_item.dart';
import '../l10n/app_localizations.dart';
import 'edit_block_dialog.dart';

class LessonDetailPage extends StatefulWidget {
  final LessonBlock block;
  final int row;
  final int col;
  final Function(LessonBlock) onSave;

  const LessonDetailPage({super.key, required this.block, required this.row, required this.col, required this.onSave});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late SharedPreferences prefs;
  late String dataPath;
  List<LessonItem> leftItems = <LessonItem>[];
  List<LessonItem> rightItems = <LessonItem>[];
  List<bool> leftExpanded = <bool>[];
  List<bool> rightExpanded = <bool>[];
  int? selectedLeftIndex;
  int? selectedRightIndex;
  int? selectedRightSubIndex;

  @override
  void initState() {
    super.initState();
    loadPrefsAndData();
  }

  Future<void> loadPrefsAndData() async {
    prefs = await SharedPreferences.getInstance();
    // get or create data path
    dataPath = await ExportImportFiles.GetPrivateDirectoryPath();
    
    if(widget.block.className.isEmpty && widget.block.schoolName.isEmpty && widget.block.lessonName.isEmpty) {
      _editBlock();
    }

    if (!widget.block.hideLeftList) { loadLeftData(); }
    if (!widget.block.hideRightList) { loadRightData(); }
  }

  String getFilePath(String fileName) {
    return p.join(dataPath, ExportImportFiles.GetSaveFilename(fileName));
  }

  void loadRightData() {
    try {
      String filePath = getFilePath('${widget.block.lessonName}.json');
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
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToLoadRightData + ': $e');
    }
  }

  void loadLeftData() {
    try {
      String filePath = getFilePath('${widget.block.lessonName}_${widget.block.className}_${widget.block.schoolName}.json');
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
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToLoadLeftData + ': $e');
    }
  }

  void saveRightData() {
    try {
      String filePath = getFilePath('${widget.block.lessonName}.json');
      String json = jsonEncode(rightItems.map((e) => e.toJson()).toList());
      File(filePath).writeAsStringSync(json);
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToSaveRightData + ': $e');
    }
  }

  void saveLeftData() {
    try {
      String filePath = getFilePath('${widget.block.lessonName}_${widget.block.className}_${widget.block.schoolName}.json');
      String json = jsonEncode(leftItems.map((e) => e.toJson()).toList());
      File(filePath).writeAsStringSync(json);
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToSaveLeftData + ': $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
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
        if (widget.block.hideLeftList) {
          leftItems.clear();
          leftExpanded.clear();
          selectedLeftIndex = null;
        } else {
          loadLeftData();
        }
      } else {
        widget.block.hideRightList = !widget.block.hideRightList;
        if (widget.block.hideRightList) {
          rightItems.clear();
          rightExpanded.clear();
          selectedRightIndex = null;
          selectedRightSubIndex = null;
        } else {
          loadRightData();
        }
      }
    });
    widget.onSave(widget.block);
  }

  void _editBlock() {
    showDialog(
      context: context,
      builder: (context) => EditBlockDialog(
        block: widget.block,
        onSave: (updatedBlock) {
          widget.onSave(updatedBlock);
          // Reload if names changed
          if( widget.block.lessonName != updatedBlock.lessonName || 
              widget.block.className != updatedBlock.className || 
              widget.block.schoolName != updatedBlock.schoolName) {
            setState(() {
              widget.block.lessonName = updatedBlock.lessonName;
              widget.block.className = updatedBlock.className;
              widget.block.schoolName = updatedBlock.schoolName;              
            });
            if (!widget.block.hideLeftList) { loadLeftData(); }
            if (!widget.block.hideRightList) { loadRightData(); }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workplan + ':   ' + widget.block.lessonName + ' - ' + widget.block.className + ' - ' + widget.block.schoolName),
        actions: [
          IconButton(
            icon: widget.block.hideLeftList ? const Icon(Icons.switch_left) : const Icon(Icons.switch_right),
            onPressed: () {_switchListVisibility(true);},
          ),
          IconButton(
            icon: widget.block.hideRightList ? const Icon(Icons.switch_right) : const Icon(Icons.switch_left),
            onPressed: () {_switchListVisibility(false);},
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () { PrintPdf().PrintBlockDetails(context, widget.block); },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _editBlock,
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [

              // Help Text, if booth lists are hidden
              if(widget.block.hideRightList && widget.block.hideLeftList)
                Text('     ' + AppLocalizations.of(context)!.bothListsHidden, style: TextStyle(color: Colors.red, fontSize: 20), textAlign: TextAlign.center),

              // Left list buttons Add Item, Add Subitem
              if(!widget.block.hideLeftList)
                ElevatedButton(
                  onPressed: () {
                    final newItemText = AppLocalizations.of(context)!.newItem;
                    setState(() {
                      leftItems.add(LessonItem(text: newItemText));
                      leftExpanded.add(true);
                    });
                    saveLeftData();
                  },
                  child: Text(AppLocalizations.of(context)!.addItemLeft),
                ),
              if(!widget.block.hideLeftList)
                ElevatedButton(
                  onPressed: selectedLeftIndex != null ? () {
                    final newSubitemText = AppLocalizations.of(context)!.newSubitem;
                    setState(() {
                      leftItems[selectedLeftIndex!].subitems.add(LessonItem(text: newSubitemText));
                    });
                    saveLeftData();
                  } : null,
                  child: Text(AppLocalizations.of(context)!.addSubitemLeft),
                ),
              if(!widget.block.hideLeftList)
                const Spacer(),

              // Copy from right list buttons
              if(!widget.block.hideRightList && !widget.block.hideLeftList)
                ElevatedButton(
                  onPressed: selectedRightIndex != null ? () {
                    var item = rightItems[selectedRightIndex!];
                    var newItem = LessonItem(text: item.text, subitems: item.subitems.map((s) => LessonItem(text: s.text)).toList(), status: '(P)');
                    setState(() {
                      leftItems.add(newItem);
                      leftExpanded.add(true);
                    });
                    saveLeftData();
                  } : null,
                  child: Text(AppLocalizations.of(context)!.copyItemToLeft),
                ),
              if(!widget.block.hideRightList && !widget.block.hideLeftList)
                ElevatedButton(
                  onPressed: selectedRightIndex != null && selectedRightSubIndex != null && selectedLeftIndex != null ? () {
                    final sub = rightItems[selectedRightIndex!].subitems[selectedRightSubIndex!];
                      setState(() {
                        leftItems[selectedLeftIndex!].subitems.add(LessonItem(text: sub.text));
                      });
                      saveLeftData();
                    } : null,
                  child: Text(AppLocalizations.of(context)!.copySubitemToLeft),
                ),
              if(!widget.block.hideRightList && !widget.block.hideLeftList)
                const Spacer(),

              // Right list buttons Add Item, Add Subitem
              if(!widget.block.hideRightList)
                ElevatedButton(
                  onPressed: () {
                    final newItemText = AppLocalizations.of(context)!.newItem;
                    setState(() {
                      rightItems.add(LessonItem(text: newItemText));
                      rightExpanded.add(true);
                    });
                    saveRightData();
                  },
                  child: Text(AppLocalizations.of(context)!.addItemRight),
                ),
              if(!widget.block.hideRightList)
                ElevatedButton(
                  onPressed: selectedRightIndex != null ? () {
                    final newSubitemText = AppLocalizations.of(context)!.newSubitem;
                    setState(() {
                      rightItems[selectedRightIndex!].subitems.add(LessonItem(text: newSubitemText));
                    });
                    saveRightData();
                  } : null,
                  child: Text(AppLocalizations.of(context)!.addSubitemRight),
                ),

            ],
          ),
          Expanded(
            child: Row(
              children: [
                if(!widget.block.hideLeftList) 
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
                                    saveLeftData();
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
                                          saveLeftData();
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
                                          saveLeftData();
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
                                          saveLeftData();
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
                                          saveLeftData();
                                        },
                                      ),
                                      
                                      Text(sub.status ?? '(P)', style: const TextStyle(height: 1.0, fontSize: 14)),
                                      const SizedBox(width: 8, height: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onDoubleTap: () => _editText(sub.text, (newText) {
                                            setState(() => sub.text = newText);
                                            saveLeftData();
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
                                          saveLeftData();
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
                                            saveLeftData();
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
                                            saveLeftData();
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
                
                
                if(!widget.block.hideRightList)
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
                                    saveRightData();
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
                                          saveRightData();
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
                                          saveRightData();
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
                                          saveRightData();
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
                                      saveRightData();
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
                                          saveRightData();
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
                                            saveRightData();
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
                                            saveRightData();
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

              ],
            ),
          ),
        ],
      ),
    );
  }
}