#Use Python 3.10 only


import torch.nn as nn
import pandas as pd
import torch
from torch.optim import Adam
from torch.utils.data import DataLoader, Dataset
import torchvision.transforms.v2 as transforms
import torchvision.transforms.functional as F
import matplotlib.pyplot as plt

#suppress warnings
import torch._dynamo
torch._dynamo.config.suppress_errors = True

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")


IMAGE_HEIGHT = 20
IMAGE_WIDTH = 20
IMAGE_CHANNELS = 1
N_CLASSES = 10

train_df = pd.read_csv("D:/model_training/training.csv")
valid_df = pd.read_csv("D:/model_training/validation.csv")


class MyDataSet(Dataset):
    def __init__(self, base_df):
        x_df = base_df.copy()
        y_df = x_df.pop("label")
        x_df = x_df.values/255
        x_df = x_df.reshape(-1, IMAGE_CHANNELS, IMAGE_WIDTH, IMAGE_HEIGHT)
        self.xs = torch.tensor(x_df).float().to(device)
        self.ys = torch.tensor(y_df).to(device)
        
    def __getitem__(self, idx):
        x = self.xs[idx]
        y = self.ys[idx]
        return x, y
    
    def __len__(self):
        return len(self.xs)
        
batch_size = 32

train_ds = MyDataSet(train_df)
train_loader = DataLoader(train_ds, batch_size, shuffle=True)
train_N = len(train_loader.dataset)

valid_ds = MyDataSet(valid_df)
valid_loader = DataLoader(valid_ds, batch_size, shuffle=False)
valid_N = len(valid_loader.dataset)



from conv_net import BaseModel

model = BaseModel()
loss_function = nn.CrossEntropyLoss()
optimiser = Adam(model.parameters())


agumentation_transforms = transforms.Compose([
    transforms.RandomResizedCrop((IMAGE_WIDTH,IMAGE_HEIGHT), scale=(0.7, 1.0), ratio=(1,1)),
    transforms.RandomRotation(10),
    transforms.ColorJitter(brightness=0.2, contrast=0.5, saturation=0.5, hue=0.2),
    transforms.GaussianBlur(3),
])

def get_batch_accuracy(output, y, N):
    pred = output.argmax(dim=1, keepdim=True)
    correct = pred.eq(y.view_as(pred)).sum().item()
    return correct / N

def train():
    loss = 0
    accuracy = 0
    model.train()
    for x,y in train_loader:
        output = model(agumentation_transforms(x))
        optimiser.zero_grad()
        batch_loss = loss_function(output, y)
        batch_loss.backward()
        optimiser.step()
        loss += batch_loss.item()
        accuracy += get_batch_accuracy(output, y, train_N)
    print(f"Train Loss: {loss:.4f} Accuracy: {accuracy:.4f}")
    

def validate():
    loss = 0
    accuracy = 0
    model.eval()
    
    with torch.no_grad():
        for x,y in valid_loader:
            output = model(x)
            loss += loss_function(output, y).item()
            accuracy += get_batch_accuracy(output, y, valid_N)
    print(f"Validation Loss: {loss:.4f} Accuracy: {accuracy:.4f}")
    
for epoch in range(30):
    print(f"Epoch {epoch}")
    train()
    validate()

save = input("Save model? (y/n): ")
if save == "y":
    BaseModel.save_model(model)