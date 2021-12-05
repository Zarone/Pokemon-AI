local delta_time = 0
local wait_frames = 24

while true do
  delta_time = delta_time + 1
  
  if delta_time % wait_frames == 0 
  then
    print(
      string.format(
        "Map: %d, X: %d, Y: %d, Z: %d", 
        memory.readword(0x0224F90C), 
        memory.readword(0x0224F912, 2), 
        memory.readword(0x0224F91A), 
        memory.readword(0x0224F916)
      )
    )
    delta_time = 0
  end
  emu.frameadvance()
end