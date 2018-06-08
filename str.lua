local utf8 = require 'lua-utf8'

local function ternary(conditional, when_true, when_false)
    return conditional and when_true or when_false
end

local function to_bool(value)
    return not not value
end

local function get_list_chars(s)
    local output = {}

    for k, c in utf8.codes(s) do
        table.insert(output, utf8.char(c))
    end

    return output
end

local str = {
    __VERSION = '1.0.0',
    __DESCRIPTION = '',
    __LICENCE = [[
        The MIT License (MIT)

        Copyright (c) 2016 Evandro Leopoldino Gonçalves

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]]
}

str = {
    slice = function(s, start, finish)
        return string.sub(s, start, ternary(finish, finish, #s))
    end,

    starts_with = function(s, start)
        return string.sub(s, 1, #start) == start
    end,

    ends_with = function(s, finish)
        return string.sub(s, -#finish) == finish
    end,

    count = function(s, substr)
        local total = 0
        local size_substr = #substr

        for i=1, #s do
            if string.sub(s, i, (i-1) + size_substr) == substr then
                total = total + 1
            end
        end

        return total
    end,

    split = function(s, pattern)
        local output = {}
        local fpat = '(.-)' .. pattern
        local last_end = 1
        local _s, e, cap = s:find(fpat, 1)

        while _s do
            if _s ~= 1 or cap ~= '' then
                table.insert(output, cap)
            end

            last_end = e+1
            _s, e, cap = s:find(fpat, last_end)
        end

        if last_end <= #s then
            cap = s:sub(last_end)
            table.insert(output, cap)
        end

        return output
    end,

    trim_right = function(s)
        local n = #s

        while string.find(string.sub(s, n, n), '%s') do
            n = n - 1
        end

        return string.sub(s, 1, n)
    end,

    trim_left = function(s)
        local n = 1

        while string.find(string.sub(s, n, n), '%s') do
            n = n + 1
        end

        return string.sub(s, n, #s)
    end,

    trim = function(s)
        return str.trim_right(str.trim_left(s))
    end,

    capitalize = function(s)
        if #s == 0 then
            return s
        end

        local output = {}
        output[1] = string.upper(string.sub(s, 1, 1))

        for i=2, #s do
            local character = string.sub(s, i, i)
            table.insert(output, string.lower(character))
        end

        return table.concat(output)
    end,

    center = function(s, n)
        local aux = ''

        for i=1, n do
            aux = aux .. ' '
        end

        return aux .. s .. aux
    end,

    slug = function(s)
        local splited = get_list_chars(s)
        local output = {}
        local accents = [[ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîï
                        ÙÚÛÜùúûüÑñŠšŸÿýŽž~"\'~^!?.:@#$%&*]]
        local accents_out = [[AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiii
                            UUUUuuuuNnSsYyyZz---------------]]

        for key, value in pairs(splited) do
            local index_of = utf8.find(accents, value)

            if index_of then
                output[key] = utf8.sub(accents_out, index_of, index_of)
            else
                output[key] = value
            end
        end

        return utf8.lower(table.concat(output, ''):gsub('%s', '-'))
    end,

    is_ascii = function(s)
        for i=1, #s do
            if string.byte(s:sub(i, i)) > 126 then return false end
        end

        return true
    end,

    is_number = function(s)
        return to_bool(string.find(s, '^%d*$'))
    end
}

return str