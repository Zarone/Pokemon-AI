# AI 1: Showdown Data and Backpropagation

## Training

The actual _thing_ being trained is a neural network built in python. Using a supervised learning method, feed in the collected showdown logs as well as game result serving as the correct answer.

## Use

set constants, actual values subject to change

    TOP_WORST = 2
    TOP_BEST = 2
    SEARCH_DEPTH = 2

The weights from the python neural network are saved to a json file. Then that file is loaded into lua, and a simple feedforward function is in lua. The emulated gamestate is loaded into a clean gamestate object. Then call RecursionFunction(gamestate, SEARCH_DEPTH)

### RecursionFunction (gamestate, depth)

All possible moves from gamestate are attempted, their game logs exported and evaluated, then that data goes back into the feedforward network and return a ranking for this gamestate. When multiple outcomes are possible (crit, flinch, etc), the rank (between 0 and 1) is the the sum of each possible rank multiplied by the chance of that happening. This should hopefully generate an array that looks like:

    [
        // each row represents one of player1's choices
        // each column represents one of player2's choices
        // the actual values in the elements are [player1 choice, player2 choice, estimated win chance]
        [p1: option1, p2: option1], [p1: option1, p2: option2], [p1: option1, p2: option3]
        [p1: option2, p2: option1], [p1: option2, p2: option2], [p1: option2, p2: option3]
        [p1: option3, p2: option1], [p1: option3, p2: option2], [p1: option3, p2: option3]
    ]

helper function

    function evaluate_row(array)
        sum = 1
        for element in array
            sum *= element^2

set variables

    row_averages = []

for each row find the worst _"TOP_WORST"_ options (since those are most likely what the opponent will do), and delete the remaining values. Then push { row_num: this row number, average: evaluate(remaining row) } to row_averages

if (depth - 1) > 0:

- find the best _"TOP_BEST"_ rows based on row_averages, and delete all other rows

- for each element in this new trimmed array, change their value into RecursionFunction(gamestate given action, depth-1)

- find the new row_averages and return the item corresponding to the new highest value in row_averages

else:

- simply find the best item in row_averages and return the corresponding best action
