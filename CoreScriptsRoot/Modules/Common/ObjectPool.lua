--	// FileName: ObjectPool.lua
--	// Written by: TheGamer101
--	// Description: An object pool class used to avoid unnecessarily instantiating Instances.

local game = game
local script = script
local setmetatable = setmetatable
local type = type
local Instance = Instance local Instance_new = Instance.new

local table = table
	local remove = table.remove
	local function insert(tbl, index, value)
		if value ~= nil then
			if type(index) == "number" then
				local tlen = #tbl
				for i = tlen, index do
					tbl[i + 1] = tbl[i]
				end
				tbl[index] = value
			end
		else
			tbl[#tbl + 1] = value
		end
	end

local module = { }
--////////////////////////////// Include
--//////////////////////////////////////
local modulesFolder = script.Parent

--////////////////////////////// Methods
--//////////////////////////////////////
local methods = { }
methods.__index = methods

function methods:GetInstance(className)
	if self.InstancePoolsByClass[className] == nil then
		self.InstancePoolsByClass[className] = { }
	end
	local availableInstances = #self.InstancePoolsByClass[className]
	if availableInstances > 0 then
		local instance = self.InstancePoolsByClass[className][availableInstances]
		remove(self.InstancePoolsByClass[className])
		return instance
	end
	return Instance_new(className)
end

function methods:ReturnInstance(instance)
	if self.InstancePoolsByClass[instance.ClassName] == nil then
		self.InstancePoolsByClass[instance.ClassName] = { }
	end
	if #self.InstancePoolsByClass[instance.ClassName] < self.PoolSizePerType then
		insert(self.InstancePoolsByClass[instance.ClassName], instance)
	else
		instance:Destroy()
	end
end

--///////////////////////// Constructors
--//////////////////////////////////////

function module.new(poolSizePerType)
	local obj = setmetatable({ }, methods)
	obj.InstancePoolsByClass = { }
	obj.Name = "ObjectPool"
	obj.PoolSizePerType = poolSizePerType
	return obj
end

return module
