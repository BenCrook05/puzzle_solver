import model_utils.preprocess as prepro
import numpy as np
import cv2
import model.process_images as pro
import json

class Extract:
    @staticmethod
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

    @staticmethod
    def extract_grid_from_manual(form_data):
        if 'grid' not in form_data:
            raise KeyError("Missing grid")

        grid_data = json.loads(form_data['grid'])

        if len(grid_data) != 81:
            raise ValueError("Invalid grid data")

        boxes = [grid_data[i: i +9] for i in range(0, 81, 9)]
        return boxes_to_rows(boxes)

    @staticmethod
    def boxes_to_rows(boxes):
        rows = [[0] * 9 for _ in range(9)]
        for box_index, box in enumerate(boxes):
            box_row = (box_index // 3) * 3
            box_col = (box_index % 3) * 3
            for i in range(3):
                for j in range(3):
                    rows[box_row + i][box_col + j] = box[i * 3 + j]
        return rows

    @staticmethod
    def rows_to_boxes(rows):
        boxes = [[0] * 9 for _ in range(9)]
        for row_index, row in enumerate(rows):
            box_row = (row_index // 3) * 3
            for col_index, value in enumerate(row):
                box_col = (col_index // 3) + (row_index % 3) * 3
                box_index = box_row + (col_index // 3)
                position = (col_index % 3) + (row_index % 3) * 3
                boxes[box_index][position] = value
        return boxes