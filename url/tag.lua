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
-- ********************************************************************
-- luacheck: ignore 611
-- RFC-4151

local abnf = require "org.conman.parsers.abnf"
local lpeg = require "lpeg"

local Cg = lpeg.Cg
local Ct = lpeg.Ct
local P  = lpeg.P
local S  = lpeg.S

	-- -------------------------------
	-- Following defined in RFC-3986
	-- -------------------------------
	
local unreserved  = abnf.ALPHA + abnf.DIGIT + S"-._~"
local pct_encoded = (lpeg.P"%" * abnf.HEXDIG * abnf.HEXDIG)
                  / function(capture)
                      local n = tonumber(capture:sub(2,-1),16)
                      return string.char(n)
                    end
local sub_delims  = S"!$&'()*+,;="
local pchar       = unreserved + sub_delims + S"@:" + pct_encoded
local specific    = S"/?" + pchar
local fragment    = S"/?" + pchar

	-- -------------------------------
	-- We resume our regular RFC
	-- -------------------------------
	
local alphaNum      = abnf.DIGIT + abnf.ALPHA
local DNScomp       = alphaNum * (alphaNum + P"-" * #alphaNum)^1
local DNSname       = DNScomp * (P"." * DNScomp)^0
local emailAddress  = (alphaNum + S"-._")^1 * P"@" * DNSname
local authorityName = Cg(emailAddress + DNSname,'authority')

local year          = Cg(abnf.DIGIT * abnf.DIGIT * abnf.DIGIT * abnf.DIGIT,'year')
local month         = Cg(abnf.DIGIT * abnf.DIGIT,'month')
local day           = Cg(abnf.DIGIT * abnf.DIGIT,'day')
local date          = Cg(Ct(year * (P"-" * month * (P"-" * day)^-1)^-1))

local taggingEntity = authorityName * P"," * date

local tag = Cg(P"tag:" / "tag",'scheme')
          * taggingEntity * P":"
          * Cg(specific^0,'specific')
          * (P"#" * Cg(fragment^0,'fragment'))^-1

return Ct(tag)
