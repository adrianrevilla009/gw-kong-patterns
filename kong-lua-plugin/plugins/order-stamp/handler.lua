local OrderStamp = {
  PRIORITY = 1000,
  VERSION = "0.1.0",
}

-- Runs before the request is proxied: stamp the upstream request.
function OrderStamp:access(conf)
  kong.service.request.set_header(conf.header_name, conf.message)
end

-- Runs when response headers arrive: echo the stamp to the client.
function OrderStamp:header_filter(conf)
  kong.response.set_header(conf.header_name, conf.message)
end

return OrderStamp
