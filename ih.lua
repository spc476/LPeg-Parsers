-- ***************************************************************
--
-- Copyright 2020 by Sean Conner.  All Rights Reserved.
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
-- ====================================================================
--
-- Some useful LPEG expressions to help the parsing of Internet headers.
--
-- ********************************************************************
-- luacheck: ignore 611

local abnf = require "org.conman.parsers.abnf"
local lpeg = require "lpeg"

local char    = lpeg.R("AZ","az")
              / function(c)
                  return lpeg.P(c:lower()) + lpeg.P(c:upper())
                end
              + lpeg.P(1)
              / function(c)
                  return lpeg.P(c)
                end
local H       = lpeg.Cf(char^1,function(a,b) return a * b end)
local COLON   = lpeg.P":" * abnf.LWSP
local generic = lpeg.C(lpeg.R("AZ","az","09","--","__")^1)
              * COLON
              * lpeg.C((lpeg.R"!\255" + (abnf.WSP + abnf.CRLF * abnf.WSP)^1 / " ")^0)
              * abnf.CRLF
              
local function headers(patt)
  return lpeg.Cf(
                  lpeg.Ct"" * lpeg.Cg(patt)^1 * abnf.CRLF,
                  function(t,k,v) t[k] = v return t end
                )
end

return {
  Hc      = function(s) return H:match(s) / s end,
  H       = function(s) return H:match(s)     end,
  COLON   = COLON,
  generic = generic,
  headers = headers,
}
