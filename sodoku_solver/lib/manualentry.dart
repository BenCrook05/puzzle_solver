import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:soduko_solver/apiresponsehandler.dart';

class GridEntryTable extends StatefulWidget {
  final VoidCallback updateSaves;
  const GridEntryTable({super.key, required this.updateSaves});

  @override
  State<GridEntryTable> createState() => _GridEntryTableState();
}

class _GridEntryTableState extends State<GridEntryTable> {
  final List<TextEditingController> _controllers =
      List.generate(81, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index_2) {
                        //[index_1 * 9 + index_2],
                        return TextField(
                          controller: _controllers[index_1 * 9 + index_2],
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle( 
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 24,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            contentPadding: const EdgeInsets.all(1),
                          ),
                          onChanged: (value) => setState(
                            () {
                              if (value.length > 1) {
                                _controllers[index_1 * 9 + index_2].text =
                                    value.substring(0, 1);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            alignment: Alignment.bottomRight,
            child: FloatingActionButton( 
              onPressed: () {
                for (var i = 0; i < 81; i++) {
                  _controllers[i].clear();
                }
              },
              shape: const CircleBorder(),
              mini: true,
              heroTag: 'clearGridButton',
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            onPressed: () async {
              try {
                if (!context.mounted) return;
                Future<String> apiRequestFuture = () async {
                  var request = http.MultipartRequest(
                      'POST', Uri.parse('http://10.0.2.2:5000'));
                  List<int> gridData = [];
                  for (var i = 0; i < 81; i++) {
                    gridData.add(int.parse(_controllers[i].text.isEmpty
                        ? '0'
                        : _controllers[i].text));
                  }
                  request.fields['grid'] = gridData.toString();
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
                      ),
                    ),
                  ),
                );
              } catch (e) {
                return;
              }
            },
            heroTag: 'manualEntrySubmit',
            child: const Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
}
