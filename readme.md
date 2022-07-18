# Showdown Data and Backpropagation AI

## Training

The actual _thing_ being trained is a neural network built in python. Using a supervised learning method, feed in the collected showdown logs as well as game result serving as the correct answer.

## Use

set constants

    TOP_WORST
    TOP_BEST
    SEARCH_DEPTH

The weights from the python neural network are saved to a json file. Then that file is loaded into lua, and a simple feedforward function is in lua. The emulated gamestate is loaded into a clean gamestate object. Then call RecursionFunction(gamestate, SEARCH_DEPTH)

### RecursionFunction (gamestate, depth)

It's worth noting that this is not the actual name of the function, it's really `void *evaluate_move` in a C subroutine. 

All possible moves from gamestate are attempted, their game logs exported and evaluated, then that data goes back into the feedforward network and return a ranking for this gamestate. The game simulator squashes randomization, such that only the most likely outcome is computed.

This array of moves is passed through a recursive tree with a depth of SEARCH_DEPTH. More showdown simulations run in order to refine the quality of a given estimate. In the end you have an array of possible moves, and the associated win-rate estimate. And so the best move is chosen, and entered back into the game via automated controller input.
