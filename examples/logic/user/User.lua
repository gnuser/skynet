local User = class("user")

local _tableName = "h_user"

function User:ctor()
    print("user create")
    self._data = {}
    self._tmp = {}
    self._isDirty = false -- 是否需要执行存储操作
end

-- 初始化数据
function User:initData(params)
    for k, v in pairs(params) do
        self:setProperty(k, v)
    end
end

-- 获取新建账号数据
function User:getNewbieData()
    return { level = 0 }
end

function User:setTmpProperty(propName, propValue)
    self._tmp[propName] = propValue
end

function User:setProperty(propName, propValue)
    self._data[propName] = propValue
end

function User:getProperty(propName)
    local result = self._data[propName]
    if not result then
        result = self._tmp[propName]
    end
    return result
end

function User:setDirty(value)
    self._isDirty = value
end

function User:isDirty()
    return self._isDirty
end

-- 获取入库数据
function User:getSaveData()
    if self:isDirty() then
        self:setDirty(false) -- 重置
        return _tableName, self:getProperty("id"), self._data
    end
end

return User
