import 'package:flutter/material.dart';

class PuzzleEntrySelector extends StatelessWidget {
  final bool isCamera;
  final ValueChanged<bool> onChanged;

  const PuzzleEntrySelector({
    super.key,
    required this.isCamera,
    required this.onChanged,
  });

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
        onChanged(index == 0);
      },
      isSelected: [isCamera, !isCamera],
      children: const [
        Text("Camera"),
        Text("Manual"),
      ],
    );
  }
}
