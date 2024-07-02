import torch.nn as nn
import torch


class Net(nn.Module):
    def __init__(self, in_ch, out_ch, dropout_p):
        kernel_size = 3
        super().__init__()
        
        self.model = nn.Sequential(
            nn.Conv2d(in_ch, out_ch, kernel_size, stride=1, padding=1),
            nn.BatchNorm2d(out_ch),
            nn.ReLU(),
            nn.Dropout(dropout_p),
            nn.MaxPool2d(2, stride=2),
        )
        
    def forward(self, x):
        return self.model(x)
    
class BaseModel(nn.Module):
    def __init__(self, image_channels=1, n_classes=10, flattened_image_size=300):
        super(BaseModel, self).__init__()
        self.model = nn.Sequential(
            Net(image_channels, 25, 0),
            Net(25, 50, 0.2),
            Net(50, 75, 0),
            nn.Flatten(),
            nn.Linear(flattened_image_size, 512),
            nn.Dropout(.3),
            nn.ReLU(),
            nn.Linear(512, n_classes)
        )
    
    def forward(self, x):
        return self.model(x)
    

        
    @staticmethod
    def save_model(model, path="model/model.pth"):
        torch.save(model.state_dict(), path)
    
    @staticmethod
    def load_model(path="model/model.pth"):
        model = BaseModel()
        model.load_state_dict(torch.load(path))
        model.eval()  # Set the model to evaluation mode
        return model
    
    