from flask import Flask, request, jsonify
import json
import model.process_images as pro
import model_utils.preprocess as prepro
from solver import recursive
import traceback
import copy
import cv2
import numpy as np
app = Flask(__name__)

def extract_grid_from_image(image_file):
    image_data = np.frombuffer(image_file.read(), np.uint8)

    image = cv2.imdecode(image_data, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("Image is empty")
    
    # cv2.imwrite("image.jpg", image)
    
    cell_images = prepro.get_cells_from_image_grid(image, 9)

    grid = []
    for row in cell_images:
        row_values = [pro.process_image(cell) for cell in row]
        if len(row_values) != 9:
            raise ValueError("Image processing error")
        
        grid.append(row_values)
    if len(grid) != 9:
        raise ValueError("Image processing error")
    
    return grid

def extract_grid_from_manual(form_data):
    if 'grid' not in form_data:
        raise KeyError("Missing grid")
    
    grid_data = json.loads(form_data['grid'])

    if len(grid_data) != 81:
        raise ValueError("Invalid grid data")
    
    boxes = [grid_data[i:i+9] for i in range(0, 81, 9)]
    return boxes_to_rows(boxes)

def solve_format_responses(grid):
    solved_grid = recursive.solve_puzzle(grid)

    return jsonify({
        "flag": "success",
        'solution': rows_to_boxes(solved_grid),
        'original_grid': rows_to_boxes(grid)
    })


@app.route('/solve/image', methods=['POST'])
def solve_image_endpoint():
    print("Solving image entry")
    try:
        if 'image' not in request.files:
            return jsonify({'flag': 'error', 'message': 'missing_image'}), 400


        grid = extract_grid_from_image(request.files['image'])
        return solve_format_responses(grid)
    except Exception as e:
        print(traceback.format_exc())
        return jsonify({'flag': 'error', 'message': str(e)}), 400

@app.route('/solve/manual', methods=['POST'])
def solve_manual_endpoint():
    print("Solving manual entry")
    try:
        grid = extract_grid_from_manual(request.form)
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

    
    
def boxes_to_rows(boxes):
    rows = [[0]*9 for _ in range(9)]
    for box_index, box in enumerate(boxes):
        box_row = (box_index // 3) * 3
        box_col = (box_index % 3) * 3
        for i in range(3):
            for j in range(3):
                rows[box_row + i][box_col + j] = box[i * 3 + j]
    return rows

def rows_to_boxes(rows):
    boxes = [[0]*9 for _ in range(9)]
    for row_index, row in enumerate(rows):
        box_row = (row_index // 3) * 3
        for col_index, value in enumerate(row):
            box_col = (col_index // 3) + (row_index % 3) * 3
            box_index = box_row + (col_index // 3)
            position = (col_index % 3) + (row_index % 3) * 3
            boxes[box_index][position] = value
    return boxes