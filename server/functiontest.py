import model.process_images as process_images
import model_utils.preprocess as preprocess
import cv2


#test image path
image_path = "D:/model_training/test/IMG_4018.JPEG"
image = cv2.imread(image_path)
cell_images = preprocess.get_cells_from_image_grid(image, 9)
print("Cells found: ", len(cell_images))
cells = []
for row in cell_images:
    row_values = []
    for cell in row:
        value = process_images.process_image(cell)
        row_values.append(value)
    cells.append(row_values)

for row in cells:
    print(row)