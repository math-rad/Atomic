local utility = {}


local SUPERSTRING = {}
SUPERSTRING.__index = function(self, i)
	return rawget(self, "string"):sub(i, i) 
end

SUPERSTRING.__call = function(...)
	print(...)
end

function utility.superString(str: string)
	return setmetatable({
		["string"] = str,
		["gmatch"] = function(self, ...)
			return string.gmatch(self.string, ...)
		end,
	}, SUPERSTRING)
end

function utility.index(t1, t2)
	return setmetatable(t1, {
		["__index"] = t2
	})
end

function utility.tlr(t)
	return utility.index(t, table)
end



local pt = "%s/%s"  -- path template 
function utility:iter(i, t, v, p)
	if not p then
		p = ''
	end
	if type(i) == "table" then
		t(i, p)
		for indx, I in i do
			self:iter(I, t, v, pt:format(p, indx))
		end
	else
		v(i, p)
	end
end

function utility:deepFreeze(t)
	self:iter(t, table.freeze)
end


return utility
