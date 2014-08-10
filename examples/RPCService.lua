local skynet = require "skynet"
local RPCService = {}

local function _checkLogin(params)
	local account = params[2]
	local passwd = params[3]
	print("_checkLogin:", account, passwd)
	local ok, result, errorCode = pcall(skynet.call,"LOGINSERVICE", "lua", "login", params)
    if not ok then
        print("error command")
        return false
    end

    if not result then
        print("failed login, errorCode", errorCode)
        return false
    end
	return true
end

local function _register(params)
    print("_register enter")
    local account = params[2]
    local passwd = params[3]
    print("_register:", account, passwd)
	local ok, result, errorCode = pcall(skynet.call,"LOGINSERVICE", "lua", "register", params)
    if not ok then
        print("error command")
        return false
    end

    if not result then
        print("failed register, errorCode", errorCode)
        return false
    end    
    return true
end

function RPCService.processRPC(params)
    print("processRPC enter")
    local funcName = params[1]
    print("funcName:", funcName)
    -- check login first
    if funcName == "login" then
    	if not _checkLogin(params) then
    		print("login failed", params[2])
    	else
    		print("login success", params[2])
    	end
    elseif funcName == "register" then
        if not _register(params) then
            print("register failed", params[2])
        else
            print("register success", params[2])
        end
    else
        
    end
    
    for k,v in pairs(params) do
        print(k,v)
    end
end

RPCService.handler = {
    "login" = _checkLogin,
    "register" = _register,
}

return RPCService
