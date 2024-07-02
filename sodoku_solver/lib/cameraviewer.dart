import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:soduko_solver/apiresponsehandler.dart';

class CameraViewer extends StatefulWidget {
  final VoidCallback updateSaves;
  const CameraViewer({
    super.key,
    required this.camera,
    required this.updateSaves,
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 15,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 5,
                ),
              ),
              child: SizedBox(
                  height: screenWidth - 50,
                  width: screenWidth - 50,
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the Future is complete, display the preview.
                        return CameraPreview(_controller);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )),
            ),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;

                final image = await _controller.takePicture();

                if (!context.mounted) return;

                Future<String> apiRequestFuture = () async {
                  var request = http.MultipartRequest(
                      'POST', Uri.parse('http://10.0.2.2:5000'));
                  request.files.add(
                      await http.MultipartFile.fromPath('image', image.path));
                  var res =
                      await request.send().timeout(const Duration(seconds: 20));
                  var responseData = await http.Response.fromStream(res);
                  if (responseData.statusCode != 200) {
                    throw Exception('Failed to connect to server');
                  } else {
                    return responseData.body;
                  }
                }()
                    .timeout(const Duration(seconds: 15));

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder<String>(
                        future: apiRequestFuture,
                        builder: (context, snapshot) => ApiResponseHandler(
                              apiRequestFuture: apiRequestFuture,
                              updateSaves: widget.updateSaves,
                            )),
                  ),
                );
              } catch (e) {
                return;
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
