# Puzzle Solver

Puzzle Solver is a Flutter application designed to help users solve Sudoku puzzles. Users can either take a picture of the puzzle or manually enter the puzzle values. The app processes the image to detect the grid and solve the puzzle.

## Features

- **Camera Integration**: Capture an image of the Sudoku puzzle using the device's camera.
- **ML image recognition**: Detect numbers in grid through Hough line transformation and Pytorch.
- **Recursive solver**: Solves the soduko using a recursive trial and error technique.
- **Manual Entry**: Manually input Sudoku values.
- **Save and Load**: Save solved puzzles and load them later.
- **Dark and Light Themes**: Supports both dark and light themes based on system settings.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Python with OpenCV and NumPy libraries

### Installation

1. **Clone the repository**:
   ```sh
   git clone https://github.com/yourusername/puzzle-solver.git
   cd puzzle-solver
