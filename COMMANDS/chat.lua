--local bc = better_commands
local S = minetest.get_translator(minetest.get_current_modname())

better_commands.register_command("say", {
    params = "<message>",
    description = S("Says <message> to all players (which can include selectors such as @@a if you have the server priv)"),
    privs = {shout = true},
    func = function(name, param, context)
        context = better_commands.complete_context(name, context)
        if not context then return false, S("Missing context"), 0 end
        if not context.executor then return false, S("Missing executor"), 0 end
        local split_param = better_commands.parse_params(param)
        if not split_param[1] then return false, nil, 0 end
        local message
        if context.command_block or minetest.check_player_privs(context.origin, {server = true}) then
            local err
            message, err = better_commands.expand_selectors(param, split_param, 1, context)
            if err then return false, err, 0 end
        else
            message = param
        end
        minetest.chat_send_all(string.format("[%s] %s", better_commands.get_entity_name(context.executor), message))
        return true, nil, 1
    end
})

better_commands.register_command("msg", {
    params = "<target> <message>",
    description = S("Sends <message> privately to <target> (which can include selectors like @@a if you have the server priv)"),
    privs = {shout = true},
    func = function(name, param, context)
        context = better_commands.complete_context(name, context)
        if not context then return false, S("Missing context"), 0 end
        if not context.executor then return false, S("Missing executor"), 0 end
        local split_param = better_commands.parse_params(param)
        if not split_param[1] and split_param[2] then
            return false, nil, 0
        end
        local targets, err = better_commands.parse_selector(split_param[1], context)
        if err or not targets then return false, err, 0 end
        local target_start = S("@1 whispers to you: ", better_commands.get_entity_name(context.executor))
        local message
        if context.command_block or minetest.check_player_privs(context.origin, {server = true}) then
            local err
            message, err = better_commands.expand_selectors(param, split_param, 2, context)
            if err then return false, err, 0 end
        else
---@diagnostic disable-next-line: param-type-mismatch
            message = param:sub(split_param[2][1], -1)
        end
        local count = 0
        for _, target in ipairs(targets) do
            if target.is_player and target:is_player() then
                count = count + 1
                local origin_start = S("You whisper to @1: ", better_commands.get_entity_name(target))
                minetest.chat_send_player(name, origin_start..message)
                minetest.chat_send_player(target:get_player_name(), target_start..message)
            end
        end
        return true, nil, count
    end
})

better_commands.register_command_alias("w", "msg")
better_commands.register_command_alias("tell", "msg")

better_commands.register_command("me", {
    description = S("Broadcasts a message about yourself (which can include selectors like @@a if you have the server priv)"),
    params = "<action>",
    privs = {shout = true},
    func = function(name, param, context)
        context = better_commands.complete_context(name, context)
        if not context then return false, S("Missing context"), 0 end
        if not context.executor then return false, S("Missing executor"), 0 end
        local split_param = better_commands.parse_params(param)
        if not split_param[1] then return false, nil, 0 end
        local message
        if context.command_block or minetest.check_player_privs(context.origin, {server = true}) then
            local err
            message, err = better_commands.expand_selectors(param, split_param, 1, context)
            if err then return false, err, 0 end
        else
            message = param
        end
        minetest.chat_send_all(string.format("* %s %s", better_commands.get_entity_name(context.executor), message))
        return true, nil, 1
    end
})