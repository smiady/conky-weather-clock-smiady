#!/bin/lua

function conky_top()
	local rows = {}
	
	for i = 1,5 do 
	    local name = conky_parse('${top name ' .. i ..'}')
	    local pid = string.gsub(conky_parse('${top pid ' .. i .. '}'), '%s+', '')
	    local cpu = string.gsub(conky_parse('${top cpu ' .. i ..'}'), '%s+', '')
	    local mem = string.gsub(conky_parse('${top mem ' .. i ..'}'), '%s+', '')
	    
	    table.insert(rows, '${goto 8}' .. name .. '${goto 130}' .. pid .. '${goto 250}' .. cpu .. '${goto 350}' .. mem)
	end
	
	return table.concat(rows, '\n')
end
