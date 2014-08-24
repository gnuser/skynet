PlayerService = {}

PlayerService.userById = {} -- id
PlayerService.userByFd = {} -- fd

local _userById = PlayerService.userById
local _userByFd = PlayerService.userByFd

setmetatable(_userByFd, {__mode = "v"})

local function _canEnterWorld(id)
    print("_canEnterWorld enter:", id)
    if _userById[id] then
        return false
    end
    return true
end

function PlayerService.enterWorld(fd, msg)
    print("PlayerService.enterWorld enter:" .. msg[2])
    local account = msg[2]
    -- 获取玩家id
    local loginData = DB.loadData("h_login", account)
    print("loginData", loginData)
    local userId = loginData.userId
    if not userId then
        print("invalid account", account)
        return
    end
    -- 检查是否已经登陆
    if not _canEnterWorld(userId) then
        -- 已经登陆
        print("already login", userId)
        return
    end
    
    local userDBName = "h_user"
    local userDBData = {}
    local userObj = User.new()
    -- 检查是否保存账号
    if REDISDB:hexists(userDBName, userId) == 1 then
        -- 有则加载
        print("load user from db", userId)
        userDBData = DB.loadData(userDBName, userId)
        userObj:initData(userDBData)
    else
        -- 没有则新建,根据数据模型新建
        print("create user ", userId)        
        userDBData = userObj:getNewbieData()
        userObj:initData(userDBData)
        -- 只需要对新玩家设置
        userObj:setProperty("id", userId)
        userObj:setProperty("account", account)            
    end
    -- 设置临时保存数据, 通信描述符
    userObj:setTmpProperty("fd", fd)
    
    _userById[userId] = userObj
    _userByFd[fd] = userObj
end

function PlayerService.logout(fd)
    print("PlayerService.logout enter", fd)
--    print("current user num", table.nums(_userById))
    local user = _userByFd[fd]
    if not user then
        print("invalid fd to logout", fd)
        return
    end
    local userId = user:getProperty("id")
    -- 主动入库
    user:setDirty(true) -- 强制设置为脏
    DB.saveData(user:getSaveData())
    
    _userById[userId] = nil
    _userByFd[fd] = nil
end

function PlayerService.getUserById(id)
    return _userById[id]
end

return PlayerService
