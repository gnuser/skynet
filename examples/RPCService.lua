local skynet = require "skynet"
local RPCService = {}

local function _checkLogin(client_fd, params)
	local account = params[1]
	local passwd = params[2]
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
    -- enter world
    local ok, result, errorCode = pcall(skynet.call,"LOGICSERVICE", "lua", client_fd, {"enterWorld", account})
    -- 检查重复登陆
    if not ok then
        print("enterWorld failed", errorCode)
        return false
    else
        if not result then
            return false
        end
    end
	return true, {account=params[1]}
end

local function _register(client_fd, params)
    print("_register enter")
    local account = params[1]
    local passwd = params[2]
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

function _delAccount(client_fd, params)
    print("_delAccount enter")
    local account = params[1]
    local ok, reuslt, errorCode = pcall(skynet.call, "LOGINSERVICE", "lua", "clearAccount", params)
    return 
end

function RPCService.processRPC(client_fd, params)
    print("processRPC enter")
    local funcName = params[1]
    print("funcName:", funcName)

    local newParams = {}
    for i=2, #params do
        table.insert(newParams, params[i])
    end

    local result = nil
    local status = true
    -- check login first
    if funcName == "login" then
        -- TODO, 踢号
        status, result = _checkLogin(client_fd, newParams)
    	if not status then
    		print("login failed", params[2])
            return false
    	else
    		print("login success", params[2])
            return true, result
    	end
    elseif funcName == "register" then
        if not _register(client_fd, newParams) then
            print("register failed", params[2])
            return false
        else
            print("register success", params[2])
            return true, params[1]
        end
    elseif funcName == "delAccount" then
        -- TODO, 检查是否在线
        if not _delAccount(client_fd, newParams) then
            print("del account failed", params[2])
            return false
        else
            print("del account success", params[2])
            return true, params[1]
        end
    else
        -- 传给logicservice处理
        local ok, result, errorCode = pcall(skynet.call,"LOGICERVICE", "lua", client_fd, params)
        return result, errorCode
    end
end

RPCService.handler = {
    login = _checkLogin,
    register = _register,
}

return RPCService
