--!native

-- duster
-- fast and lightweight maid impl ( thats also better than janitor )

type Types = "table" | "function" | "thread" | "Instance" | "RBXScriptConnection"

type TableCleanupMethod = <V>(self: (V & {})) -> ()
	
export type Cleanable =
	| { Disconnect: TableCleanupMethod }
	| { disconnect: TableCleanupMethod }
	| { Cleanup: TableCleanupMethod }
	| { destroy: TableCleanupMethod }
	| { Destroy: TableCleanupMethod }
	| { cleanup: TableCleanupMethod }
	| { Cleanup: TableCleanupMethod }
	| { clear: TableCleanupMethod }
	| { Clear: TableCleanupMethod }
	| RBXScriptConnection
	| Instance 
	| () -> ()
	| thread
	
local DISCONNECT = (function()
	local conn = script.Changed:Connect(function() end)
	local disconnect = conn.Disconnect
	disconnect(conn)
	return disconnect
end)()
local TYPEOF = typeof :: <V>(value: V) -> Types
local DESTROY = game.Destroy
local INSERT = table.insert
local CANCEL = task.cancel
local CLEAR = table.clear
local FIND = table.find
	
local duster = {}

local function REMOVE<V>(t: { V }, index: number)
	local length = #t

	if length ~= 1 then
		local last = t[length]
		t[index] = last
		t[length] = nil
	else
		t[1] = nil
	end
end

-- have to keep the generic, as otherwise typechecker WILL kick and scream
--[[
	Cleans and removes a value from the cleanup array provided
]]
function duster.remove<V>(duster: { Cleanable }, value: V & Cleanable)
	local index = FIND(duster, (value :: any))
	
	if index then
		local type = TYPEOF(value)

		if type == "function" then
			(value :: any)()
		elseif type == "thread" then
			CANCEL((value :: any))
		elseif type == "table" then
			--[[
				these are sorted by what i think atleast is the most likely
				cleanup method names
			]]
			local destroy = (value :: any).Destroy
		
			if destroy then
				destroy(value)
				REMOVE(duster, index)
				return
			end
			local disconnect = (value :: any).Disconnect
		
			if disconnect then
				disconnect(value)
				REMOVE(duster, index)
				return
			end
			local destroy2 = (value :: any).destroy
		
			if destroy2 then
				destroy2(value)
				REMOVE(duster, index)
				return
			end
			local clean = (value :: any).cleanup
		
			if clean then
				clean(value)
				REMOVE(duster, index)
				return
			end
			local disconnect2 = (value :: any).disconnect
		
			if disconnect2 then
				disconnect2(value)
				REMOVE(duster, index)
				return
			end
			local clear2 = (value :: any).Clear
	
			if clear2 then
				clear2(value)
				REMOVE(duster, index)
				return
			end
			local clear = (value :: any).clear
		
			if clear then
				clear(value)
				REMOVE(duster, index)
				return
			end
			local clean2 = (value :: any).Cleanup
		
			if clean2 then
				clean2(value)
				REMOVE(duster, index)
				return
			end
		elseif type == "Instance" then
			DESTROY((value :: any))
		elseif type == "RBXScriptConnection" then
			DISCONNECT((value :: any))
		end
		REMOVE(duster, index)
	end
end

--[[
	Cleans up every value in the clenaup array and clears the cleanup array
]]
function duster.clear(duster: { Cleanable })
	for _, value in duster do
		local type = TYPEOF(value)

		if type == "function" then
			(value :: any)()
		elseif type == "thread" then
			CANCEL((value :: any))
		elseif type == "table" then
			--[[
				these are sorted by what i think atleast is the most likely
				cleanup method names
			]]
			local destroy = (value :: any).Destroy
		
			if destroy then
				destroy(value)
				continue
			end
			local disconnect = (value :: any).Disconnect
		
			if disconnect then
				disconnect(value)
				continue
			end
			local destroy2 = (value :: any).destroy
		
			if destroy2 then
				destroy2(value)
				continue
			end
			local clean = (value :: any).cleanup
		
			if clean then
				clean(value)
				continue
			end
			local disconnect2 = (value :: any).disconnect
		
			if disconnect2 then
				disconnect2(value)
				continue
			end
			local clear2 = (value :: any).Clear
	
			if clear2 then
				clear2(value)
				continue
			end
			local clear = (value :: any).clear
		
			if clear then
				clear(value)
				continue
			end
			local clean2 = (value :: any).Cleanup
		
			if clean2 then
				clean2(value)
			end
		elseif type == "Instance" then
			DESTROY((value :: any))
		elseif type == "RBXScriptConnection" then
			DISCONNECT((value :: any))
		end
	end
	CLEAR(duster)
end

--[[
	Inserts a value to the duster, with the option of providing a cleanup function to use to clean the value.
	This function is eqvilent to `table.insert`, except for the fact it allows for a cleanup function. 
	It is reccomended to use `table.insert` instead if possible, as it will be much more faster as it is fastcalled.
]]
function duster.insert<V>(
	duster: { Cleanable }, 
	value: V & Cleanable, 
	cleaner: (((value: V) -> ()) | () -> ())?
): V
	if cleaner then
		INSERT(duster, function()
			(cleaner :: any)(value)
		end)
	else
		INSERT(duster, value :: any)
	end
	return value
end
	
return table.freeze(duster) 
	
	