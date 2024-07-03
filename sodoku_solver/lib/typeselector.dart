import 'package:flutter/material.dart';


class PuzzleSelector extends StatefulWidget {
  final VoidCallback changeView;
  final Function(String) onTypeChange;
  const PuzzleSelector(
      {super.key, required this.changeView, required this.onTypeChange});

  @override
  State<PuzzleSelector> createState() => _PuzzleSelectorState();
}

class _PuzzleSelectorState extends State<PuzzleSelector> {
  final List<bool> _selectedType = <bool>[true, false];
  bool vertical = false;

  String get selectedType {
    if (_selectedType[0]) {
      return "Camera";
    } else {
      return "Manual";
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
        widget.onTypeChange(selectedType);
        print(selectedType);
        widget.changeView();
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
      children: const [Text("Camera"), Text("Manual")],
    );
  }
}
