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
-- ====================================================================
--
-- BNF rules per RFC-5234.  These are common among a lot of RFCs, so it
-- makes sense to define them in one place to be used elsewhere.
--
-- ********************************************************************
-- luacheck: ignore 611

local lpeg = require "lpeg"
local abnf =
{
  ALPHA  = lpeg.R("AZ","az"),
  BIT    = lpeg.P"0" + lpeg.P"1",
  CHAR   = lpeg.R"\1\127",
  CR     = lpeg.P"\r",
  CRLF   = lpeg.P"\r"^-1 * lpeg.P"\n", -- [1]
  CTL    = lpeg.R("\0\31","\127\127"),
  DIGIT  = lpeg.R"09",
  DQUOTE = lpeg.P'"',
  HEXDIG = lpeg.R("09","AF","af"), -- [2]
  HTAB   = lpeg.P"\t",
  LF     = lpeg.P"\n",
  OCTET  = lpeg.P(1),
  SP     = lpeg.P" ",
  VCHAR  = lpeg.R"!~",
}

abnf.WSP  = abnf.SP + abnf.HTAB
abnf.LWSP = (abnf.WSP + abnf.CRLF * abnf.WSP)^0 -- [3]

return abnf

-- ********************************************************************
--
-- [1]	I made the CR optional, as it makes it easier to test on the command
--	line under Unix, which only uses LF to mark end of lines.  This
--	should not effect the resulting parsers in any way.
--
--	Famous last words.
--
-- [2]	The definition in RFC-5234 only allows upper case.  I'm being
--	lenient here.
--
-- [3]	As noted in RFC-5234, this rule should NOT be used for email
--	headers.
--
-- ********************************************************************
