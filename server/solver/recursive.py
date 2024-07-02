import timeout_decorator

def check_value_is_safe(value, row, column, grid):
    #check row
    row_values = grid[row]
    if value in row_values:
        return False
    #check column
    column_values = [grid[i][column] for i in range(9)]
    if value in column_values:
        return False
    #check box
    box_row = row//3
    box_column = column//3
    box_values = []
    for i in range(3):
        for j in range(3):
            box_values.append(grid[box_row*3 + i][box_column*3 + j])
    if value in box_values:
        return False
    return True


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


@timeout_decorator.timeout(6)
def solve_puzzle(grid):
    solved_grid = solve(grid)
    return solved_grid


grid = [[0, 0, 8, 7, 0, 0, 1, 0, 3],
        [7, 0, 0, 0, 0, 9, 0, 0, 2],
        [0, 0, 0, 0, 5, 0, 0, 7, 0],
        [0, 8, 0, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0, 0, 4, 0, 0],
        [6, 7, 0, 0, 4, 5, 0, 0, 0],
        [0, 0, 3, 0, 0, 7, 6, 2, 0],
        [0, 0, 1, 0, 0, 0, 0, 5, 0],
        [0, 5, 0, 3, 0, 2, 0, 0, 4],
    ]

solve(grid)
print(grid)