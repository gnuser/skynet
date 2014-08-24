REDISDB = nil -- redis db 全局变量

-- 基本函数列表
require "framework.functions"

NetUtil = require "logic.NetUtil"
DB = require "db.DB"

-- 用户管理
User = require "logic.user.User"
PlayerService = require "logic.user.PlayerService"

-- 协议处理
Handler = require "proto.Handler"
Handler.registerHandler()






