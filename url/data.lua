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

local Cc = lpeg.Cc
local Cf = lpeg.Cf
local Cg = lpeg.Cg
local Cs = lpeg.Cs
local Ct = lpeg.Ct
local C  = lpeg.C
local P  = lpeg.P
local R  = lpeg.R
local S  = lpeg.S

-- ********************************************************************

local escaped    = P"%" * C(abnf.HEXDIG * abnf.HEXDIG)
                 / function(c) return string.char(tonumber(c,16)) end
local mark       = S"-_.!~*'()"
local unreserved = abnf.ALPHA + abnf.DIGIT + mark
local uric       = escaped + unreserved

local base64     = abnf.ALPHA + abnf.DIGIT + S"+/"

-- ------------------------------------------------------------------------
-- RFC-2045 lists [=["(),/:;<=>?@[\]]=] as tspecials, which cannot be in
-- a parameter name, and *must* be quoted to appear in a value.
--
-- RFC-3986 lists [=[ "#%<>[\]^{|}]=] as unsafe and these MUST always be
-- escaped in a URL.
--
-- If you match up the two lists, then the following list [=[#%^{|}]=] are
-- the characters that can appear in a parameter name that MUST be escaped.
-- ------------------------------------------------------------------------

local mcharsafe  = R"AZ" / string.lower
                 + S[[!$&`+-.0123456789_`abcdefghijklmnopqrstuvwxyz~]]
local ichar      = mcharsafe
                 + (P"%%23")           / "#"
                 + (P"%%25")           / "%%"
                 + (P"%%5E" + P"%%5e") / "^"
                 + (P"%%7B" + P"%%7b") / "{"
                 + (P"%%7C" + P"%%7c") / "|"
                 + (P"%%7D" + P"%%7d") / "}"
local char       = escaped + (R"!~" - S";,")
local itoken     = Cs(ichar^1)
local token      = Cs(char^1)
local parameters = Cf(
                       Ct"" * (P";" * Cg(itoken * P"=" * token))^0,
                       function(acc,name,val)
                         acc[name] = val
                         return acc
                       end
                     )
local mimetype   = Cs(ichar^1 * P"/" * ichar^1)
local mediatype  = Cg(mimetype,'type')
                 * Cg(#P";" * parameters,'parameters')^-1
local charset    = Cg(Ct(P"charset=" * Cg(token,'charset')),'parameters')
local data       = Cg(P"data:" / "data",'scheme')
                 * Cg(Cc('text/plain'),'type')
                 * Cg(Ct(Cg(Cc'US-ASCII','charset')),'parameters')
                 * (mediatype + charset)^-1
                 * (
                     (
                       Cg(P";base64" * Cc(true),'base64')
                       * P"," * Cg(C(base64^1),'data')
                     )
                     +
                     (
                       Cg(Cc(false),'base64')
                       * P"," * Cg(C(uric^1),'data')
                     )
                   )
return Ct(data)
