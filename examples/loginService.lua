local skynet = require "skynet"
local redis = require "redis"
local cjson = require "cjson"

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
    print("CMD.login enter")
    local account = params[1]
    local passwd = params[2]

    local errorCode = 0
    if db:hexists("h_login", tostring(account)) == 0 then
        print("account is not exist!", account)
        errorCode = 1
        return false, errorCode
    end

    local loginInfo = db:hget("h_login", tostring(account))
    local loginJsonInfo = cjson.decode(loginInfo)

    if loginJsonInfo.passwd ~= tostring(passwd) then
        print("account passwd is wrong!", account)
        errorCode = 2
        return false, errorCode        
    end

    -- 通知agent登陆成功
    return true
end

---
-- 注册账号
function CMD.register(params)
    local account = params[1]
    local passwd = params[2]    
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
    local accountValue = {
                userId = userId,
                passwd = tostring(passwd),
                nickName = tostring(nickName)
            }
    local accountJsonValue = cjson.encode(accountValue)
    db:hset("h_login", tostring(account),  accountJsonValue)
    return true
end

---
-- 清理账号
function CMD.clearAccount(params)
    local account = params[1]
    db:hdel("h_login", tostring(account))
    return true
end

skynet.start(function()
        skynet.fork(watching)
        db = redis.connect(conf)
        
        skynet.dispatch("lua", function(session, address, cmd, params)
                            print("loginService get cmd:", address, cmd)
            local f = assert(CMD[cmd])
            skynet.ret(skynet.pack(f(params)))
            --skynet.ret(skynet.pack(login(params)))
        end)
        skynet.register "LOGINSERVICE"
end)
