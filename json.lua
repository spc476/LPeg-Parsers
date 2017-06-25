-- ***************************************************************
--
-- Copyright 2012 by Sean Conner.  All Rights Reserved.
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
local re   = require "re"
local up
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
        res = res .. onechar(c)
      end
      return res
    end
  }
  
  if _VERSION == "Lua 5.1" then
    up = unpack
  else
    up = table.unpack -- luacheck: ignore
  end
  
else
  utf8 = require "utf8"
  up   = table.unpack -- luacheck: ignore
end

-- **********************************************************************

local G = --[[ lpeg/re ]] [[
json            <- object /  array

object          <- begin_object
                        %member_list
                   end_object
member          <- {: string name_separator value :}

array           <- begin_array
                        {| (value (value_separator value)* )* |}
                   end_array
                   
number          <- { "-" ? int frac ? exp ? } => tonumber
exp             <- [Ee] [+-] ? [0-9]+
frac            <- "." [0-9]+
int             <- "0" / ( [1-9] [0-9]* )

string          <- '"' char* -> {} => final_string '"'
char            <- unescaped    => normal
                / '\"'          => escape
                / "\\"          => escape
                / "\b"          => escape
                / "\f"          => escape
                / "\n"          => escape
                / "\r"          => escape
                / "\t"          => escape
                / "\/"          => escape
                / (
                    "\u"
                    { [0-9A-Fa-f]^4 }  => tou16
                  )+  -> {}            => unicode
                  
unescaped       <- [^\"%c]

value           <- "false"      => retfalse
                /  "null"       => retnil
                /  "true"       => rettrue
                /  object
                /  array
                /  number
                /  string
                
begin_array     <- ws "[" ws
end_array       <- ws "]" ws
begin_object    <- ws "{" ws
end_object      <- ws "}" ws
name_separator  <- ws ":" ws
value_separator <- ws "," ws
ws              <- (%c / %s)*
]]

local member          = lpeg.V"member"
local value_separator = lpeg.V"value_separator"
local member_list     = lpeg.Cf(
                lpeg.Ct("") * (member * (value_separator * member)^0)^0,
                rawset
        )
        
-- **********************************************************************

local R =
{
  member_list = member_list,
  
  retnil = function(_,position)
    return position,null
  end,
  
  retfalse = function(_,position)
    return position,false
  end,
  
  rettrue = function(_,position)
    return position,true
  end,
  
  tonumber = function(_,position,capture)
    return position,tonumber(capture)
  end,
  
  tou16 = function(_,position,capture)
    return position,tonumber(capture,16)
  end,
  
  unicode = function(_,position,capture)
    return position,utf8.char(up(capture))
  end,
  
  normal = function(_,position,capture)
    return position,capture
  end,
  
  escape = function(_,position,capture)
    local trans =
    {
      [ [[\]] ] = 92,
      [ [[/]] ] = 47,
      [ [["]] ] = 34,
      b = 7 ,
      f = 12 ,
      n = 10,
      r = 13,
      t = 9
    }
    
    return position,string.char(trans[capture:sub(2,2)])
  end,
  
  final_string = function(_,position,capture)
    return position,table.concat(capture,"")
  end,
  
}

-- *********************************************************************

lpeg.setmaxstack(1000)
return re.compile(G,R)
