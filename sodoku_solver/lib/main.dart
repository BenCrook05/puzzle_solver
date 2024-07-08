import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import 'package:soduko_solver/cameraviewer.dart';
import 'package:soduko_solver/gridviewdisplay.dart';
import 'package:soduko_solver/typeselector.dart';
import 'package:soduko_solver/manualentry.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Solver',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: Colors.blue[200]!,
            secondary: Colors.blue[300]!,
            tertiary: Colors.blueAccent[100]!,
            onPrimary: Colors.blue[700]!,
            onSecondary: Colors.blue[800]!,
            onTertiary: Colors.blueAccent[400]!,
            surface: Colors.white,
            inverseSurface: Colors.black87,
          )),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey[700]!,
          secondary: Colors.blueGrey[600]!,
          tertiary: Colors.blueAccent[700]!,
          onPrimary: Colors.blueGrey[50]!,
          onSecondary: Colors.blueGrey[100]!,
          onTertiary: Colors.blueAccent[200]!,
          surface: Colors.blueGrey[900]!,
          inverseSurface: Colors.white70,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<dynamic>> savedFileNames = [];
  bool _selectorValueIsCamera = true;
  bool _initialSelectorValueIsCamera = true;
  late FutureBuilder<CameraViewer> cameraView;
  late GridEntryTable gridView;

  Future<CameraViewer> _cameraBuilder() async {
    final cameras =
        await availableCameras(); // Get a specific camera from the list of available cameras.
    CameraDescription firstCamera = cameras.first;
    return CameraViewer(
      camera: firstCamera,
      updateSaves: _refreshSavedFiles,
    );
  }

  Future<void> _saveViewPreference(bool isCamera) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('viewPreference', isCamera);
  }

  Future<bool> _getInitialViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('viewPreference') ?? true;
  }

  Future<void> _loadInitialViewPreference() async {
    bool showCameraFirst = await _getInitialViewPreference();
    setState(() {
      _initialSelectorValueIsCamera = showCameraFirst;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();

    print(_selectorValueIsCamera);
    _loadInitialViewPreference();

    cameraView = FutureBuilder<CameraViewer>(
      future: _cameraBuilder(),
      builder: (BuildContext context, AsyncSnapshot<CameraViewer> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // show loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return snapshot.data ??
              Container(); // show CameraViewer when data is available, otherwise return a placeholder widget
        }
      },
    );

    gridView = GridEntryTable(
      updateSaves: _refreshSavedFiles,
    );
  }

  Future<void> _loadSavedFiles() async {
    savedFileNames = await _getSavedFiles();
    setState(() {});
  }

  void _refreshSavedFiles() {
    _loadSavedFiles();
  }

  Future<List<List<dynamic>>> _getSavedFiles() async {
    final Directory directory = await getApplicationDocumentsDirectory();

    final File savesFile = File('${directory.path}/saves.json');
    final String content = await savesFile.readAsString();
    List<List<dynamic>> saveDetails = [];
    try {
      final Map<String, dynamic> saves = jsonDecode(content);
      saveDetails = saves.entries.map((entry) {
        String name = entry.key;
        String date = entry.value['time'];
        date = date.substring(0, 11);
        List<dynamic> originalGrid = entry.value['originalData'];
        List<dynamic> solution = entry.value['solutionData'];
        return [name, date, originalGrid, solution];
      }).toList();
      saveDetails = saveDetails.reversed.toList();
    } catch (e) {
      saveDetails = [];
    }
    return saveDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Solver'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Builder(
          builder: (context) => Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Saved Puzzles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: savedFileNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        savedFileNames[index][0],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        savedFileNames[index][1],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return DisplayPictureScreen(
                                originalData: savedFileNames[index][2],
                                responseData: savedFileNames[index][3],
                                updateSaves: _refreshSavedFiles,
                                newSave: false,
                                fileName: savedFileNames[index][0],
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              PuzzleEntrySelector(
                originalSelectedTypeIsCamera: _initialSelectorValueIsCamera,
                changeSelectedType: () {
                  setState(() {
                    _selectorValueIsCamera = !_selectorValueIsCamera;
                    _saveViewPreference(_selectorValueIsCamera);
                  });
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                _selectorValueIsCamera
                    ? 'Take a picture of the puzzle to solve:'
                    : 'Enter sodoku values manually',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              _selectorValueIsCamera ? cameraView : gridView,
            ],
          ),
        ),
      ),
    );
  }
}
