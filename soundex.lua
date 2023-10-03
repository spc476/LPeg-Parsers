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
-- https://www.archives.gov/research/census/soundex.html
--
-- luacheck: ignore 611

local lpeg = require "lpeg"

return lpeg.P {
  'soundex',
  ignore  = lpeg.S"AEIOUWYHaeiouwyh'"^0,
  skip    = lpeg.S"HWhw"^1,
  cs1     = lpeg.S"BFPVbfpv"^1,
  cs2     = lpeg.S"CGJKQSXZcgjkqsxz"^1,
  cs3     = lpeg.S"DTdt"^1,
  cs4     = lpeg.S"Ll"^1,
  cs5     = lpeg.S"MNmn"^1,
  cs6     = lpeg.S"Rr"^1,
  initial = (lpeg.V"cs1" + lpeg.V"cs2" + lpeg.V"cs3" + lpeg.V"cs4" + lpeg.V"cs5" + lpeg.V"cs6" + lpeg.P(1))
          / function(c) return c:sub(1,1):upper() end,
  keep    = lpeg.V"cs1" * (lpeg.V"skip" * lpeg.V"cs1")^-1 * lpeg.Cc "1"
          + lpeg.V"cs2" * (lpeg.V"skip" * lpeg.V"cs2")^-1 * lpeg.Cc "2"
          + lpeg.V"cs3" * (lpeg.V"skip" * lpeg.V"cs3")^-1 * lpeg.Cc "3"
          + lpeg.V"cs4" * (lpeg.V"skip" * lpeg.V"cs4")^-1 * lpeg.Cc "4"
          + lpeg.V"cs5" * (lpeg.V"skip" * lpeg.V"cs5")^-1 * lpeg.Cc "5"
          + lpeg.V"cs6" * (lpeg.V"skip" * lpeg.V"cs6")^-1 * lpeg.Cc "6"
          +                                         lpeg.Cc "0",
  use     = lpeg.V"ignore" * lpeg.V"keep",
  soundex = lpeg.Cf(lpeg.V"initial" * lpeg.V"use" * lpeg.V"use" * lpeg.V"use",function(a,c) return a..c end),
}
