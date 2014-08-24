local cjson = require "cjson"

DB = {}

-- 定时存储, 根据dirty位判断是否入库
-- 注册存储对象
local saveObject = {}

-- 数据访问接口

function DB.loadData(tableName, key)
--    print("DB.loadData:" , tableName, key)
    local data = nil
    if REDISDB:hexists(tableName, key) == 1 then
--        print("DB.loadData has data")
        data = REDISDB:hget(tableName, key)
        data = cjson.decode(data)
    else
--        print("DB.loadData no data")
    end
    return data
end

function DB.saveData(tableName, key, data)
    if tableName and key and data then
        local jsonData = cjson.encode(data)
--        print("DB.saveData", tableName, key, jsonData)
        REDISDB:hset(tableName, key, cjson.encode(data))
    end
end

-- 定期存储
function DB.saveRegisteredObject()
    -- todo,增加平滑机制,一次保存一部分
    for k, v in pairs(saveObject) do
        if v.getSaveData then
            DB.saveData(v:getSaveData())
        end
    end
end

return DB
