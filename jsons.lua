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
  local frac   = P"."  * R"09"^0
  local exp    = S"Ee" * S"+-"^-1 * R"09"^1
  local number = (P"-"^-1 * int * frac^-1 * exp^-1)
               / tonumber
               
  local unescaped = R(" !","#[","]~")
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
  
  local ws      = R("\0\32","\127\127")^0
  local name    = ws * P":" * ws
  local value   = ws * P"," * ws
  local array   = ws * P"[" * ws
  local arraye  = ws * P"]" * ws
  local object  = ws * P"{" * ws
  local objecte = ws * P"}" * ws
  
  local next    = value + #arraye + #objecte
  
  jsonS =            Cc('name')       * string    * name  * Cp()
        +            Cc('value')      * string    * next  * Cp()
        +            Cc('value')      * number    * next  * Cp()
        + P'false' * Cc('value')      * Cc(false) * next  * Cp()
        + P'true'  * Cc('value')      * Cc(true)  * next  * Cp()
        + P'null'  * Cc('value')      * Cc(null)  * next  * Cp()
        + array    * Cc('array')      * Ct("")    * #P(1) * Cp()
        + object   * Cc('object')     * Ct("")    * #P(1) * Cp()
        + arraye   * Cc('array_end')  * Cc(nil)   * next  * Cp()
        + objecte  * Cc('object_end') * Cc(nil)   * next  * Cp()
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
  local add_array  -- forward function reference
  local add_object -- forward function reference
  
  -- -----------------------------------------------------------------------
  
  local function next_token()
    local token,value,newpos = jsonS:match(data,pos)
    if not token then
      local new = fundat()
      if new == nil or new == "" then return nil end
      data = data:sub(pos,-1) .. new
      pos  = 1
      return next_token()
    else
      return token,value,newpos
    end
  end
  
  -- -----------------------------------------------------------------------
  -- JSON arrays and objects are mapped to Lua tables.  During processing,
  -- the current array/object is stored in result.  To help keep track of
  -- things, the following are temporarily stored during processing:
  --
  --	result[false]	-> parent node
  --	result[true]	-> function to call for processing next token
  --
  -- They are removed once an array/object is finished processing.
  -- -----------------------------------------------------------------------
  
  local function insert_list(token,key,value)
    result[key] = value
    
    if token == 'array' then
      value[false] = result
      value[true]  = add_array
      result       = value
    elseif token == 'object' then
      value[false] = result
      value[true]  = add_object
      result       = value
    end
    return result[true]()
  end
  
  -- -----------------------------------------------------------------------
  
  local function end_list()
    local parent  = result[false]
    result[true]  = nil
    result[false] = nil
    result        = parent or result
    return result[true]()
  end
  
  -- -----------------------------------------------------------------------
  
  add_array = function()
    local token,value
    
    token,value,pos = next_token()
    if token == nil          then return nil end
    if token == 'object_end' then return nil end
    if token == 'name'       then return nil end
    
    if token == 'array_end' then
      return end_list()
    else
      return insert_list(token,#result + 1,value)
    end
  end
  
  -- -----------------------------------------------------------------------
  
  add_object = function()
    local token,value,name
    
    token,value,pos = next_token("object_name")
    if not token then return nil end
    
    if token == 'object_end' then
      return end_list()
    elseif token == 'name' then
      name = value
    else
      return nil
    end
    
    token,value,pos = next_token("object_value")
    
    if token == 'value' or token == 'array' or token == 'object' then
      return insert_list(token,name,value)
    else
      return nil
    end
  end
  
  -- ------------------------------------------------------------------
  
  local token
  data = fundat()
  pos  = 1
  
  if data == nil or data == "" then return nil end
  
  token,result,pos = next_token()
  
  if not token or token ~= 'array' and token ~= 'object' then
    return nil
  end
  
  -- ---------------------------------------------------------------
  -- The top level "next token" function will actually return the
  -- accumulated result, clearing itself from the result.
  -- ---------------------------------------------------------------
  
  result[true] = function()
    result[true] = nil
    return result
  end
  
  if token == 'array' then
    return add_array()
  elseif token == 'object' then
    return add_object()
  else
    return nil
  end
end

-- **********************************************************************

return { match = match }
