
zeroDB = zeroDB or {}

function zeroDB.debug(...)
    local printResult = ''

    for i = 1, arg.n do
        printResult = printResult .. tostring(arg[i]) .. " "
    end

    DEFAULT_CHAT_FRAME:AddMessage('|cff3399ffzeroDB |ccfffffff'..printResult)
end

function zeroDB.explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")

    local o = {}
    local count = 0

    while true do
        local pos1, pos2 = string.find(str, div)

        if not pos1 then
            if str ~= '' then
                count = count + 1
                o[count] = str
            end

            break
        end

        if pos1 > 1 then
            count = count + 1
            o[count] = string.sub(str, 1, pos1 - 1)
        end

        str = string.sub(str, pos2 + 1)
    end

    return o, count
end

function zeroDB.begins_with(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function zeroDB.list_map(list, count, func)
    local output = {}

    for i = 1, count do
        output[i] = func(list[i], i)
    end

    return output, count
end
