-- open pokemon showdown client in write mode

-- read memory locations from emulator, format into battleState.json
-- mod pokemon showdown to read battleState.json and pass state in
    -- some variables are needed by battleState but not the AI,
    -- IVs, EVs, moveset, nature, ability, level, happiness

-- mod pokemon showdown to write it's log to file

-- create a gamestate object, passing in the current log file (last.txt)

-- start loop
    -- pass the current gamestate to a decision making function,
    -- that function returns a gameaction
        -- this "decision making function" would either be our NEAT trained AI,
        -- or a minmax function incorporating the game state evaluater AI trained
        -- through backpropagation from showdown matches

    -- format game action into pokemon showdown command string 
    -- pass that string into the pokemon showdown write stream
    
    -- pass the new current log file to the gamestate
    -- run next_turn function
        -- Do not free this object from memory,
        -- we need to remember the current game state

    -- if next_turn returns true,
    -- that means the log has given "|win" or "|tie" and that the game is over
        -- end loop

