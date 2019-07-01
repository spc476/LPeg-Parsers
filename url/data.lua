-- ***************************************************************
--
-- Copyright 2019 by Sean Conner.  All Rights Reserved.
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
-- RFC-2397

local abnf = require "org.conman.parsers.abnf"
local lpeg = require "lpeg"

-- ********************************************************************

local CHARSET    = (lpeg.P"C" + lpeg.P"c" + lpeg.P"%43" + lpeg.P"%63")
                 * (lpeg.P"H" + lpeg.P"h" + lpeg.P"%48" + lpeg.P"%68")
                 * (lpeg.P"A" + lpeg.P"a" + lpeg.P"%41" + lpeg.P"%61")
                 * (lpeg.P"R" + lpeg.P"r" + lpeg.P"%52" + lpeg.P"%72")
                 * (lpeg.P"S" + lpeg.P"s" + lpeg.P"%53" + lpeg.P"%73")
                 * (lpeg.P"E" + lpeg.P"e" + lpeg.P"%45" + lpeg.P"%65")
                 * (lpeg.P"T" + lpeg.P"t" + lpeg.P"%54" + lpeg.P"%74")
local BASE64     = (lpeg.P"b" + lpeg.P"%62")
                 * (lpeg.P"a" + lpeg.P"%61")
                 * (lpeg.P"s" + lpeg.P"%73")
                 * (lpeg.P"e" + lpeg.P"%65")
                 * (lpeg.P"6" + lpeg.P"%36")
                 * (lpeg.P"4" + lpeg.P"%34")
local escaped    = lpeg.P"%" * lpeg.C(abnf.HEXDIG * abnf.HEXDIG)
                 / function(c) return string.char(tonumber(c,16)) end
local mark       = lpeg.S"-_.!~*'()"
local unreserved = abnf.ALPHA + abnf.DIGIT + mark
local uric       = escaped + unreserved
local base64     = abnf.ALPHA + abnf.DIGIT + lpeg.S"+/"
local iana_token = escaped + lpeg.R("AZ","az","09","--","..")
local majortype  = iana_token^1
local minortype  = iana_token^1 + lpeg.P"*"
local mimetype   = majortype * lpeg.P"/" * minortype
local especials  = lpeg.P"%28" + lpeg.P"%29"
                 + lpeg.P"%3C" + lpeg.P"%3E" + lpeg.P"%3c" + lpeg.P"%3e"
                 + lpeg.P"%40"
                 + lpeg.P"%2C" + lpeg.P"%2c"
                 + lpeg.P"%3B" + lpeg.P"%3b"
                 + lpeg.P"%3A" + lpeg.P"%3a"
                 + lpeg.P"%5C" + lpeg.P"%5c"
                 + lpeg.P"%22"
                 + lpeg.P"%2F" + lpeg.P"%2f"
                 + lpeg.P"%5B" + lpeg.P"%5D" + lpeg.P"%5b" + lpeg.P"%5d"
                 + lpeg.P"%3F" + lpeg.P"%3f"
                 + lpeg.P"%3D" + lpeg.P"%3d"
                 + lpeg.P"%2A" + lpeg.P"%2a"
                 + lpeg.P"%27"
                 + lpeg.P"%25"
local quote      = lpeg.P'"' + lpeg.P"%22"
local token      = (escaped - especials)
                 + lpeg.R"!~" - lpeg.S[[()<>@,;:\"/[]?=*'%]] -- RFC-2231
local attribute  = token^1 / function(c) return c:lower() end
local qs         = quote
                 * (-quote * (escaped + lpeg.R"!~"))^1
                 * quote
local value      = token^1 + qs
local parameter  = attribute * lpeg.P"=" * lpeg.C(value)
local parmlist   = lpeg.Cf(
                            lpeg.Ct"" * (lpeg.P";" * lpeg.Cg(parameter))^1,
                            function(acc,n,v)
                              acc[n] = v
                              return acc
                            end
                          )
local mediatype  = lpeg.Cg(mimetype,'type')
                 * lpeg.Cg(#lpeg.P";" * parmlist,'parameters')^-1
local charset    = lpeg.Cg(lpeg.Ct(CHARSET * lpeg.P"=" * lpeg.Cg(value,'charset')),'parameters')
local data       = lpeg.Cg(lpeg.P"data:" / "data",'scheme')
                 * lpeg.Cg(lpeg.Cc('text/plain'),'type')
                 * lpeg.Cg(lpeg.Ct(lpeg.Cg(lpeg.Cc'US-ASCII','charset')),'parameters')
                 * (mediatype + charset)^-1
                 * (
                     (
                       lpeg.Cg(lpeg.P";" * BASE64 * lpeg.Cc(true),'base64')
                       * lpeg.P"," * lpeg.Cg(lpeg.C(base64^1),'data')
                     )
                     +
                     (
                       lpeg.Cg(lpeg.Cc(false),'base64')
                       * lpeg.P"," * lpeg.Cg(lpeg.C(uric^1),'data')
                     )
                   )
return lpeg.Ct(data)
