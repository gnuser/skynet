local skynet = require "skynet"
local jsonpack = require "jsonpack"
local netpack = require "netpack"
local socket = require "socket"

package.path = package.path .. ";./?.lua;./examples/?.lua"
local RPCService = require "RPCService"
local CMD = {}

local client_fd
local isLoginSuccess = false

local loginInfo = {} -- 记录登陆信息,如账号

local function send_client(v)
	socket.write(client_fd, netpack.pack(jsonpack.pack(0, {true, v})))
end

local function response_client(session,v)
	socket.write(client_fd, netpack.pack(jsonpack.response(session,v)))
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return jsonpack.unpack(skynet.tostring(msg,sz))
	end,
	dispatch = function (_, _, session, args)
		local ok, status, result = pcall(RPCService.processRPC, client_fd, args)
--		local ok, result = pcall(skynet.call,"RPCSERVICE", "lua", args)
--		if ok then
--			response_client(session, { true, result })
--		else
--			response_client(session, { false, "Invalid command" })
--		end
	end
}

function CMD.start(gate , fd)
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
	--send_client "Welcome to skynet"
end

function CMD.stop(gate, fd)
    skynet.call("LOGICSERVICE", "lua", fd, {"logout"})
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
        if not f then
            print("agent has no function define for", command)
            return
        end
		skynet.ret(skynet.pack(f(...)))
	end)
end)
