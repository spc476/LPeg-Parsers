-- ***************************************************************
--
-- Copyright 2013 by Sean Conner.  All Rights Reserved.
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
-- luacheck: ignore 611

local lpeg = require "lpeg"
local Cf   = lpeg.Cf
local Cg   = lpeg.Cg
local Ct   = lpeg.Ct
local C    = lpeg.C
local P    = lpeg.P
local S    = lpeg.S

-- **********************************************************************

local merge = function() end    -- forward declaration

local function doset(dest,name,value)
  if dest[name] == nil then
    dest[name] = value
  elseif type(dest[name]) ~= 'table' then
    dest[name] = { dest[name] , value }
  else
    if type(value) == 'table' then
      for i = 1 , #value do
        table.insert(dest[name],value[i])
        value[i] = nil
      end
      merge(dest[name],value)
    else
      table.insert(dest[name],value)
    end
  end
  return dest
end

-- **********************************************************************

merge = function(dest,src)
  for name,value in pairs(src) do
    doset(dest,name,value)
  end
end

-- **********************************************************************

local CRLF    = P"\r"^-1 * P"\n"
local SP      = P" " + P"\t"
local EQ      = SP^0 * P"=" * SP^0
local COMMA   = SP^0 * P"," * SP^0

local comment = SP^0 * (P";" + P"#") * (P(1) - CRLF)^0
local blank   = SP^0 * comment^-1 * CRLF

local name    = C((P(1) - S" \t=[]" )^1)
              / function(c) return c:lower() end
              
local item    = C((P(1) - S",;#\r\n")^1)
local char    = P(1) - P'"'
local quoted  = P'"' * C(char^0) * P'"'
local value   = quoted + item
local values  = Ct(value * (COMMA * value)^1) * comment^-1
              + value * comment^-1
              
local pair    = SP^0 * Cg(name * EQ * values) * CRLF
local nvpairs = Cf(Ct"" * (blank + pair)^0,doset)

local sname   = SP^0 * P"[" * SP^0 * name * SP^0 * P"]" * comment^-1 * CRLF
local section = Cg(sname * nvpairs)

local ini     = Cf(Ct"" * (blank + section + pair)^1,doset)

-- **********************************************************************

return ini
