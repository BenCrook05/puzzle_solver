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

@app.route('/', methods=['POST'])
def endpoint():
    try:
        if 'image' in request.files:
            image_file = request.files['image']
            image_data = np.fromstring(image_file.read(), np.uint8)
            image = cv2.imdecode(image_data, cv2.IMREAD_COLOR)
            cv2.imwrite('image.jpg', image)  
            cell_images = prepro.get_cells_from_image_grid(image, 9)
            grid = []
            for row in cell_images:
                row_values = []
                for cell in row:
                    value = pro.process_image(cell)
                    row_values.append(value)
                if len(row_values) != 9:
                    return jsonify({'flag': 'error', 'message': 'image_processing_error'})
                grid.append(row_values)
                
            grid = rows_to_boxes(grid)
            
            if len(grid) != 9:
                return jsonify({'flag': 'error', 'message': 'image_processing_error'})
            
        elif request.form:
            data = request.form
            print("Data:")
            print(data)
            if 'grid' not in data:
                return jsonify({'flag': 'error', 'message': 'missing_grid'})
            print("Received grid data")
            grid_str = data['grid']
            print("Extracted grid data")
            grid_data = json.loads(grid_str)
            print("Loaded grid data")
            grid = []
            # convert 1d array into 2d array with 9 boxes
            for i in range(0, 81, 9):
                row = grid_data[i:i+9]
                grid.append(row)
            
            grid = boxes_to_rows(grid)

        #make copy so we can compare original and solved grid
        original_grid = copy.deepcopy(grid)
        solved_grid = recursive.solve_puzzle(grid)
        
        print("Solved grid")
        print(solved_grid)
        
        print("original grid")
        print(original_grid)
        
        
        original_grid = rows_to_boxes(original_grid)
        solved_grid = rows_to_boxes(solved_grid)
        
        return jsonify({'flag': 'success', 'solution': solved_grid, 'original_grid': original_grid})
                   
    
    except Exception as e:
        print(traceback.format_exc())
        return jsonify({'flag': 'error', 'message': str(e)})
    
    
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