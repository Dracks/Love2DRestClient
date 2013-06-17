require "Utils/ObjectOriented"

List=inheritsFrom(nil)
function List:init ()
	self.first=0
	self.last = -1
	return self;
end
-- Now, we can insert or remove an element at both ends in constant time:
function List:pushFirst (value)
	--print(self, self.first, self.last)
	local first = self.first - 1
	self.first = first
	self[first] = value
end
    
function List:push (value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

function List:popFirst ()
	local first = self.first
	if first > self.last then error("list is empty") end
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1
	return value
end

function List:pop ()
	local last = self.last
	if self.first > last then error("list is empty") end
	local value = self[last]
	self[last] = nil         -- to allow garbage collection
	self.last = last - 1
	return value
end

function List:foreach(call)
	local index=self.first
	while index<=self.last do
		call(self[index])
		index=index+1
	end
end

function List:length()
	return self.last-self.first+1
end

function List:get()
	local clone={}
	for i=self.first,self.last do
		table.insert(clone, self[i])
	end
	return clone
end
