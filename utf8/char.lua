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
-- Parse a valid UTF-8 non-control character.
--
-- ********************************************************************
-- luacheck: ignore 611

local lpeg = require "lpeg"

return lpeg.P"\194"     * lpeg.R"\160\191"
     + lpeg.R"\195\223" * lpeg.R"\128\191"
     + lpeg.P"\224"     * lpeg.R"\160\191" * lpeg.R"\128\191"
     + lpeg.R"\225\236" * lpeg.R"\128\191" * lpeg.R"\128\191"
     + lpeg.P"\237"     * lpeg.R"\128\159" * lpeg.R"\128\191"
     + lpeg.R"\238\239" * lpeg.R"\128\191" * lpeg.R"\128\191"
     + lpeg.P"\240"     * lpeg.R"\144\191" * lpeg.R"\128\191" * lpeg.R"\128\191"
     + lpeg.R"\241\243" * lpeg.R"\128\191" * lpeg.R"\128\191" * lpeg.R"\128\191"
     + lpeg.P"\244"     * lpeg.R"\128\143" * lpeg.R"\128\191" * lpeg.R"\128\191"
