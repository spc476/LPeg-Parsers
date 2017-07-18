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
  local frac   = P"." * R"09"^0
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
  
  jsonS  = P'false' * Cc('boolean')    * Cc(false) * Cp()
         + P'true'  * Cc('boolean')    * Cc(true)  * Cp()
         + P'null'  * Cc('null')       * Cc(null)  * Cp()
         +            Cc('number')     * number    * Cp()
         +            Cc('string')     * string    * Cp()
         + array    * Cc('array')      * Ct("")    * Cp()
         + object   * Cc('object')     * Ct("")    * Cp()
         + arraye   * Cc('array_end')  * Cc(nil)   * Cp()
         + objecte  * Cc('object_end') * Cc(nil)   * Cp()
         + name     * Cc('name')       * Cc(nil)   * Cp()
         + value    * Cc('value')      * Cc(nil)   * Cp()
end

-- **********************************************************************
-- Usage:	json = jsonS:match(fundat)
-- Desc:	Return a Lua table populated from JSON data.  This uses
--		a streaming method that is more resource lean than my
--		other JSON decoder.
-- Input:	fundat(string function) if a string, JSON encoded data.
--			| if a function, it should return the next chunk
--			| to parse; otherwise it should return nil or an
--			| empty string to indicate no more data.
-- Return:	json (table) JSON data parsed as Lua data.
--
-- Note:	The JSON "null" value will be returned as a Lua nil.  If
--		you want a custom null value, define a global variable
--		named "null" with the sentinel value you want.
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
      data = nil
      return d
    end
  end
  
  local data
  local pos
  local result
  local more
  local add_array
  local add_object
  
  -- -----------------------------------------------------------------------
  -- JSON arrays and objects are mapped to Lua tables.  Durring processing,
  -- the current array/object is stored in result.  To keep track of nested
  -- arrays and values, we store the parent in result[false].  And the end
  -- of an array/object, we remove the parent pointer.  We do this to keep
  -- the call stack at a minimum and use the structure we are decoding as
  -- our stack.
  --
  -- Also, result[true] will hold the proper function to call for subsequent
  -- tokens, either adding to an array, or to an object.  And again, once
  -- the array/object is done, we remove this value.  Then the value in the
  -- parent node is used to restore the function.  Again, we use the
  -- structure we are creating as our stack.
  --
  -- Both functions will return true if there are no parsing errors,
  -- otherwise, they return false.
  -- -----------------------------------------------------------------------
  
  local function start_list(token,value)
    if token == 'array' then
      value[false] = result
      value[true]  = add_array
      result       = value
    elseif token == 'object' then
      value[false] = result
      value[true]  = add_object
      result       = value
    end
    return true
  end
  
  -- -----------------------------------------------------------------------
  
  local function end_list()
    more          = result[false]
    result[true]  = nil
    result[false] = nil
    result        = more or result
    return true
  end
  
  -- -----------------------------------------------------------------------
  
  add_array = function(token,value)
    if token == 'array_end' then
      return end_list()
      
    elseif token == 'object_end' then
      return false
      
    elseif token == 'name' then
      return false
      
    elseif token == 'value' then
      return true
      
    else
      table.insert(result,value)
      return start_list(token,value)
    end
  end
  
  -- ------------------------------------------------------------------
  -- For objects, we temporarily store the name and value in the array
  -- portion of the Lua table.  The actual setting of the field doesn't
  -- occur until we get the 'value' token.  Then the name and value are
  -- removed from the array portion and used to set the field portion.
  -- ------------------------------------------------------------------
  
  add_object = function(token,value)
    if token == 'object_end' then
      local val = table.remove(result)
      local key = table.remove(result)
      if not key then return false end
      result[key.value] = val.value
      return end_list()
      
    elseif token == 'array_end' then
      return false
      
    elseif token == 'name' then
      return type(result[1].token) == 'string'
      
    elseif token == 'value' then
      local val = table.remove(result)
      local key = table.remove(result)
      if not key then return false end
      result[key.value] = val.value
      return true
      
    else
      table.insert(result, { token = token , value = value })
      return start_list(token,value)
    end
  end
  
  -- ------------------------------------------------------------------
  
  data = fundat()
  if not data then return nil end

  local token,value,newpos = jsonS:match(data,1)
  if not token or token ~= 'array'  and token ~= 'object' then
    return nil
  end
  
  pos    = newpos
  result = value
  more   = true
  
  if token == 'array' then
    result[true] = add_array
  else
    result[true] = add_object
  end
  
  -- ------------------------------------------------------------------
  -- Parse data.  If the LPeg parser returns nil, that triggers a refill of
  -- the data.  If storing the result returns false, that indicates a syntax
  -- error in the input stream, and will thus return a nil to indicate an
  -- error.
  -- ------------------------------------------------------------------
  
  local function process()
    if not more then return result end
    
    token,value,newpos = jsonS:match(data,pos)
    
    if not token then
      local new = fundat()
      if new == nil or new == "" then return nil end
      data = data:sub(pos,-1) .. new
      pos  = 1
      return process()
    end
    
    if not result[true](token,value) then return nil end
    
    pos = newpos
    return process()
  end
  
  return process()
end

-- **********************************************************************

return { match = match }
