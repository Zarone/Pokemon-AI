local lmd = require "local_map"

-- the purpose of "mode" is to determine what
-- game actions the bot is attempting to perform
-- 0 => bot needs to decide
-- 1 => navigation
local mode = 1

while true do
    if (mode == 1) then
        lmd.update_map(true)
    end

    emu.frameadvance()
end