--[[
	Filename: CommonUtil.lua
	Written by: dbanks
	Description: Common work.
--]]
local table = table local sort = table.sort

--[[ Classes ]]--
local CommonUtil = { }

-- Concatenate these two tables, return result.
function CommonUtil.TableConcat(t1, t2)
	local t1len, t2len = #t1, #t2
	for i = 1, t2len do
		t1[t1len + 1] = t2[i]
	end
	return t1
end

-- Instances have a "Name" field.  Sort 
-- by that name,
function CommonUtil.SortByName(items)	
	function compareInstanceNames(i1, i2) 
		return (i1.Name < i2.Name)
	end
	sort(items, compareInstanceNames)
	return items
end

return CommonUtil
