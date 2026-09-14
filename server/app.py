from flask import Flask, request, jsonify
import json
from solver import recursive
import traceback
import cv2
import numpy as np
app = Flask(__name__)
from solver.extractgrids import Extract


def solve_format_responses(grid):
    solved_grid = recursive.solve_puzzle(grid)

    return jsonify({
        "flag": "success",
        'solution': Extract.rows_to_boxes(solved_grid),
        'original_grid': Extract.rows_to_boxes(grid)
    })


@app.route('/solve/image', methods=['POST'])
def solve_image_endpoint():
    print("Solving image entry")
    try:
        if 'image' not in request.files:
            return jsonify({'flag': 'error', 'message': 'Could not read image from request. Please try again or use Manual Entry.'}), 400

        try:
            grid = Extract.extract_grid_from_image(request.files['image'])
        except Exception:
            print(traceback.format_exc())
            return jsonify({'flag': 'error', 'message': 'Could not recognize the Sudoku grid from the photo. Please check lighting and camera alignment, or try Manual Entry.'}), 400

        return solve_format_responses(grid)
    except Exception as e:
        print(traceback.format_exc())
        return jsonify({'flag': 'error', 'message': str(e)}), 400

@app.route('/solve/manual', methods=['POST'])
def solve_manual_endpoint():
    print("Solving manual entry")
    try:
        grid = Extract.extract_grid_from_manual(request.form)
        return solve_format_responses(grid)
    except Exception as e:
        print(traceback.format_exc())
        return jsonify({'flag': 'error', 'message': str(e)}), 400


@app.route('/', methods=['POST'])
def endpoint():
    print("Solving general old entry")
    #keep old endpoint for testing 
    if 'image' in request.files:
        return solve_image_endpoint()
    elif request.form:
        return solve_manual_endpoint()
    return jsonify({'flag': 'error', 'message': 'unsupported_request_format'}), 400

    
    
