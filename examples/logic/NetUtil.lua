local socket = require "socket"
local netpack = require "netpack"
local jsonpack = require "jsonpack"

NetUtil = {}

function NetUtil.send(fd, protoId, params)
    socket.write(fd, netpack.pack(jsonpack.pack(protoId, params)))
end

return NetUtil
