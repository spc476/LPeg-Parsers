-- ***************************************************************
--
-- Parse an ASV (Ascii Separated Value) file
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
-- ====================================================================
--
-- The BNF is define in RFC-5234.
-- The US-ASCII encoding is defined in RFC-20.
-- The UTF-8 encoding is defined in RFC-3629.
-- The keywords SHOULD and MAY are defined in RFC-2119.
-- HTAB CR LF SP VCHAR are defined in RFC-5234.
--
-- The SP rule MAY be extended to support Unicode whitespace.
--
-- The VCHAR rule MAY be extended to support Uhicode graphic and combining
-- characters.
--
-- The number of units per record per grouping SHOULD be the same.
--
-- The character encoding MAY be US-ASCII or UTF-8.
--
-- file   = group    *(FS group)
-- group  = record   *(GS record)
-- record = [hunit RS] unit *(RS unit) ; *** see notes
-- unit   = data     *(US data)
-- hunit  = FF hdata *(US hdata)
--
-- data   = *(VCHAR / SP / HTAB / CR / LF)
-- hdata  = *(VCHAR / SP)
--
-- FF     = %x0C ; Form Feed
-- FS     = %x1C ; File Separator
-- GS     = %x1D ; Group Separator
-- RS     = %x1E ; Record Separator
-- US     = %x1F ; Unit Separator
--
-- ********************************************************************
-- luacheck: ignore 611

local abnf = require "org.conman.parsers.abnf"
local lpeg = require "lpeg"

local FF = lpeg.P"\f"
local FS = lpeg.P"\28"
local GS = lpeg.P"\29"
local RS = lpeg.P"\30"
local US = lpeg.P"\31"

local hdata = (abnf.VCHAR + abnf.SP)^0
local data  = (abnf.VCHAR + abnf.SP + abnf.HTAB + abnf.CR + abnf.LF)^0

local hunit  = FF * lpeg.Ct(lpeg.C(hdata) * (US * lpeg.C(hdata))^0)
local unit   =      lpeg.Ct(lpeg.C(data)  * (US * lpeg.C( data))^0)
local record = lpeg.Ct(lpeg.Cg((hunit * RS),'headers')^-1 * unit * (RS * unit)^0)
local group  = lpeg.Ct(record * (GS * record)^0)
local file   = lpeg.Ct(group  * (FS *  group)^0)

return {
  record = record,
  group  = group,
  file   = file
}
