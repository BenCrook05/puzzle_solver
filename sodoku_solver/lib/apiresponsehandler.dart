import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:soduko_solver/gridviewdisplay.dart';

class ApiResponseHandler extends StatelessWidget {
  final Future<String> apiRequestFuture;
  final VoidCallback updateSaves;
  const ApiResponseHandler({super.key, required this.apiRequestFuture, required this.updateSaves});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: apiRequestFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          print("Response data:   ");
          print(snapshot.data);
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("No data received from the server."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            );
          }
          try {
            var responseData = jsonDecode(snapshot.data ?? '');
            String responseFlag = responseData["flag"];
            if (responseFlag == "error") {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(responseData["message"]),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              );
            } else if (responseFlag == "success") {
              var originalData = responseData["original_grid"];
              var solutionData = responseData["solution"];
              List<int> originalDataList = _convertGridToList(originalData);
              List<int> solutionDataList = _convertGridToList(solutionData);
              return DisplayPictureScreen(
                originalData: originalDataList,
                responseData: solutionDataList,
                updateSaves: updateSaves,
                newSave: true,
              );
            } else {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("Unknown error"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              );
            }
          } catch (e) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Failed to parse data from server"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  List<int> _convertGridToList(dynamic grid) {
    List<int> list = [];
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        list.add(grid[i][j]);
      }
    }
    return list;
  }
}
