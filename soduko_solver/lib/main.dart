
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'cameraviewer.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class PuzzleSelector extends StatefulWidget {
  const PuzzleSelector({super.key});

  @override
  State<PuzzleSelector> createState() => _PuzzleSelectorState();
}

class _PuzzleSelectorState extends State<PuzzleSelector> {
  final List<bool> _selectedType = <bool>[true, false, false];
  bool vertical = false;

  String get selectedType {
    if (_selectedType[0]) {
      return "Soduko";
    } else if (_selectedType[1]) {
      return "Killer";
    } else {
      return "Futiski";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedType.length; i++) {
            _selectedType[i] = i == index;
          }
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      borderColor: Theme.of(context).colorScheme.secondary,
      selectedBorderColor: Theme.of(context).colorScheme.onPrimary,
      selectedColor: Theme.of(context).colorScheme.onSecondary,
      fillColor: Theme.of(context).colorScheme.primary,
      color: Theme.of(context).colorScheme.onPrimary,
      constraints: const BoxConstraints(
        minHeight: 40.0,
        minWidth: 80.0,
      ),
      isSelected: _selectedType,
      children: const [Text("Soduko"), Text("Killer"), Text("Futiski")],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<CameraViewer> _cameraBuilder() async {
    final cameras =
        await availableCameras(); // Get a specific camera from the list of available cameras.
    CameraDescription firstCamera = cameras.first;
    return CameraViewer(
      camera: firstCamera,
    );
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            _selector,
            const SizedBox(height: 15,),
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
              builder:
                  (BuildContext context, AsyncSnapshot<CameraViewer> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // show loading spinner while waiting
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // show error message if any error occurred
                } else {
                  return snapshot.data ??
                      Container(); // show CameraViewer when data is available, otherwise return a placeholder widget
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
