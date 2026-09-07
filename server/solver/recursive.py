from string import templatelib
from _typeshed import _type_checker_internals
from string import templatelib
import threading


def check_value_is_safe(value, row, column, grid):
    #check row
    if value in grid[row]:
        return False
    #check column
    for r in range(9):
        if grid[r][column] == value:
            return False

    #check box
    box_row = (row//3) * 3
    box_column = (column//3) * 3
    for r in range(box_row, box_row+3):
        for c in range(box_column, box_column+3):
            if grid[r][c] == value:
                return False

    return True

# def check_value_is_safe(value, row, column, grid):



def solve(grid):
    for i in range(9):
        for j in range(9):
            if grid[i][j] == 0:
                for value in range(1,10):
                    if check_value_is_safe(value, i, j, grid):
                        grid[i][j] = value
                        #recursively calls solve on new grid
                        #backtracks if no valid solutions from cell value
                        if solve(grid) == True:
                            return True
                        else:
                            grid[i][j] = 0
                return False
    return True

def solve_tail(grid, empty_grid):
    for i in range(9):
        for j in range(9):
            if empty_grid[i][j] == 0:
                for value in range(1,10):
                    
                    if check_value_is_safe(value, i, j, empty_grid):
                        empty_grid[i][j] = value
                        
                        if solve_tail(empty_grid):
                            return True
                        else:
                            empty_grid[i][j] = 0
                return False
    return True

def check_valid(grid):
    #check that initial grid presented is valid. 
    for i in range(9):
        for j in range(9):
            if grid[i][j] != 0:
                if not check_value_is_safe(grid[i][j], i, j, grid):
                    return False
    return True


def solve_puzzle(grid):
    
    # def solve_thread():
    #     solve(grid)
        
    # thread = threading.Thread(target=solve_thread)
    # thread.start()
    # thread.join(timeout=6)    
    # print(grid)
    # if thread.is_alive():
    #     raise TimeoutError("Solving the puzzle took too long")
    # else:
    #     return grid


    #create copy of grid so as not to mutate original
    empty_grid = [[grid[i][j] for j in range(9)] for i in range(9)]

    if not check_valid(empty_grid):
        raise ValueError("Invalid Sudoku Grid")
    

    if solve_tail(grid, empty_grid):
        return empty_grid
    
    raise Exception("No solution found")
    
