import cv2
import csv
import os
import random
import matplotlib.pyplot as plt

# configure the training data
training_path = "D:/model_training/training"
validation_path = "D:/model_training/validation"

training_csv = "D:/model_training/training.csv"
validation_csv = "D:/model_training/validation.csv"

IMAGE_SIZE = 20


def define_labels(csv_file):
    with open(csv_file, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["label", *[f"pixel_{i}" for i in range(IMAGE_SIZE**2)]]) # 20x20 pixels

define_labels(training_csv)
define_labels(validation_csv)

def write_images_to_csv(images_path, csv_file):
    image_data = []
    for folder in os.listdir(images_path):
        image_label = folder
        for image in os.listdir(os.path.join(images_path, folder)):
            img_list = [image_label]
            
            #reduce image to 20x20 pixels
            img = cv2.imread(os.path.join(images_path, folder, image))
            img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            img = cv2.resize(img, (IMAGE_SIZE, IMAGE_SIZE))
            
            #write image to csv file as pixels
            img = img.flatten()
            img_list.extend(img.tolist())
            
            image_data.append(img_list)
    
    #shuffle data to improve training        
    random.shuffle(image_data)
    
    
    with open(csv_file, "a", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(image_data)
            
write_images_to_csv(training_path, training_csv)
write_images_to_csv(validation_path, validation_csv)
        
#read a sample image
def test_sample():
    with open(training_csv, "r") as file:
        reader = csv.reader(file)
        for i, row in enumerate(reader):
            if i == 30:
                #show original image
                plt.imshow(cv2.imread(training_path+"/1/cell_17_0_2.jpg"))
                plt.show()
                
                #show formatted image
                label = row[0]
                pixels = row[1:]
                pixels = [int(pixel) for pixel in pixels]
                pixels = [pixels[i:i+IMAGE_SIZE] for i in range(0, len(pixels), IMAGE_SIZE)]
                plt.imshow(pixels, cmap="gray")
                plt.title(label)
                plt.show()
                break
            else:
                continue