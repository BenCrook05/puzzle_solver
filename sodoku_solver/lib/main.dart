import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import 'package:soduko_solver/cameraviewer.dart';
import 'package:soduko_solver/gridviewdisplay.dart';
import 'package:soduko_solver/typeselector.dart';

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
            background: Colors.white,
            primary: Colors.blue[200]!,
            secondary: Colors.blue[300]!,
            tertiary: Colors.blueAccent[100]!,
            onPrimary: Colors.blue[700]!,
            onSecondary: Colors.blue[800]!,
            onTertiary: Colors.blueAccent[400]!,
            surface: Colors.lightBlue[50]!,
            inverseSurface: Colors.black87,
          )),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          background: Colors.blueGrey[900]!,
          primary: Colors.blueGrey[700]!,
          secondary: Colors.blueGrey[600]!,
          tertiary: Colors.blueAccent[700]!,
          onPrimary: Colors.blueGrey[50]!,
          onSecondary: Colors.blueGrey[100]!,
          onTertiary: Colors.blueAccent[200]!,
          surface: Colors.blueGrey[800]!,
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

  Future<CameraViewer> _cameraBuilder() async {
    final cameras =
        await availableCameras(); // Get a specific camera from the list of available cameras.
    CameraDescription firstCamera = cameras.first;
    return CameraViewer(
      camera: firstCamera,
      updateSaves: _refreshSavedFiles,
    );
  }

  @override
  void initState() {
    super.initState();
    print("Loading saved files");
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    savedFileNames = await _getSavedFiles();
    print(savedFileNames);
    setState(() {
      //to trigger rebuild
    });
  }

  void _refreshSavedFiles() {
    _loadSavedFiles();
  }

  Future<List<List<dynamic>>> _getSavedFiles() async {
    print("Getting saved files");
    final Directory directory = await getApplicationDocumentsDirectory();

    final File savesFile = File('${directory.path}/saves.json');
    final String content = await savesFile.readAsString();
    List<List<dynamic>> saveDetails = [];
    try {
      final Map<String, dynamic> saves = jsonDecode(content);
      print("Retrieved");
      saveDetails = saves.entries.map((entry) {
        String name = entry.key;
        String date = entry.value['time'];
        date = date.substring(0, 11);
        List<dynamic> originalGrid = entry.value['originalData'];
        List<dynamic> solution = entry.value['solutionData'];
        return [name, date, originalGrid, solution];
      }).toList();
      print("Saved files: $saveDetails");
    } catch (e) {
      print("Error reading saved files: $e");
    }
    return saveDetails;
  }

  final _selector = const PuzzleSelector();

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
        backgroundColor: Theme.of(context).colorScheme.background,
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
              _selector,
              const SizedBox(
                height: 15,
              ),
              Text(
                'Take a picture of the puzzle to solve:',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              FutureBuilder<CameraViewer>(
                future: _cameraBuilder(),
                builder: (BuildContext context,
                    AsyncSnapshot<CameraViewer> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // show loading spinner while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return snapshot.data ??
                        Container(); // show CameraViewer when data is available, otherwise return a placeholder widget
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
