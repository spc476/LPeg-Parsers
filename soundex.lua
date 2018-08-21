-- ***************************************************************
--
-- Copyright 2016 by Sean Conner.  All Rights Reserved.
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

local ignore  = lpeg.S"AEIOUWYHaeiouwyh"^0
local skip    = lpeg.S"HWhw"
local cs1     = lpeg.S"BFPVbfpv"^1
local cs2     = lpeg.S"CGJKQSXZcgjkqsxz"^1
local cs3     = lpeg.S"DTdt"^1
local cs4     = lpeg.S"Ll"^1
local cs5     = lpeg.S"MNmn"^1
local cs6     = lpeg.S"Rr"^1
local initial = (lpeg.P(1) * (cs1 + cs2 + cs3 + cs4 + cs5 + cs6)^-1)
              / function(c) return c:sub(1,1):upper() end
local keep    = cs1 * (skip * cs1)^-1 * lpeg.Cc "1"
              + cs2 * (skip * cs2)^-1 * lpeg.Cc "2"
              + cs3 * (skip * cs3)^-1 * lpeg.Cc "3"
              + cs4 * (skip * cs4)^-1 * lpeg.Cc "4"
              + cs5 * (skip * cs5)^-1 * lpeg.Cc "5"
              + cs6 * (skip * cs6)^-1 * lpeg.Cc "6"
              +                         lpeg.Cc "0"
local use     = ignore * keep

return lpeg.Cf(initial * use * use * use,function(a,c) return a..c end)
