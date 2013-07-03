require "Network/Request"

-- http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=demo
Request=Request:alloc():init("http://api.geonames.org/:action:?")
Request:async("citiesJSON", {north=44.1, south=-9.9, east=-22.4, west=55.2, lang="de", username="demo"}, "GET", nil, function (data)
	print (data.response);

	love.event.push('quit')
end)

function love.update(dt)
	Request:update()
end

function love.quit()
	Request:quit()
end