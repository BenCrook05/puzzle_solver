import 'package:flutter/material.dart';

class PuzzleEntrySelector extends StatefulWidget {
  final bool originalSelectedTypeIsCamera;
  final VoidCallback changeSelectedType;
  const PuzzleEntrySelector(
      {super.key,
      required this.originalSelectedTypeIsCamera,
      required this.changeSelectedType});

  @override
  State<PuzzleEntrySelector> createState() => _PuzzleEntrySelectorState();
}

class _PuzzleEntrySelectorState extends State<PuzzleEntrySelector> {
  late bool _currentSelectedTypeIsCamera;

  @override
  void initState() {
    super.initState();
    _currentSelectedTypeIsCamera = widget.originalSelectedTypeIsCamera;
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
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
      onPressed: (int index) {
        setState(() {
          _currentSelectedTypeIsCamera = index == 0;
          widget.changeSelectedType();
        });
      },
      isSelected: [_currentSelectedTypeIsCamera, !_currentSelectedTypeIsCamera],
      children: const [
        Text("Camera"),
        Text("Manual"),
      ],
    );
  }
}
