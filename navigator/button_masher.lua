local button_masher = {}
button_masher.counter = 0
button_masher.hold_for = 10
button_masher.delay = 30
button_masher.is_holding = false
button_masher.total_time = 0

button_masher.reset_time = function()
    button_masher.total_time = 0
    button_masher.counter = 0
end

button_masher.mash = function(button_info, time_limit)

    if time_limit ~= nil then
        if button_masher.total_time > time_limit then
            return true
        else
            button_masher.total_time = button_masher.total_time + 1
        end
    end

    -- if we're not holding "A" and we're not supposed to
    if (not button_masher.is_holding) and button_masher.counter < button_masher.delay then
        button_masher.counter = button_masher.counter + 1
    -- if we're not holding "A" and we're supposed to
    elseif (not button_masher.is_holding) and button_masher.counter >= button_masher.delay then
        button_masher.is_holding = true
        button_masher.counter = 0
    -- if we're holding A and we're supposed to
    elseif button_masher.is_holding and button_masher.counter < button_masher.hold_for then
        joypad.set(0, button_info)
        button_masher.counter = button_masher.counter + 1
    -- if we're holding A and we're no longer supposed to
    elseif button_masher.is_holding and button_masher.counter >= button_masher.hold_for then
        button_masher.is_holding = false
        button_masher.counter = 0
    end

    return false
end

return button_masher