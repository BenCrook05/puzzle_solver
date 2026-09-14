import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:soduko_solver/apiresponsehandler.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:soduko_solver/apiconfig.dart';


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

class _CameraViewerState extends State<CameraViewer> with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCapturing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize().then((_) async {
      try {
        await _controller.setFlashMode(FlashMode.off);
      } catch (_) {}
      try {
        await _controller.setFocusMode(FocusMode.auto);
      } catch (_) {}
    });
  }

  Future<void> _toggleFlash() async {
    if (!_controller.value.isInitialized) return;
    try {
      final nextState = !_isFlashOn;
      await _controller.setFlashMode(nextState ? FlashMode.always : FlashMode.off);
      setState(() {
        _isFlashOn = nextState;
      });
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _controller.pausePreview();
    } else if (state == AppLifecycleState.resumed) {
      _controller.resumePreview();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<String> _cropAndResizeImage(String sourcePath) async {
    final file = File(sourcePath);
    final imageBytes = await file.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Failed to decode image");
    }

    final length = originalImage.width < originalImage.height
        ? originalImage.width
        : originalImage.height;

    final croppedImage = img.copyCrop(
      originalImage,
      x: (originalImage.width - length) ~/ 2,
      y: (originalImage.height - length) ~/ 2,
      width: length,
      height: length,
    );

    final resizedImage = img.copyResize(croppedImage, width: 800, height: 800);
    final croppedImageBytes = img.encodeJpg(resizedImage, quality: 85);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_cropped_image.jpg');
    await tempFile.writeAsBytes(croppedImageBytes);

    try {
      await file.delete();
    } catch (_) {}

    return tempFile.path;
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
                      // // If the Future is complete, display the preview.
                      // final scaleHeight = (screenWidth - 50) /
                      //     _controller.value.previewSize!.height;
                      // final scaleWidth = (screenWidth - 50) /
                      //     _controller.value.previewSize!.width;
                      // final aspectRatio = _controller.value.aspectRatio;
                      // final scale = aspectRatio > 1 ? scaleHeight : scaleWidth;
                      // final scaleRatio = scale * aspectRatio;
                      // return Center(
                      //   child: AspectRatio(
                      //     aspectRatio: 1,
                      //     child: ClipRect(
                      //       child: Transform.scale(
                      //         scale: scaleRatio,
                      //         child: Center(
                      //           child: CameraPreview(_controller)
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // );
                      final size = screenWidth - 50;
                      return Center(
                        child: GestureDetector(
                          onTapUp: (details) async {
                            try {
                              final offset = Offset(
                                details.localPosition.dx / size,
                                details.localPosition.dy / size,
                              );
                              await _controller.setFocusPoint(offset);
                              await _controller.setFocusMode(FocusMode.auto);
                            } catch (e) {} // should do something with the catches
                          },
                          child: SizedBox(
                            height: size,
                            width: size,
                            child: ClipRect(
                              child: SizedOverflowBox(
                                size: Size(size, size),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _controller.value.previewSize?.height ?? size,
                                    height: _controller.value.previewSize?.width ?? size,
                                    child: CameraPreview(_controller),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 56),
              FloatingActionButton(
                heroTag: 'cameraCapture',
                onPressed: _isCapturing
                    ? null
                    : () async {
                        setState(() {
                          _isCapturing = true;
                        });
                        try {
                          await _initializeControllerFuture;

                          final image = await _controller.takePicture();
                          final croppedPath = await _cropAndResizeImage(image.path);

                          if (!context.mounted) return;

                          Future<String> apiRequestFuture = () async {
                            var request = http.MultipartRequest('POST', ApiConfig.solveImageUri);
                            request.files.add(await http.MultipartFile.fromPath('image', croppedPath));
                            
                            var res = await request.send().timeout(const Duration(seconds: 20));
                            var responseData = await http.Response.fromStream(res);
                            if (responseData.statusCode == 200 || responseData.statusCode == 400) {
                              return responseData.body;
                            } else {
                              throw Exception('Server returned HTTP ${responseData.statusCode}');
                            }
                          }().timeout(const Duration(seconds: 15));
                          try {
                            await _controller.pausePreview();
                          } catch (_) {}

                          if (!context.mounted) return;

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ApiResponseHandler(
                                apiRequestFuture: apiRequestFuture,
                                updateSaves: widget.updateSaves,
                              ),
                            ),
                          );

                          try {
                            await _controller.resumePreview();
                          } catch (_) {}
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Camera/Upload error: ${e.toString()}')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isCapturing = false;
                            });
                          }
                        }
                      },
                child: _isCapturing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.camera_alt),
              ),
              const SizedBox(width: 16),
              FloatingActionButton.small(
                heroTag: 'cameraFlashToggle',
                onPressed: _toggleFlash,
                child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
