import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DisplayPictureScreen extends StatefulWidget {
  final List<dynamic> responseData;
  final List<dynamic> originalData;
  final VoidCallback updateSaves;
  final bool newSave;

  const DisplayPictureScreen(
      {super.key,
      required this.responseData,
      required this.originalData,
      required this.updateSaves,
      required this.newSave});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool showAllValues = false;
  late List<bool> visibilityStates;

  @override
  void initState() {
    super.initState();
    visibilityStates = List<bool>.generate(widget.originalData.length,
        (index) => widget.originalData[index] != 0 || showAllValues);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solution"),
        actions: <Widget>[
          if (widget.newSave) ...[
            IconButton(
              icon: const Icon(Icons.save_as),
              onPressed: () => showSaveDialog(context),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteSave(context),
            ),
          ],
        ],
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary,
            width: 2,
          ),
        ),
        margin: const EdgeInsets.all(10),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index_1) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 2,
                  ),
                ),
                child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index_2) {
                    return GridElementButton(
                      value: widget.responseData[index_1 * 9 + index_2],
                      originalValue: widget.originalData[index_1 * 9 + index_2],
                      showValue: visibilityStates[index_1 * 9 + index_2],
                      onToggleVisibility: () =>
                          toggleElementVisibility(index_1 * 9 + index_2),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showAllValues = !showAllValues;
            _updateVisibilityStates();
          });
        },
        child: Icon(showAllValues ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }

  void toggleElementVisibility(int index) {
    setState(() {
      if (widget.originalData[index] == 0) {
        visibilityStates[index] = !visibilityStates[index];
      }
    });
  }

  void _updateVisibilityStates() {
    for (int i = 0; i < visibilityStates.length; i++) {
      visibilityStates[i] = widget.originalData[i] != 0 || showAllValues;
    }
  }

  Future<void> deleteSave(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Save'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this save?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                BuildContext dialogContext = context;
                final directory = await getApplicationDocumentsDirectory();
                final file = File('${directory.path}/saves.json');
                if (await file.exists()) {
                  await file.delete();
                  // ignore: use_build_context_synchronously
                  Navigator.of(dialogContext).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Save deleted successfully'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.of(dialogContext).pop();
                  widget.updateSaves();
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.of(dialogContext).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting save'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showSaveDialog(BuildContext context) async {
    final TextEditingController fileNameController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Solution'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: fileNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "File Name",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String fileName = fileNameController.text;
                if (fileName.isNotEmpty) {
                  BuildContext dialogContext = context;
                  await _saveDataToFile(fileName);
                  if (mounted) {
                    // safe to use because mounted
                    // ignore: use_build_context_synchronously
                    Navigator.of(dialogContext).pop();
                    widget.updateSaves();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content:
                            Text('Data saved to file $fileName successfully'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDataToFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saves.json');

    Map<String, dynamic> fileData = {};

    if (file.existsSync() && file.lengthSync() > 0) {
      try {
        String content = file.readAsStringSync();
        fileData = jsonDecode(content);
      } catch (e) {
        print("Error reading file: $e");
        fileData = {};
      }
    }

    final data = {
      'originalData': widget.originalData,
      'solutionData': widget.responseData,
      'time': DateTime.now().toString(),
    };

    fileData[fileName] = data;
    file.writeAsStringSync(jsonEncode(fileData));
  }
}

class GridElementButton extends StatefulWidget {
  final int value;
  final int originalValue;
  final bool showValue;
  final VoidCallback onToggleVisibility;
  // final bool topBorder;
  // final bool bottomBorder;
  // final bool leftBorder;
  // final bool rightBorder;

  const GridElementButton({
    super.key,
    required this.value,
    required this.originalValue,
    required this.showValue,
    required this.onToggleVisibility,
    // required this.topBorder,
    // required this.bottomBorder,
    // required this.leftBorder,
    // required this.rightBorder
  });

  @override
  State<GridElementButton> createState() => _GridElementButtonState();
}

class _GridElementButtonState extends State<GridElementButton> {
  late bool showValue;

  @override
  void initState() {
    super.initState();
    showValue = widget.showValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.inverseSurface,
          width: 1,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            minimumSize: MaterialStateProperty.all(Size.zero),
          ),
          onPressed: _onPressed,
          child: Center(
            child: Text(
              _getValue(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.originalValue == 0
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.inverseSurface,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getValue() {
    if (widget.showValue) {
      return widget.value.toString();
    } else {
      return '';
    }
  }

  void _onPressed() {
    widget.onToggleVisibility();
  }
}
