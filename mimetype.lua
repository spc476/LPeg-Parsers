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
-- ====================================================================
--
-- Parse the MIME type from RFC-2045
--
-- ********************************************************************
-- luacheck: ignore 611

local lpeg   = require "lpeg"
local string = require "string"

local Cf = lpeg.Cf
local Cg = lpeg.Cg
local Cs = lpeg.Cs
local Ct = lpeg.Ct
local C  = lpeg.C
local P  = lpeg.P
local R  = lpeg.R
local S  = lpeg.S

-- ********************************************************************
-- The rules here follow from RFC-2045, but don't follow the BNF exactly,
-- but are instead, somewhat expanded out and transformed a bit such that
-- the MIME type (such as "text/plain") will be folded to lowercase, and the
-- paramter names will also be folded to lowercase, while the value will NOT
-- be folded.
--
-- NOTE:  depending upon the RFC, the parameter value may indeed be defined
-- as "case insensitive".
-- ********************************************************************

local tspecials     = S[=["(),/:;<=>?@[\]]=]
local ichar         = R"AZ" / string.lower + (R"!~" - tspecials)
local itoken        = Cs(ichar^1)
local token         = C((R" ~" - tspecials)^1)
local quoted_string = P'"' * C(R(" !","#~")^0) * P'"'
local value         = quoted_string + token
local parameters    = Cf(
                        Ct"" * (P";" * P" "^0 * Cg(itoken * P"=" * value))^0,
                        function(acc,name,val)
                          acc[name] = val
                          return acc
                        end
                      )
local mimetype      = Cs(ichar^1 * P"/" * ichar^1)

return Ct(Cg(mimetype,'type') * Cg(parameters,'parameters'))
