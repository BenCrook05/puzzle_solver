from flask import Flask, request, jsonify
import model.process_images as pro
import model_utils.preprocess as prepro
from solver import recursive
app = Flask(__name__)

@app.route('/', methods=['POST'])
def endpoint():
    try:
        if 'image' in request.files:
            image = request.files['image']
            
            # cell_images = prepro.get_cells_from_image_grid(image, 9)
            # grid = []
            # for row in cell_images:
            #     row_values = []
            #     for cell in row:
            #         value = pro.process_image(cell)
            #         row_values.append(value)
            #     if len(row_values) != 9:
            #         return jsonify({'flag': 'error', 'message': 'image_processing_error'})
            #     grid.append(row_values)
            # if len(grid) != 9:
            #     return jsonify({'flag': 'error', 'message': 'image_processing_error'})
        elif request.is_json:
            data = request.get_json()
            if 'grid' not in data:
                return jsonify({'flag': 'error', 'message': 'missing_grid'})
            grid = data['grid']
        
        # solved_grid = recursive.solve_puzzle(grid)
        
        grid = [[0, 0, 8, 7, 0, 0, 1, 0, 3],
            [7, 0, 0, 0, 0, 9, 0, 0, 2],
            [0, 0, 0, 0, 5, 0, 0, 7, 0],
            [0, 8, 0, 0, 0, 0, 0, 0, 1],
            [0, 0, 0, 0, 0, 0, 4, 0, 0],
            [6, 7, 0, 0, 4, 5, 0, 0, 0],
            [0, 0, 3, 0, 0, 7, 6, 2, 0],
            [0, 0, 1, 0, 0, 0, 0, 5, 0],
            [0, 5, 0, 3, 0, 2, 0, 0, 4],
        ]
        
        
        solved_grid = [[5, 9, 8, 7, 2, 6, 1, 4, 3], 
            [7, 1, 6, 4, 3, 9, 5, 8, 2], 
            [3, 2, 4, 8, 5, 1, 9, 7, 6], 
            [4, 8, 5, 2, 9, 3, 7, 6, 1], 
            [1, 3, 2, 6, 7, 8, 4, 9, 5], 
            [6, 7, 9, 1, 4, 5, 2, 3, 8], 
            [8, 4, 3, 5, 1, 7, 6, 2, 9], 
            [2, 6, 1, 9, 8, 4, 3, 5, 7], 
            [9, 5, 7, 3, 6, 2, 8, 1, 4]
        ]
        
        
        
        
        return jsonify({'flag': 'success', 'solution': solved_grid, 'original_grid': grid})
    
    except Exception as e:
        return jsonify({'flag': 'error', 'message': str(e)})