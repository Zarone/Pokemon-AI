gmd = {}

gmd.map = {
    -- map1 = {
    --     { map2, x, y, out_x, out_y }
    -- }
}

function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

gmd.go_to_map = function(current_map, current_x, current_y, to_map) -- returns path
    -- Dijkra's Algorithm, because there's no heuristic

    -- Create a queue
    queue = {}

    -- create a list to track visited nodes
    visited_nodes = {}

    -- add current item to list {current_map, current_x, current_y, 0, {}}
    -- the zero is for heuristic distance
    -- the table is for the path
    table.insert(queue, {current_map, current_x, current_y, 0, {}})

    -- loop through queue as long as the queue is not empty
    while #queue > 0 do
        -- find item at start of queue
        -- store item as variable
        checking_node = queue[1]

        -- pop it
        table.remove(queue, 1)

        -- find all places player could go from current item
        all_neighbors = {}

        if gmd.map[checking_node[1]] ~= nil then
            for _, neighbor in pairs(gmd.map[checking_node[1]]) do
                
                -- checks if visited_nodes has any element with the same map as this neighbor
                map_in_visited = visited_nodes[neighbor[1]] ~= nil
                
                neighbor_has_been_visited = false
                for _, visited_node in pairs(visited_nodes) do
                    if visited_node[1] == neighbor[2] and visited_node[2] == neighbor[3] then
                        neighbor_has_been_visited = true
                        break
                    end
                end
    
                if not neighbor_has_been_visited then
    
                    cost_to_neighbor = distance(checking_node[2], checking_node[3], neighbor[2], neighbor[3])
                    -- print(checking_node[2], checking_node[3], neighbor[2], neighbor[3], cost_to_neighbor)
        
                    -- inserts the cheapest neighbors furthest at the start 
                    i = 1
                    while i < #all_neighbors + 1 and cost_to_neighbor > all_neighbors[i][4] do
                        i = i + 1
                    end
    
                    new_path = {}
    
                    last_path = unpack(checking_node[5])
    
                    if (last_path ~= nil) then
                        new_path = {last_path, {neighbor[2], neighbor[3]}}
                    else
                        new_path = {{neighbor[2], neighbor[3]}}
                    end
    
                    if neighbor[1] == to_map then 
                        -- print(last_path, neighbor, to_map)
                        return new_path
                    end
    
                    -- {to_map, to_x, to_y, cost, path}
                    all_neighbors[i] = {neighbor[1], neighbor[4], neighbor[5], checking_node[4] + cost_to_neighbor, new_path}
                end
            end
    
            -- print(all_neighbors)
            for _, sorted_neighbor in pairs(all_neighbors) do
                table.insert(queue, sorted_neighbor)
            end
        end

        -- add item to list of visited nodes
        if visited_nodes[checking_node[1]] == nil then
            visited_nodes[checking_node[1]] = {}
        end
        table.insert(visited_nodes[checking_node[1]], {checking_node[2], checking_node[3]})
        
    end
    return false

end

-- gmd.map[1] = {{2, 3, 4, 2, 2}, {4, 3, 1, 4, 6}}
-- gmd.map[2] = {{3, 1, 1, 4, 1}}

-- print(gmd.go_to_map(1, 3, 3, 3))

return gmd
