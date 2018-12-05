-- ************************************************************************
--
--    Parse a gopher index file.
--    Copyright 2018 by Sean Conner.  All Rights Reserved.
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--    Comments, questions and criticisms can be sent to: sean@conman.org
--
-- ************************************************************************
-- luacheck: ignore 611


local abnf  = require "org.conman.parsers.abnf"
local types = require "org.conman.const.gopher-types"
local lpeg  = require "lpeg"

local Cc = lpeg.Cc
local Cg = lpeg.Cg
local Ct = lpeg.Ct
local P  = lpeg.P
local R  = lpeg.R

local type        = P(1) / types
local display     = R" \255"^0
local selector    = R" \255"^0
local host        = R" \255"^0
local port        = R"09"^1 / tonumber
                  + Cc(0)
local line        = Ct(
                          Cg(type,'type')
                        * Cg(display,'display')   * abnf.HTAB
                        * Cg(selector,'selector') * abnf.HTAB
                        * Cg(host,'host')         * abnf.HTAB
                        * Cg(port,'port')
                        * R("\9\9"," \255")^0 -- slurp up rest of line
                        * abnf.CRLF
                      )
return Ct(line^1)
