-- ***************************************************************
--
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
-- ********************************************************************
-- luacheck: ignore 611

local ip   = require "org.conman.parsers.ip-text"
local abnf = require "org.conman.parsers.abnf"
local lpeg = require "lpeg"
local re   = require "re"

-- ************************************************************************
--      RFC-3987
-- ************************************************************************

local G = --[[ lpeg/re ]] [[

IRI_reference   <- {| IRI / irelative_ref |}
IRI             <- scheme ':' ihier_part ('?' iquery)? ('#' ifragment)?

scheme          <- {:scheme: 'https'  & ':' :} {:port: %p443  :}
                /  {:scheme: 'http'   & ':' :} {:port: %p80   :}
                /  {:scheme: 'ftp'    & ':' :} {:port: %p21   :}
                /  {:scheme: 'gemini' & ':' :} {:port: %p1965 :}
                /  {:scheme: 'file'   & ':' :}
                /  {:scheme: %ALPHA (%ALPHA / %DIGIT / '+' / '-' / '.')* :}
                
ihier_part      <- '//' iauthority {:path: ipath_abempty  :}
                /                  {:path: ipath_absolute :}
                /                  {:path: ipath_rootless :}
                /                  {:path: ipath_empty    :}
                
irelative_ref   <- irelative_part ('?' iquery)? ('#' ifragment)?

irelative_part  <- '//' iauthority {:path: ipath_abempty  :}
                /                  {:path: ipath_absolute :}
                /                  {:path: ipath_noscheme :}
                /                  {:path: ipath_empty    :}
                
iauthority      <- (iuserinfo '@')? ihost (':' port)?
iuserinfo       <- {:user: {~ (iunreserved / %pct_encoded / sub_delims / ':')* ~} :}
ihost           <- {:host: IP_literal / %IPv4address / ireg_name :}
port            <- {:port: %DIGIT+ -> tonumber :}

IP_literal      <- '[' ( IPv6addrz / %IPv6address / IPvFuture) ']' -- RFC-6874
IPvFuture       <- { 'v' %HEXDIG+ '.' (iunreserved / sub_delims / ':')+ }
ZoneID          <- {~ (iunreserved / %pct_encoded)+ ~}      -- RFC-6874
IPv6addrz       <- {~ %IPv6address '%25' -> '%%' ZoneID ~} -- RFC-6874
ireg_name       <- {~ (iunreserved / %pct_encoded / sub_delims)* ~}
ipath           <- ipath_abempty  -- begins with '/' or is empty
                /  ipath_absolute -- begins with '/' but not '//'
                /  ipath_noscheme -- begins with a non-colon segment
                /  ipath_rootless -- begins with a segment
                /  ipath_empty
ipath_abempty   <- {~ ( '/' isegment)+                      ~} /  '' -> '/'
ipath_absolute  <- {~   '/' (isegment_nz ('/' isegment)* )? ~}
ipath_noscheme  <- {~ isegment_nz_nc ('/' isegment)*        ~}
ipath_rootless  <- {~ isegment_nz    ('/' isegment)*        ~}
ipath_empty     <- '' -> '/'
isegment        <- ipchar*
isegment_nz     <- ipchar+
isegment_nz_nc  <- (iunreserved / %pct_encoded / sub_delims / '@')+
ipchar          <-  iunreserved / %pct_encoded / sub_delims / '@' / ':'
iquery          <- {:query:    {  (ipchar / '/' / '?')*  } :}
ifragment       <- {:fragment: {~ (ipchar / '/' / '?')* ~} :}
reserved        <- gen_delims / sub_delims
gen_delims      <- ':' / '/' / '?' / '#' / '[' / ']' / '@'
sub_delims      <- '!' / '$' / '&' / "'" / '(' / ')'
                /  '*' / '+' / ',' / ';' / '='
iunreserved     <- %ALPHA / %DIGIT / '-' / '.' / '_' / '~' / %utf8c
]]

-- *********************************************************************

local pct_encoded = (lpeg.P"%" * abnf.HEXDIG * abnf.HEXDIG)
                  / function(capture)
                      local n = tonumber(capture:sub(2,-1),16)
                      return string.char(n)
                    end
local R =
{
  HEXDIG = abnf.HEXDIG,
  ALPHA  = abnf.ALPHA,
  DIGIT  = abnf.DIGIT,
  
  p443        = lpeg.Cc( 443),
  p80         = lpeg.Cc(  80),
  p21         = lpeg.Cc(  21),
  p1965       = lpeg.Cc(1965),
  tonumber    = tonumber,
  IPv4address = ip.IPv4,
  IPv6address = ip.IPv6,
  pct_encoded = pct_encoded,
  utf8c       = require "org.conman.parsers.utf8.char"
}

return re.compile(G,R)
