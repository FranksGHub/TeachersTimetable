import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
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
    // Use app documents directory instead of user-selected path
    final directory = await getApplicationDocumentsDirectory();
    dataPath = directory.path + '/Timetable';
    
    // Create the directory if it doesn't exist
    final timetableDir = Directory(dataPath);
    if (!await timetableDir.exists()) {
      await timetableDir.create(recursive: true);
    }
    
    loadRightData();
    loadLeftData();
  }

  void loadRightData() {
    try {
      String fileName = '${widget.block.lessonName}.json';
      fileName = fileName.replaceAll(RegExp(r'[\\/:*?" <>|]'), '_');
      String filePath = '$dataPath/$fileName';
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
      _showError('Failed to load right data: $e');
    }
  }

  void loadLeftData() {
    try {
      String fileName = '${widget.block.lessonName}${widget.block.className}${widget.block.schoolName}.json';
      fileName = fileName.replaceAll(RegExp(r'[\\/:*?" <>|]'), '_');
      String filePath = '$dataPath/$fileName';
      if (File(filePath).existsSync()) {
        String json = File(filePath).readAsStringSync();
        List<dynamic> data = jsonDecode(json);
        setState(() {
          leftItems = List<LessonItem>.from(
            data.map((e) => LessonItem.fromJson(e))
          );
          leftExpanded = leftItems.map((item) => !item.subitems.every((s) => s.status == 'F')).toList();
        });
      }
    } catch (e) {
      _showError('Failed to load left data: $e');
    }
  }

  void saveRightData() {
    try {
      String fileName = '${widget.block.lessonName}.json';
      fileName = fileName.replaceAll(RegExp(r'[\\/:*?" <>|]'), '_');
      String filePath = '$dataPath/$fileName';
      String json = jsonEncode(rightItems.map((e) => e.toJson()).toList());
      File(filePath).writeAsStringSync(json);
    } catch (e) {
      _showError('Failed to save right data: $e');
    }
  }

  void saveLeftData() {
    try {
      String fileName = '${widget.block.lessonName}${widget.block.className}${widget.block.schoolName}.json';
      fileName = fileName.replaceAll(RegExp(r'[\\/:*?" <>|]'), '_');
      String filePath = '$dataPath/$fileName';
      String json = jsonEncode(leftItems.map((e) => e.toJson()).toList());
      File(filePath).writeAsStringSync(json);
    } catch (e) {
      _showError('Failed to save left data: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
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

  void _editBlock() {
    showDialog(
      context: context,
      builder: (context) => EditBlockDialog(
        block: widget.block,
        onSave: (updatedBlock) {
          widget.onSave(updatedBlock);
          // Reload if names changed
          loadRightData();
          loadLeftData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.block.lessonName + ' - ' + widget.block.className + ' - ' + widget.block.schoolName),
        actions: [
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
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (selectedRightIndex != null && selectedRightSubIndex == null) {
                    var item = rightItems[selectedRightIndex!];
                    var newItem = LessonItem(
                      text: item.text,
                      subitems: item.subitems.map((s) => LessonItem(text: s.text)).toList(),
                      status: 'P',
                    );
                    setState(() {
                      if (selectedLeftIndex != null) {
                        leftItems.insert(selectedLeftIndex!, newItem);
                        leftExpanded.insert(selectedLeftIndex!, true);
                      } else {
                        leftItems.add(newItem);
                        leftExpanded.add(true);
                      }
                    });
                    saveLeftData();
                  }
                },
                child: Text(AppLocalizations.of(context)!.copyItemToLeft),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedRightIndex != null && selectedRightSubIndex != null && selectedLeftIndex != null) {
                    var sub = rightItems[selectedRightIndex!].subitems[selectedRightSubIndex!];
                    setState(() {
                      leftItems[selectedLeftIndex!].subitems.add(LessonItem(text: sub.text));
                    });
                    saveLeftData();
                  }
                },
                child: Text(AppLocalizations.of(context)!.copySubitemToLeft),
              ),
              const Spacer(),
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
                Expanded(
                  child: Column(
                    children: [
                      Text(' ', style: const TextStyle(fontSize: 12)),
                      Text(AppLocalizations.of(context)!.leftList, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: leftItems.length,
                          itemBuilder: (context, index) {
                            var item = leftItems[index];
                            return ExpansionTile(
                              initiallyExpanded: leftExpanded[index],
                              backgroundColor: selectedLeftIndex == index ? const Color.fromARGB(255, 136, 134, 121) : null,
                              title: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedLeftIndex = index;
                                    selectedRightIndex = null;
                                    selectedRightSubIndex = null;
                                  });
                                },
                                onDoubleTap: () => _editText(item.text, (newText) {
                                  setState(() => item.text = newText);
                                  saveLeftData();
                                }),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(item.text)),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
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
                                      icon: const Icon(Icons.keyboard_arrow_up),
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
                                      icon: const Icon(Icons.keyboard_arrow_down),
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
                                tileColor: selectedLeftIndex == index && selectedRightIndex == null ? Color.fromARGB(255, 136, 134, 121) : null,
                                title: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.circle, color: sub.status == 'F' ? Colors.green : Colors.yellow),
                                      onPressed: () {
                                        setState(() {
                                          if (sub.status == 'P') sub.status = 'W';
                                          else if (sub.status == 'W') sub.status = 'F';
                                          else sub.status = 'P';
                                        });
                                        saveLeftData();
                                      },
                                    ),
                                    Text(sub.status ?? 'P'),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onDoubleTap: () => _editText(sub.text, (newText) {
                                          setState(() => sub.text = newText);
                                          saveLeftData();
                                        }),
                                        child: Text(sub.text),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedLeftIndex = index;
                                    selectedRightIndex = null;
                                    selectedRightSubIndex = null;
                                  });
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        int subIndex = item.subitems.indexOf(sub);
                                        setState(() {
                                          item.subitems.removeAt(subIndex);
                                        });
                                        saveLeftData();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_up),
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
                                      icon: const Icon(Icons.keyboard_arrow_down),
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
                Expanded(
                  child: Column(
                    children: [
                      Text(' ', style: const TextStyle(fontSize: 12)),
                      Text(AppLocalizations.of(context)!.rightList, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: rightItems.length,
                          itemBuilder: (context, index) {
                            var item = rightItems[index];
                            return ExpansionTile(
                             title: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRightIndex = index;
                                    selectedRightSubIndex = null;
                                    selectedLeftIndex = null;
                                  });
                                },
                                onDoubleTap: () => _editText(item.text, (newText) {
                                  setState(() => item.text = newText);
                                  saveRightData();
                                }),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(item.text)),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
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
                                      icon: const Icon(Icons.keyboard_arrow_up),
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
                                      icon: const Icon(Icons.keyboard_arrow_down),
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
                                tileColor: selectedRightIndex == index ? Color.fromARGB(255, 136, 134, 121) : null,
                                title: GestureDetector(
                                  onDoubleTap: () => _editText(sub.text, (newText) {
                                    setState(() => sub.text = newText);
                                    saveRightData();
                                  }),
                                  child: Text(sub.text),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedRightIndex = index;
                                    selectedRightSubIndex = item.subitems.indexOf(sub);
                                    selectedLeftIndex = null;
                                  });
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        int subIndex = item.subitems.indexOf(sub);
                                        setState(() {
                                          item.subitems.removeAt(subIndex);
                                        });
                                        saveRightData();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_up),
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
                                      icon: const Icon(Icons.keyboard_arrow_down),
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