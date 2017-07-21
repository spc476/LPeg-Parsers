-- ***************************************************************
--
-- Copyright 2017 by Sean Conner.  All Rights Reserved.
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or (at your
-- option) any later version.
--
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
-- License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this library; if not, see <http://www.gnu.org/licenses/>.
--
-- Comments, questions and criticisms can be sent to: sean@conman.org
--
-- ********************************************************************
-- luacheck: globals null
-- luacheck: ignore 611

local lpeg = require "lpeg"
local utf8

if _VERSION < "Lua 5.3" then
  local char   = require "string".char
  local floor  = require "math".floor
  local select = select
  
  utf8 =
  {
    char = function(...)
      local function onechar(n)
        if n < 0x80 then
          return char(n)
        elseif n < 0x800 then
          return char(
                  floor(n / 2^6) + 0xC0,
                  (n % 0x40)     + 0x80
          )
        else
          return char(
                  (floor(n / 2^12) + 0xE0),
                  (floor(n / 2^ 6) % 0x40) + 0x80,
                  (n               % 0x40) + 0x80
          )
        end
      end
      
      local res = ""
      for i = 1 , select('#',...) do
        local c = select(i,...)
        res = res .. onechar(c,16)
      end
      return res
    end
  }
else
  utf8 = require "utf8"
end

-- ********************************************************************

local jsonS do
  local Cc   = lpeg.Cc
  local Cp   = lpeg.Cp
  local Cs   = lpeg.Cs
  local Ct   = lpeg.Ct
  local P    = lpeg.P
  local R    = lpeg.R
  local S    = lpeg.S
  
  local int    = P"0"
               + R"19" * R"09"^0
  local frac   = P"."  * R"09"^1
  local exp    = S"Ee" * S"+-"^-1 * R"09"^1
  local number = (P"-"^-1 * int * frac^-1 * exp^-1)
               / tonumber
               
  local unescaped = R(" !","#[","]~","\128\255")
  local char      = unescaped
                  + P[[\"]] / [["]]
                  + P[[\\]] / [[\]]
                  + P[[\b]] / "\b"
                  + P[[\f]] / "\f"
                  + P[[\n]] / "\n"
                  + P[[\r]] / "\r"
                  + P[[\t]] / "\t"
                  + P[[\/]] / "/"
                  + P[[\u]]
                  * (
                        R("09","AF","af")
                      * R("09","AF","af")
                      * R("09","AF","af")
                      * R("09","AF","af")
                    )
                  / function(c)
                      return utf8.char(tonumber(c:sub(3,-1),16))
                    end
  local string    = P'"' * Cs(char^0) * P'"'
  
  local ws     = S"\t\r\n "^0
  local array  = ws * P"[" * ws * #P(1)
  local object = ws * P"{" * ws * #P(1)
  local NAME   = ws * P":" * ws * #P(1)
  local VALUE  = ws * P"," * ws * #P(1)
  local ARRAY  = ws * P"]" * ws
  local OBJECT = ws * P"}" * ws
  
  jsonS =            Cc('string')  * string    * Cp()
        +            Cc('number')  * number    * Cp() * #(VALUE + ARRAY + OBJECT)
        + P'false' * Cc('boolean') * Cc(false) * Cp()
        + P'true'  * Cc('boolean') * Cc(true)  * Cp()
        + P'null'  * Cc('null')    * Cc(null)  * Cp()
        + array    * Cc('array')   * Ct("")    * Cp()
        + object   * Cc('object')  * Ct("")    * Cp()
        + ARRAY    * Cc('ARRAY')   * Cc(nil)   * Cp()
        + OBJECT   * Cc('OBJECT')  * Cc(nil)   * Cp()
        + NAME     * Cc('NAME')    * Cc(nil)   * Cp()
        + VALUE    * Cc('VALUE')   * Cc(nil)   * Cp()
end

-- **********************************************************************
-- Usage:       json = jsonS:match(fundat)
-- Desc:        Return a Lua table populated from JSON data.  This uses
--              a streaming method that is more resource lean than my
--              other JSON decoder.
-- Input:       fundat(string function) if a string, JSON encoded data.
--                      | if a function, it should return the next chunk
--                      | to parse; otherwise it should return nil or an
--                      | empty string to indicate no more data.
-- Return:      json (table) JSON data parsed as Lua data.
--
-- Note:        The JSON "null" value will be returned as a Lua nil.  If
--              you want a custom null value, define a global variable
--              named "null" with the sentinel value you want.
--
--              Always returning a single character from fundat() will
--              cause issues with parsing.
-- **********************************************************************

