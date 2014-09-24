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

local iconv      = require "org.conman.iconv"
local cc         = require "org.conman.cc"
local lpeg       = require "lpeg"
local re         = require "re"

local conversion = iconv("UTF-8","UTF-16LE")

-- **********************************************************************

local TOUTF16 = --[[ C ]] [[
#include <stddef.h>
#include <lua.h>
#include <lauxlib.h>

int toutf16(lua_State *L)
{
  size_t len;
  size_t i;

  luaL_checktype(L,1,LUA_TTABLE);
  len = lua_objlen(L,1);
  
  unsigned short input[len];

  for (i = 0 ; i < len ; i++)
  {
    lua_rawgeti(L,1,i+1);
    input[i] = lua_tointeger(L,-1);
    lua_pop(L,1);
  }
  
  lua_pushlstring(L,(char *)input,len * sizeof(short));
  return 1;
}

]]

local toutf16 = cc.compile('toutf16',TOUTF16)

-- **********************************************************************

local G = --[[ lpeg/re ]] [[
json		<- object /  array -> {}

object		<- begin_object
			%member_list
		   end_object
member		<- {: string name_separator value :}

array		<- begin_array
			{| (value (value_separator value)* )* |}
		   end_array

number		<- { "-" ? int frac ? exp ? } => tonumber
exp		<- [Ee] [+-] ? [0-9]+
frac		<- "." [0-9]+
int		<- "0" / ( [1-9] [0-9]* )

string		<- '"' char* -> {} => final_string '"'
char		<- unescaped	=> normal
		/ '\"'		=> escape
		/ "\\"		=> escape
		/ "\b"		=> escape
		/ "\f"		=> escape
		/ "\n"		=> escape
		/ "\r"		=> escape
		/ "\t"		=> escape
		/ "\/"		=> escape
		/ (
                    "\u"
		    { [0-9A-Fa-f]^4 }  => tou16
		  )+  -> {}            => unicode

unescaped	<- [^\"%c]

value		<- "false"	=> retfalse
		/  "null" 	=> retnil
		/  "true" 	=> rettrue
		/  object
		/  array 
		/  number 
		/  string

begin_array	<- ws "[" ws
end_array	<- ws "]" ws
begin_object	<- ws "{" ws
end_object	<- ws "}" ws
name_separator	<- ws ":" ws
value_separator	<- ws "," ws
ws		<- (%c / %s)*
]]

local member = lpeg.V"member"
local value_separator = lpeg.V"value_separator"
local member_list = lpeg.Cf(
		lpeg.Ct("") * (member * (value_separator * member)^0)^0,
		rawset
	)

-- **********************************************************************

local R =
{
  member_list = member_list,

  retnil = function(subject,position,capture)
    return position,nil
  end,

  retfalse = function(subject,position,capture)
    return position,false
  end,

  rettrue = function(subject,position,capture)
    return position,true
  end,

  tonumber = function(subject,position,capture)
    return position,tonumber(capture)
  end,

  tou16 = function(subject,position,capture)
    return position,tonumber(capture,16)
  end,

  unicode = function(subject,position,capture)
    local utf16 = toutf16(capture)
    local utf8  = conversion(utf16)
    return position,utf8
  end,
    
  normal = function(subject,position,capture)
    return position,capture
  end,

  escape = function(subject,position,capture)
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

  final_string = function(subject,position,capture)
    return position,table.concat(capture,"")
  end,

}
  
-- *********************************************************************

lpeg.setmaxstack(1000)
return re.compile(G,R)

