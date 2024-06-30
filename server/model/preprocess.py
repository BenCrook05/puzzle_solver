import cv2
import numpy as np



def preprocess_image(image):
    reduced = cv2.resize(image, (500, 500))
    grey = cv2.cvtColor(reduced, cv2.COLOR_BGR2GRAY)
    return grey


def detect_gridlines(image, threshold=80):
    
    edges = cv2.Canny(image, threshold, threshold*2, apertureSize=3)
    kernel = np.ones((3,3),np.uint8)
    edges = cv2.dilate(edges,kernel,iterations = 2)
    kernel = np.ones((5,5),np.uint8)
    edges = cv2.erode(edges,kernel,iterations = 1)
    lines = cv2.HoughLines(edges, 1, np.pi/180, 250, 100)
    
    
    grid_lines = []
    
    #remove non-horizontal and non-vertical lines
    for line in lines:
        rho,theta = line[0]
        a = np.cos(theta)
        b = np.sin(theta)
        #print(f"Theta: {round(theta, 5)}, a: {round(a, 3)}, b: {round(b,3)}")
        #print(f"Rho: {round(rho, 3)}")
        if abs(a) > 0.999 or abs(b) > 0.999:
            grid_lines.append(line)

    RHO_THRESHOLD = 15
    THETA_THRESHOLD = 0.1

    
    #create a dictionary of similar lines
    similar_lines = {i: [] for i in range(len(grid_lines))}
    for i in range(len(grid_lines)):
        for j in range(len(grid_lines)):
            if i != j:
                rho1, theta1 = grid_lines[i][0]
                rho2, theta2 = grid_lines[j][0]
                if abs(rho1 - rho2) < RHO_THRESHOLD and abs(theta1 - theta2) < THETA_THRESHOLD:
                    similar_lines[i].append(j)

    #create new list of single lines
    used_lines = []
    unique_lines = []
    for i in range(len(grid_lines)):
        if i not in used_lines:
            unique_lines.append(i)
            used_lines.append(i)
            for j in similar_lines[i]:
                used_lines.append(j)
        else:
            #find line which had i in its similar lines and add similar lines of i to it    
            for k in unique_lines:
                if i in similar_lines[k]:
                    similar_lines[k].extend(similar_lines[i])
    
    #remove duplicates
    unique_lines = list(set(unique_lines))
    unique_similar_lines = {i: similar_lines[i] for i in unique_lines}
    for i in unique_lines:
        unique_similar_lines[i] = list(set(unique_similar_lines[i]))   
    
    #create list of unique, averaged lines
    proper_lines = []
    for i in unique_lines:
        similar_lines = unique_similar_lines[i] + [i]
        rho = sum([grid_lines[j][0][0] for j in similar_lines]) / len(similar_lines)
        theta = sum([grid_lines[j][0][1] for j in similar_lines]) / len(similar_lines)
        # rho,theta = line[0]
        a = np.cos(theta)
        b = np.sin(theta)
        x0 = a*rho
        y0 = b*rho
        x1 = int(x0 + 1000*(-b))
        y1 = int(y0 + 1000*(a))
        x2 = int(x0 - 1000*(-b))
        y2 = int(y0 - 1000*(a))
        proper_lines.append([[x1,y1,x2,y2],0])
    
    #print("Proper lines: ", len(proper_lines))
    return proper_lines      
        

