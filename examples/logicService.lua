local skynet = require "skynet"
local redis = require "redis"
local cjson = require "cjson"

package.path = package.path .. ";./?.lua;./examples/?.lua"
require "logic.global" -- 全局

local conf = {
    host = "127.0.0.1",
    port = 6379,
    db = 0
}

local db = nil

local function watching()
    local w = redis.watch(conf)
end

function processRPC(fd, params)
    print("logicservice processRPC enter")

    local handler = Handler[params[1]]
    if handler then
        handler(fd, params)
    end
end

skynet.start(function()
        skynet.fork(watching)
        db = redis.connect(conf)

        REDISDB = db -- 赋值给全局变量

        skynet.dispatch("lua", function(session, address, fd, params)
                            print("logicService get cmd:", params[1])
                            local ok, result = pcall(processRPC, fd, params)
        end)
        skynet.register "LOGICSERVICE"
end)
