-- 协议注册函数
Handler = {}

function Handler.registerHandler()
    Handler.enterWorld = PlayerService.enterWorld
    Handler.logout = PlayerService.logout
end

return Handler