def find_intersection(lines):
    intersections = []
    for i in range(len(lines)):
        for j in range(len(lines)):
            line1 = lines[i][0]
            line2 = lines[j][0]
            x1, y1, x2, y2 = line1
            x3, y3, x4, y4 = line2

            det = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4)   
            #print("Det: ",det)
            
            
            
            if  abs(det) > 100000:  
                x = ((x1*y2-y1*x2)*(x3-x4) - (x1-x2)*(x3*y4-y3*x4)) / det
                y = ((x1*y2-y1*x2)*(y3-y4) - (y1-y2)*(x3*y4-y3*x4)) / det
                #check if intersection is within the image
                if 0 <= x < 500 and 0 <= y < 500:
                    #print("Intersection: ", x, y)
                    intersections.append((x, y))
                
    #remove similar intersections
    def get_unique_intersections(intersections, threshold=25):
        unique_intersections = []
        non_unique_intersection_ranges = []
        #print(len(intersections))
        for i in range(len(intersections)):
            x1, y1 = intersections[i]
            unique = True
            for coordinate_range in non_unique_intersection_ranges:
                if coordinate_range[0] <= x1 <= coordinate_range[1] and coordinate_range[2] <= y1 <= coordinate_range[3]:
                    unique = False
                    break
            if unique:
                unique_intersections.append(intersections[i])
                non_unique_intersection_ranges.append((x1-threshold, x1+threshold, y1-threshold, y1+threshold))
        return unique_intersections
    
    unique_intersections = get_unique_intersections(intersections)
    
    #sort first by y coordinate
    sorted_y_intersections = sorted(unique_intersections, key=lambda x: x[1])
    
    #then sort each group of 10 (row) by x coordinate
    sorted_intersections = []
    for i in range(0, len(sorted_y_intersections), 10):
        sorted_intersections[i:i+10] = sorted(sorted_y_intersections[i:i+10], key=lambda x: x[0])
        

    
    return sorted_intersections

def crop_cells(image, intersections, grid_size):
    #find grounps of 4 intersections
    cells = []
    for i in range(0, grid_size-1):
        row = []
        for j in range(0, grid_size-1):
            x1, y1 = intersections[i*grid_size+j]
            x2, y2 = intersections[i*grid_size+j+1]
            x3, y3 = intersections[(i+1)*grid_size+j]
            x4, y4 = intersections[(i+1)*grid_size+j+1]
            
            #scale coordinates to match original image
            scalar_x = image.shape[1] / 500
            scalar_y = image.shape[0] / 500
            x1 *= scalar_x
            x2 *= scalar_x
            x3 *= scalar_x
            x4 *= scalar_x
            
            y1 *= scalar_y
            y2 *= scalar_y
            y3 *= scalar_y
            y4 *= scalar_y
            
            #find the bounding box of the cell
            x_min = min(x1, x2, x3, x4)
            x_max = max(x1, x2, x3, x4)
            y_min = min(y1, y2, y3, y4)
            y_max = max(y1, y2, y3, y4)
            
            #crop cell to exclude gridlines
            x_diff = x_max - x_min
            y_diff = y_max - y_min
            CROP_FACTOR = 0.15
            
            #crop the cell
            cell = image[int(y_min + (y_diff * CROP_FACTOR)):int(y_max - (y_diff * CROP_FACTOR)), 
                         int(x_min + (x_diff * CROP_FACTOR)):int(x_max - (x_diff * CROP_FACTOR))]
            #print("\ncell created , ", cell.shape)
            #print("x_min: ", int(x_min), "x_max: ", int(x_max), "y_min: ", int(y_min), "y_max: ", int(y_max))
            #print(f"i: {i}, j: {j}")

            
            #perform check to ensure cell is valid
            if cell.shape[0] < 10 or cell.shape[1] < 10:
                #print("cell too small")
                continue
            
            
            row.append(cell)

            
        cells.append(row)
        
        
    return cells
        
        
        
def plot_intersections(image, intersections):
    # Load the image
    # image = cv2.imread(image_path)
    
    # Convert image from BGR to RGB (matplotlib uses RGB)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    # Iterate through the intersections and plot stars
    for idx, (x, y) in enumerate(intersections):
        cv2.drawMarker(image, (int(x), int(y)), color=(255, 0, 0), markerType=cv2.MARKER_SQUARE, markerSize=10)
        cv2.putText(image, str(idx), (int(x), int(y)), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)
    # Display the image with matplotlib
    # plt.imshow(image)
    # plt.show()
        
    
def get_cells_from_image_grid(image, grid_size):
    threshold_image = preprocess_image(image)
        
    lines = detect_gridlines(threshold_image)
    #print("Lines detected: ", len(lines))
    

    intersections = find_intersection(lines)
    #print("Intersections found: ", len(intersections))
    
    # plot_intersections(threshold_image, intersections)
    
    cells = crop_cells(image, intersections, grid_size+1)
    #print("Cells divided: ", len(cells))
    
    if len(cells) != grid_size**2:
        raise ValueError("Error in cell division")
    
    return cells
    

