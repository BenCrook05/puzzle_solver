import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class CameraViewer extends StatefulWidget {
  const CameraViewer({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<CameraViewer> createState() => _CameraViewerState();
}

class _CameraViewerState extends State<CameraViewer> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 5,
            ),
          ),
          child: SizedBox(
              height: screenWidth - 50, // specify the height
              width: screenWidth - 50,
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the Future is complete, display the preview.
                    return CameraPreview(_controller);
                  } else {
                    // Otherwise, display a loading indicator.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )),
        ),
        const SizedBox(height: 15),
        FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;

              final image = await _controller.takePicture();

              if (!context.mounted) return;

              Future<String> apiRequestFuture = () async {
                var request =
                    http.MultipartRequest('POST', Uri.parse('inserturl here'));
                request.files.add(
                    await http.MultipartFile.fromPath('image', image.path));
                var res =
                    await request.send().timeout(const Duration(seconds: 10));
                var responseData = await http.Response.fromStream(res);
                return responseData.body;
              }()
                  .timeout(const Duration(seconds: 10));

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FutureBuilder<String>(
                    future: apiRequestFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return DisplayPictureScreen(
                          responseData: snapshot.data ?? '',
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              );
            } catch (e) {
              return;
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ],
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String responseData;

  const DisplayPictureScreen({super.key, required this.responseData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solution"),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
    );
  }
}
