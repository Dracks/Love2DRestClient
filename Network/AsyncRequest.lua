--
-- Created by IntelliJ IDEA.
-- User: dracks
-- Date: 6/17/13
-- Time: 11:59 AM
-- To change this template use File | Settings | File Templates.
--

require "Utils/ObjectOriented"
local http = require("socket.http")
local json=require("libraries/dkjson")
local ltn12 = require("ltn12")
local url = require("socket.url")

AsyncRequest=inheritsFrom(nil);

function AsyncRequest:init()
	self.thread= love.thread.getThread();
	return self;
end


function AsyncRequest:request(action, arguments, header, method)
	-- print("Request", action, arguments, header)
	local textArguments=""
	local rtable={};
	if header==nil then
		header={}
	end

	local request={
		--url="http://www.server.com/api.php?action="..action,
		url="http://api.geonames.org/"..action.."?",
		method=method,
		headers=header,
		sink = ltn12.sink.table(rtable)
	}
	if arguments~=nil then
		for key, value in pairs(arguments) do
			--print ("arguments", key, value);
			textArguments=textArguments.."&"..key.."="..value
		end
	end
	--print "Step 1"

	if method=="GET" then
		request.url= request.url..textArguments;
	else
		--print "s11"
	 	request.headers["Content-Length"] = tostring(string.len(textArguments))
		--print "s12"
		request.headers["Content-Type"] = "application/x-www-form-urlencoded"
		--print "s13"
		request.source = ltn12.source.string(textArguments)
	end
	--print "step 2"
	--print(request.url);

	local okCode, code, header=http.request(request);
	--print (okCode, code, header);

	local response=table.concat(rtable);

	--print(response,code,header)
	self.thread:set("result", json.encode({response=response, header=header, code=code}));
	self.thread:demand("endaction");
end

function AsyncRequest:run()
	local active=true;
	local data;
	while active do
		--print("Wait")
		local rawData=self.thread:demand("action");
		--print(rawData);
		data=json.decode(rawData)
		if data.action~="quit" then
			--print (data.arguments);
			AsyncRequest:request(data.action, data.arguments, data.header, data.method)
		else
			active=false;
		end
	end
end

AsyncRequest:init():run();