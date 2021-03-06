gmd = {}

gmd.map = {
    -- map1 = {
    --     { map2, x, y, out_x, out_y }
    -- }
}

gmd.fully_explored = {

}

local function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

gmd.go_to_map = function(current_map, current_x, current_y, to_map) -- returns path
    
    -- Dijkra's algorithm, because there's no heuristic

    -- print("")
    -- print("")
    -- print("going to", to_map)
    -- print("go to map: start")
    -- print("current map", current_map)
    -- print("current global map", gmd.map)

    if type(to_map) == "number" then
        to_map = {to_map}
    end

    -- this is in situations where there are
    -- multiple destinations which would be
    -- acceptable. This variable tracks which
    -- map ended up being found most efficient
    local found_map_id

    -- Create a queue
    local queue = {}

    -- create a list to track visited nodes
    local visited_nodes = {}

    local best_path = nil
    local best_path_length = 1E10

    -- add current item to list {current_map, current_x, current_y, 0, {}}
    -- the zero is for heuristic distance
    -- the table is for the path
    table.insert(queue, {current_map, current_x, current_y, 0, {}})

    -- loop through queue as long as the queue is not empty
    while #queue > 0 do
        -- find item at start of queue
        -- store item as variable
        local checking_node = queue[1]

        -- print("")
        -- print("checking_node", checking_node)
        -- print("queue", queue)
        -- print("visited_nodes", visited_nodes)

        -- pop it
        table.remove(queue, 1)

        -- find all places player could go from current item
        local all_neighbors = {}

        -- if the map object currently has data on this new map
        if gmd.map[checking_node[1]] ~= nil then
            for _, neighbor in pairs(gmd.map[checking_node[1]]) do
                
                -- checks if visited_nodes has any element with the same map as this neighbor
                local map_in_visited = visited_nodes[neighbor[1]] ~= nil

                -- tracks if neighbor has been visisted
                local neighbor_has_been_visited = false

                -- print("neighbor", neighbor, "map_in_visited", map_in_visited)

                if map_in_visited then
                    for _, visited_node in pairs( visited_nodes[ neighbor[1] ] ) do
    
                        -- visited_node is in format {x, y}
                        -- print("visited_node", visited_node)
    
                        if visited_node[1] == neighbor[4] and visited_node[2] == neighbor[5] then
                            -- print("matched, has been visited")
                            neighbor_has_been_visited = true
                            break
                        end
                    end
    
                    
                end

                if not neighbor_has_been_visited then
    
                    local cost_to_neighbor = distance(checking_node[2], checking_node[3], neighbor[2], neighbor[3])
    
                    local new_path = {}
    
                    local last_path = unpack(checking_node[5])
    
                    if (last_path ~= nil) then
                        new_path = {last_path, {neighbor[2], neighbor[3]}}
                    else
                        new_path = {{neighbor[2], neighbor[3]}}
                    end

                    local this_neighbor_path_length = checking_node[4] + cost_to_neighbor
    
                    local neighbor_is_target_destination = false

                    for k, target_map in pairs(to_map) do
                        if neighbor[1] == target_map then
                            neighbor_is_target_destination = true
                            found_map_id = k
                        end
                    end

                    if neighbor_is_target_destination then 
                        if (this_neighbor_path_length < best_path_length) then
                            best_path_length = this_neighbor_path_length
                            best_path = new_path
                        end
                    end
    
                    
                    -- add item to list of visited nodes
                    if visited_nodes[neighbor[1]] == nil then
                        visited_nodes[neighbor[1]] = {}
                    end
                    table.insert(visited_nodes[neighbor[1]], {neighbor[4], neighbor[5]})
                    

                    -- this if statement is triggers if this neighbor would be the longest length in the queue
                    if #queue == 0 or this_neighbor_path_length >= queue[#queue][4] then
                        table.insert(queue, {neighbor[1], neighbor[4], neighbor[5], this_neighbor_path_length, new_path})
                    else
                        for i, v in ipairs(queue) do
                            if (this_neighbor_path_length < v[4]) then
                                table.insert(queue, i, {neighbor[1], neighbor[4], neighbor[5], this_neighbor_path_length, new_path})
                                break
                            end
                        end
                    end
                end
                
            end
        end        
    end
    
    return best_path, found_map_id

end

-- gmd.map[1] = {{2, 3, 4, 2, 2}, {4, 3, 1, 4, 6}}
-- gmd.map[2] = {{3, 1, 1, 4, 1}}

-- gmd.go_to_map(1, 3, 3, 3)

return gmd
