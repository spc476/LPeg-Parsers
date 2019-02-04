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
-- Parse a valid UTF-8 control character.
--
-- ********************************************************************
-- luacheck: ignore 611

local lpeg  = require "lpeg"
local utf8  = require "org.conman.parsers.utf8.char"
local ascii = require "org.conman.parsers.ascii.char"

local CSI = lpeg.P"\194\155" + lpeg.P"\27["
local OSC = lpeg.P"\194\157" + lpeg.P"\27]"
local ST  = lpeg.P"\194\156" + lpeg.P"\27\\"
local str = lpeg.P"\194" * lpeg.S"\144\152\158\159"
          + lpeg.P"\27"  * lpeg.S"PX^_"

return CSI * lpeg.R"0?"^0 * lpeg.R" /"^0 * lpeg.R"@~"
     + OSC * (lpeg.R"\8\13" + ascii + utf8)^0 * (ST + lpeg.P"\7") -- xterm uses BEL
     + str * (lpeg.R"\8\13" + ascii + utf8)^0 * ST
     + lpeg.P"\27"  * lpeg.R"`~"       -- 7-bit of C1
     + lpeg.P"\194" * lpeg.R"\128\159" -- rest of C1
     + lpeg.P"\27"  * lpeg.R"@_"       -- rest of C1 (7-bits)
