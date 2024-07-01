#Use Python 3.10 only
import torch
import torch.nn as nn
import torchvision.transforms.v2 as transforms

from model.conv_net import BaseModel


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


model = BaseModel.load_model()


IMAGE_HEIGHT = 20
IMAGE_WIDTH = 20

def process_image(image):
    print("Processing image")
    print(image.shape)
    preprocess_trans = transforms.Compose([
        # transforms.ToDtype(torch.float32, scale=True), # Converts [0, 255] to [0, 1]
        transforms.ToTensor(),
        transforms.Resize((IMAGE_WIDTH, IMAGE_HEIGHT)),
        transforms.Grayscale()  
    ])
    
    processed_image = preprocess_trans(image)
    batched_image = processed_image.unsqueeze(0)
    batched_image_device = batched_image.to(device)
    output = model(batched_image_device)
    
    prediction = output.argmax(dim=1).item() #get most probable item in array
    print(prediction)
    return prediction