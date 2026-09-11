


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

def solve_tail(grid):
    for i in range(9):
        for j in range(9):
            if grid[i][j] == 0:
                for value in range(1,10):
                    
                    if check_value_is_safe(value, i, j, grid):
                        grid[i][j] = value
                        
                        if solve_tail(grid):
                            return True
                        else:
                            grid[i][j] = 0
                return False
    return True

def check_valid(grid):
    #check that initial grid presented is valid. 
    # doesn't mutate grid
    for i in range(9):
        for j in range(9):
            if grid[i][j] != 0:
                val = grid[i][j]
                grid[i][j] = 0
                if not check_value_is_safe(val, i, j, grid):
                    grid[i][j] = val
                    return False
                grid[i][j] = val
    return True


def solve_puzzle(grid):
    # doesn't mutate original grid so original grid can be returned by api
    grid_copy_to_solve = [[grid[i][j] for j in range(9)] for i in range(9)]
    if not check_valid(grid_copy_to_solve):
        raise ValueError("Invalid Sudoku Grid")
    

    if solve_tail(grid_copy_to_solve):
        return grid_copy_to_solve
    
    raise Exception("No solution found")
    
