-- ***************************************************************
--
-- Copyright 2018 by Sean Conner.  All Rights Reserved.
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

local abnf  = require "org.conman.parsers.abnf"
local ip    = require "org.conman.parsers.ip-text"
local lpeg  = require "lpeg"
local re    = require "re"

local tonumber = tonumber

-- ************************************************************************
-- RFC-4266 The gopher URI Scheme
--
-- Doesn't really go into that great of detail.  It appears that %-encoding
-- is only done for spaces, and in the plus area, for SP, CR, LF and TAB,
-- from the only few examples I found at
--
-- http://www.w3.org/Addressing/URL/4_1_Gopher+.html
--
-- So, that's what I'm going with.
--
--      gopher =
--      {
--        scheme   = 'gopher',
--        host     = "conman.org",
--        port     = 70,
--        type     = '1',
--        selector = "string",
--        search   = "string",          -- optional
--        plus     = "string",          -- optional
--      }
-- ************************************************************************

local G = --[[ lpeg/re ]] [[

gopher_url      <- {:scheme:   'gopher' :}
                   {:port:     %p70     :}
                   {:type:     %type    :}
                   {:selector:          :}
                   '://' host (':' port)? gopher_path?
gopher_path     <- '/'
                   {:type:     gopher_type  :}
                   {:selector: {~ gopher_char* ~} :}
                   (
                       '%09' {:search: {~ gopher_char* ~} :}
                     ( '%09' {:plus:   {~ gopher_char* ~} :} )?
                   )?
gopher_type     <- gopher_char
gopher_char     <- ! '%09' (%pct_encoded / .)
host            <- {:host: IP_literal / %IPv4address / reg_name :}
port            <- {:port: %DIGIT* -> tonumber :}
IP_literal      <- '[' ( IPv6addrz / %IPv6address / IPvFuture ) ']' -- RFC-6874
IPvFuture       <- { 'v' %HEXDIG+ '.' (unreserved / sub_delims / ':')+ }
IPv6addrz       <- {~ %IPv6address '%25' -> '%%' ZoneID ~} -- RFC-6874
ZoneID          <- {~ (unreserved / %pct_encoded)+ ~}      -- RFC-6874
reg_name        <- {~ (unreserved / %pct_encoded / sub_delims)* ~}
sub_delims      <- '!' / '$' / '&' / "'" / '(' / ')'
                /  '*' / '+' / ',' / ';' / '='
unreserved      <- %ALPHA / %DIGIT / '-' / '.' / '_' / '~'
]]

local R =
{
  DIGIT       = abnf.DIGIT,
  HEXDIG      = abnf.HEXDIG,
  ALPHA       = abnf.ALPHA,
  p70         = lpeg.Cc(70),
  type        = lpeg.Cc('1'),
  tonumber    = tonumber,
  IPv6address = ip.IPv6,
  IPv4address = ip.IPv4,
  pct_encoded = (lpeg.P"%" * abnf.HEXDIG * abnf.HEXDIG)
              / function(capture)
                  local n = tonumber(capture:sub(2,-1),16)
                  return string.char(n)
                end,
}

return lpeg.Ct(re.compile(G,R))

-- ************************************************************************
