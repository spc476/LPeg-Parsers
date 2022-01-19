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


local abnf    = require "org.conman.parsers.abnf"
local types   = require "org.conman.const.gopher-types"
local control = require "org.conman.parsers.utf8.control"
              + require "org.conman.parsers.iso.control"
              + require "org.conman.parsers.ascii.control"
local lpeg    = require "lpeg"

local Cc = lpeg.Cc
local Cg = lpeg.Cg
local Cs = lpeg.Cs
local Ct = lpeg.Ct
local P  = lpeg.P
local R  = lpeg.R

local text     = Cs((#-(abnf.CRLF + abnf.HTAB) * control / "" + R" \255")^0)
local type     = Cg(R" ~" * #-abnf.CRLF / types,'type')
local display  = Cg(text,'display')
local selector = abnf.HTAB * Cg(R" \255"^0,'selector')             + Cg(Cc"",'selector')
local host     = abnf.HTAB * Cg(R" \255"^0,'host')                 + Cg(Cc"example.com",'host')
local port     = abnf.HTAB * Cg(R"09"^1 / tonumber + Cc(0),'port') + Cg(Cc(0),'port')
local gplus    = abnf.HTAB * Cg(R" \255"^0,'gplus')
local line     = Ct(type * display * selector * host * port * gplus^-1) * (abnf.CRLF + P(-1))
               + abnf.CRLF
return Ct(line^1) * (P"." * abnf.CRLF)^-1