local function match(_,fundat)
  -- -----------------------------------------------------------------------
  -- To be a drop-in replacement for my original JSON decoder, the fundat
  -- parameter can be a string.  If it is, then replace it with a function
  -- that just returns said string.  Otherwise, we have a function that will
  -- return the next chunk of data to read.
  -- -----------------------------------------------------------------------
  
  if type(fundat) == 'string' then
    local data = fundat
    fundat = function()
      local d = data
      data    = nil
      return d
    end
  end
  
  local data
  local pos
  local result
  local okay
  local array  -- forward function reference
  local object -- forward function reference
  
  -- -----------------------------------------------------------------------
  
  local function next_token(list)
    local token,val,newpos = jsonS:match(data,pos)
    if not token then
      local new = fundat()
      if new == nil or new == "" then error "parse" end
      data = data:sub(pos,-1) .. new
      pos  = 1
      return next_token(list)
    else
      for _,isthis in ipairs(list) do
        if isthis == token then
          return token,val,newpos
        end
      end
      error "parse"
    end
  end
  
  -- -----------------------------------------------------------------------
  -- JSON arrays and objects are mapped to Lua tables.  During processing,
  -- the current array/object is stored in result.  To help keep track of
  -- things, the following are temporarily stored during processing:
  --
  --    result[false]   -> parent node
  --    result[true]    -> function to call for processing next token
  --
  -- They are removed once an array/object is finished processing.
  -- -----------------------------------------------------------------------
  
  local function insert_list(token,key,value,resume)
    result[key]  = value
    result[true] = resume
    
    if token == 'array' then
      value[false] = result
      value[true]  = array
      result       = value
    elseif token == 'object' then
      value[false] = result
      value[true]  = object
      result       = value
    end
    
    return result[true]()
  end
  
  -- -----------------------------------------------------------------------
  
  local end_list do
    -- ---------------------------------------------------------
    -- Sigh---the things I do to follow the letter of the spec.
    -- ---------------------------------------------------------
    
    local SPACE = lpeg.S"\t\r\n "^0 * lpeg.P(-1)
    
    local function drain(d)
      local extra = fundat()
      if not extra or extra == "" then
        return d
      else
        return drain(d .. extra)
      end
    end
    
    end_list = function()
      local parent  = result[false]
      result[true]  = nil
      result[false] = nil
      result        = parent or result
      
      if not parent then
        if pos > #data then
          local extra = drain("")
          if SPACE:match(extra) then
            return result
          end
        end
        return nil
      else
        return result[true]()
      end
    end
  end
  
  -- -----------------------------------------------------------------------
  
  local token
  local value
  
  local function array_value()
    token,value,pos = next_token { 'ARRAY' , 'VALUE' }
    if token == 'ARRAY' then
      return end_list()
    else
      assert(token == 'VALUE')
      token,value,pos = next_token { 'string' , 'number' , 'boolean' , 'null' , 'array' , 'object' }
      return insert_list(token,#result + 1,value,array_value)
    end
  end
  
  array = function()
    token,value,pos = next_token { 'string' , 'number' , 'boolean' , 'null' , 'array' , 'object' , 'ARRAY' }
    if token == 'ARRAY' then return end_list() end
    return insert_list(token,#result + 1,value,array_value)
  end
  
  -- -----------------------------------------------------------------------
  
  local function object_value()
    token,value,pos = next_token { 'VALUE','OBJECT'}
    if token == 'OBJECT' then
      return end_list()
    else
      assert(token == 'VALUE')
      token,value,pos = next_token { 'string' }
      local name = value
      token,value,pos = next_token { 'NAME' }
      token,value,pos = next_token { 'string' , 'number' , 'boolean' , 'null' , 'array' , 'object' }
      return insert_list(token,name,value,object_value)
    end
  end
  
  object = function()
    token,value,pos = next_token { 'string' , 'OBJECT' }
    
    if token == 'OBJECT' then return end_list() end
    
    local name = value
    
    token,value,pos = next_token { 'NAME' }
    token,value,pos = next_token { 'string' , 'number' , 'boolean' , 'null' , 'array' , 'object' }
    return insert_list(token,name,value,object_value)
  end
  
  -- ------------------------------------------------------------------
  
  okay,result = pcall(function()
    data = fundat()
    pos  = 1
    
    if data == nil or data == "" then return nil end
    
    token,result,pos = next_token { 'array' , 'object' }
    
    if token == 'array' then
      return array()
    elseif token == 'object' then
      return object()
    end
  end)
  
  return okay and result or nil
end

-- **********************************************************************

return { match = match }
