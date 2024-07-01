from flask import Flask, request, jsonify
import model.process_images as pro
import model_utils.preprocess as prepro
from solver import recursive
app = Flask(__name__)

@app.route('/', methods=['POST'])
def endpoint():
    data = request.get_json()
    try:
        image = data['image']
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
        if len(grid) != 9:
            return jsonify({'flag': 'error', 'message': 'image_processing_error'})
    except KeyError:
        grid = data['grid']
    
    solved_grid = recursive.solve(grid)
    
    return jsonify({'flag': 'success', 'solution': solved_grid})