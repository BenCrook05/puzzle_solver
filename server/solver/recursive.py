


def check_value_is_safe(value, row, column, grid):
    #doesn't mutate grid
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


# def solve_tail(grid):
#     for i in range(9):
#         for j in range(9):
#             if grid[i][j] == 0:
#                 for value in range(1,10):
#
#                     if check_value_is_safe(value, i, j, grid):
#                         grid[i][j] = value
#
#                         if solve_tail(grid):
#                             return True
#                         else:
#                             grid[i][j] = 0
#                 return False
#     return True


def find_mrv_cell(grid):
    min_candidates = 10
    best_cell = None
    best_values = []

    for r in range(9):
        for c in range(9):
            if grid[r][c] == 0: #ignore cells with hard coded values
                values = get_possible_values(grid, r, c)
                if len(values) == 0:
                    return (r,
                            c), []  #no solution because 0 candidates for cell
                if len(values) < min_candidates:
                    min_candidates = len(values)
                    best_cell = (r, c)
                    best_values = values
                    if min_candidates == 1:
                        return best_cell, best_values

    return best_cell, best_values


def solve_mrv(grid):
    cell, values = find_mrv_cell(grid)
    if cell is None:
        return True  # no cells needing to be filled so grid complete
    if len(values) == 0:
        return False  # no solution so triggers backtrack

    r, c = cell
    for val in values:
        grid[r][c] = val
        if solve_mrv(grid):
            return True
        grid[r][
            c] = 0  # triggers backtrack

    return False





def get_possible_values(grid, row, column):
    vals = []
    for val in range(1,10):
        if check_value_is_safe(val, row, column, grid):
            vals.append(val)

    return vals





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



    if solve_mrv(grid_copy_to_solve):
        return grid_copy_to_solve

    #can we identify the cause of the problem?


    
    raise Exception("No solution found")
    
