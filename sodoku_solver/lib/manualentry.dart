import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:soduko_solver/apiresponsehandler.dart';
import 'package:soduko_solver/apiconfig.dart';


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
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

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
                      physics: const NeverScrollableScrollPhysics(),
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
              onPressed: () async {
                try {
                  if (!context.mounted) return;
                  Future<String> apiRequestFuture = () async {
                    var request = http.MultipartRequest(
                      'Post',
                      ApiConfig.solveManualUri

                    );
                    List<int> gridData = [];
                    for (var i = 0; i < 81; i++) {
                      final text = _controllers[i].text.trim();
                      gridData.add(int.tryParse(text) ?? 0);


                    }
                    request.fields['grid'] = gridData.toString();
                    var res = await request.send().timeout(const Duration(seconds: 20));
                    var responseData = await http.Response.fromStream(res);
                    if (responseData.statusCode == 200 || responseData.statusCode == 400) {
                      return responseData.body;
                    } else {
                      throw Exception('Server returned HTTP ${responseData.statusCode}');
                    }
                  }().timeout(const Duration(seconds: 15));
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ApiResponseHandler(
                        apiRequestFuture: apiRequestFuture,
                        updateSaves: widget.updateSaves,
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              heroTag: 'manualEntrySubmit',
              child: const Icon(Icons.upload),
            ),
          ),
        ],
      ),
    );
  }
}
