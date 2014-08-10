local skynet = require "skynet"
local redis = require "redis"

local conf = {
    host = "127.0.0.1",
    port = 6379,
    db = 0
}

local db = nil

local function watching()
    local w = redis.watch(conf)
end

local CMD = {}
function CMD.login(params)
    local account = params.account
    local passwd = params.passwd

    local errorCode = 0
    if db:hexists("h_login", tostring(account)) == 0 then
        print("account is not exist!", account)
        errorCode = 1
        return false, errorCode
    end

    local loginInfo = db:hget("h_login", tostring(account))
    if loginInfo.passwd ~= tostring(passwd) then
        print("account passwd is wrong!", account)
        errorCode = 2
        return false, errorCode        
    end
end

function CMD.register(params)
    local account = params.account
    local passwd = params.passwd    
    local nickName = params.nickName

    local errorCode = 0
    if db:hexists("h_login", tostring(account)) == 1 then
        print("account already exist!", account)
        errorCode = 1
        return false, errorCode
    end

    -- 检查密码长度，强度， TODO
    -- 加入顺序表
    db:sadd("s_login", tostring(account))
    -- 获取id
    local userLen = db:scard("s_login")
    local userId = userLen + 1
    db:hset("h_login", tostring(account),
            {
                userId = userId,
                passwd = tostring(passwd),
                nickName = tostring(nickName)
            }
    )
        
    return true
end

skynet.start(function()
        skynet.fork(watching)
        db = redis.connect(conf)
        
        skynet.dispatch("lua", function(session, address, cmd, params)
                            print("loginService get cmd:", cmd)
            local f = assert(CMD[cmd])
            skynet.ret(skynet.pack(f(params)))
            --skynet.ret(skynet.pack(login(params)))
        end)
        skynet.register "LOGINSERVICE"
end)
