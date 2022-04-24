output_manager = {}

output_manager.current_sequence_index = 1
output_manager.progress_of_output = 0
output_manager.pause_progress = 0
output_manager.between_actions = false

output_manager.reset = function()
    output_manager.current_sequence_index = 1
    output_manager.progress_of_output = 0
    output_manager.pause_progress = 0
    output_manager.between_actions = false
end

output_manager.press = function(sequence, time_between_actions)
    -- sequence looks like {{buttonMap1, 10}, {buttonMap2, 5}}
    
    -- that would mean joypad.set(0, buttonMap1) for 10 frame, then do joypad.set(0, buttonMap2) for 5

    if output_manager.current_sequence_index > #sequence then
        output_manager.reset()
    end

    if output_manager.between_actions and output_manager.pause_progress < time_between_actions then
        output_manager.pause_progress = output_manager.pause_progress + 1
    elseif output_manager.between_actions then
        output_manager.pause_progress = 0
        output_manager.between_actions = false
    else

        output_manager.progress_of_output = output_manager.progress_of_output + 1
        -- print("sequence", sequence)
        -- print("output_manager.current_sequence_index", output_manager.current_sequence_index)
        button_info = sequence[output_manager.current_sequence_index][1]
        joypad.set(0, button_info)
        -- print(button_info)

        -- if current button press is completed 
        if output_manager.progress_of_output > sequence[output_manager.current_sequence_index][2] then

            -- print("completed: ", sequence[output_manager.current_sequence_index][1])

            -- if there's another output in the sequence
            if output_manager.current_sequence_index < #sequence then
                output_manager.current_sequence_index = output_manager.current_sequence_index + 1
                output_manager.progress_of_output = 0
                output_manager.between_actions = true
                -- return false
            else
                output_manager.current_sequence_index = 1
                output_manager.progress_of_output = 0
                output_manager.pause_progress = 0
                output_manager.between_actions = true
                return true
            end
        end

    end
    return false
end

output_manager.pressA = function()
    output_manager.current_sequence_index = 1
    output_manager.press({
        {{A = true}, 5}
    }, 25)
end

done = false

return output_manager

-- while true do
--     -- joypad.set({down = true})
--     if not done then
--         done = output_manager.press(
--             {
--                 {{A = true}, 5}, 
--                 {{up = true}, 5}, 
--                 {{left = true}, 5}, 
--                 {{down = true}, 5}, 
--                 -- {{right = true}, 5}, 
--                 {{A = true}, 5},
--             }, 
--             60
--         )
--     end
--     emu.frameadvance()
-- end