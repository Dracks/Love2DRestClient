--
-- Created by IntelliJ IDEA.
-- User: dracks
-- Date: 6/17/13
-- Time: 1:34 AM
-- To change this template use File | Settings | File Templates.
--

require "Utils/ObjectOriented"
require "Utils/List"

-- local http = require("socket.http")
local json=require("libraries/dkjson")

Request=inheritsFrom(nil);
function Request:init()
	self.thread=love.thread.newThread("thread", "Network/AsyncRequest.lua")
	self.thread:start()
	self.busy=false;
	self.asyncResponse=List:alloc():init()
	self.asyncTasks=List:alloc():init();
end

function Request:launchTask()
	if self.busy==false and self.asyncTasks:length()>0 then
		self.thread:set("action",self.asyncTasks:popFirst());
		self.busy=true
	end
end

function Request:async(action, arguments, method, header, response)
	self.asyncResponse:push(response);
	local data={action=action, arguments=arguments, method=method, header=header }
	self.asyncTasks:push(json.encode(data));
	self:launchTask();
end

function Request:update()
	local ret=self.thread:get("result")
	if ret~=nil then
		local method=self.asyncResponse:popFirst()
		-- print("Request:update", method)
		method(json.decode(ret));
		self.thread:set("endaction", true);
		self.busy=false;
	end
	self:launchTask();
end

function Request:quit()
	self.thread:set("action", json.encode({action="quit"}))
	self.thread:wait()
end

Request:init()