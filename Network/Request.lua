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

local threadCounter=0

Request=inheritsFrom(nil);
function Request:init(url)
	self.thread=love.thread.newThread('Network/AsyncRequest.lua')
	local channelName='RequestChannel'..threadCounter
	threadCounter=threadCounter+1
	self.channel={
		action=love.thread.getChannel(channelName..'action'),
		result=love.thread.getChannel(channelName..'result'),
		-- endaction=love.thread.getChannel(channelName..'endaction')
	}
	self.thread:start(channelName, url)
	self.busy=false;
	self.asyncResponse=List:alloc():init()
	self.asyncTasks=List:alloc():init();
	return self;
end

function Request:launchTask()
	if self.busy==false and self.asyncTasks:length()>0 then
		self.channel.action:push(self.asyncTasks:popFirst());
		self.busy=true
	end
end

function Request:async(action, arguments, method, header, response)
	self.asyncResponse:push(response);
	-- print (json.encode(arguments))
	-- print (json.encode(header))
	if header==nil then
		header={}
	end
	local data={action=action, arguments=arguments, method=method, header=header }
	self.asyncTasks:push(json.encode(data));
	self:launchTask();
end

function Request:update()
	local ret=self.channel.result:pop()
	if ret~=nil then
		local method=self.asyncResponse:popFirst()
		-- print("Request:response", method, ret)
		method(json.decode(ret));
		--self.channel.endaction:push(true);
		self.busy=false;
	end
	self:launchTask();
end

function Request:quit()
	self.channel.action:push(json.encode({action="quit"}))
	self.thread:wait()
end
