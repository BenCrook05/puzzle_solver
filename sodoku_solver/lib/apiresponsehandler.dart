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
          if (snapshot.hasError) {
            return _buildErrorScaffold(
              context,
              "Connection Error",
              "${snapshot.error}",
            );
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return _buildErrorScaffold(
              context,
              "Error",
              "No data received from the server.",
            );
          }
          try {
            var responseData = jsonDecode(snapshot.data ?? '');
            String responseFlag = responseData["flag"];
            if (responseFlag == "error") {
              String msg = responseData["message"] ?? "An error occurred";
              String title = "Error";
              if (msg.contains("breaks Sudoku rules") || msg.contains("violates")) {
                title = "Rule Violation";
              } else if (msg.contains("unsolvable")) {
                title = "Unsolvable Puzzle";
              } else if (msg.contains("recognize") || msg.contains("Manual Entry")) {
                title = "Recognition Error";
              }
              return _buildErrorScaffold(
                context,
                title,
                msg,
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
                fileName: "",
              );
            } else {
              return _buildErrorScaffold(
                context,
                "Error",
                "Unknown error",
              );
            }
          } catch (e) {
            return _buildErrorScaffold(
              context,
              "Error",
              "Failed to parse data from server: response: $e",
            );
          }
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Solving..."),
              titleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Analyzing and solving...",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
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
