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

local ip   = require "org.conman.parsers.ip-text"
local abnf = require "org.conman.parsers.abnf"
local lpeg = require "lpeg"
local re   = require "re"

-- ************************************************************************
--      RFC-3986 RFC-6874 RFC-7320
-- ************************************************************************

local G = --[[ lpeg/re ]] [[

URI_reference   <- {| URI / relative_ref |}
URI             <- scheme ':' hier_part ('?' query)? ('#' fragment)?


scheme          <- {:scheme: 'https' :} {:port: %p443 :}
                /  {:scheme: 'http'  :} {:port: %p80  :}
                /  {:scheme: 'ftp'   :} {:port: %p21  :}
                /  {:scheme: 'file'  :}
                /  {:scheme: %ALPHA (%ALPHA / %DIGIT / '+' / '-' / '.')* :}
                
hier_part       <- '//' authority {:path: path_abempty  :}
                /                 {:path: path_absolute :}
                /                 {:path: path_rootless :}
                /                 {:path: path_empty    :}
                
relative_ref    <- relative_part ('?' query)? ('#' fragment)?

relative_part   <- '//' authority {:path: path_abempty  :}
                /                 {:path: path_absolute :}
                /                 {:path: path_noscheme :}
                /                 {:path: path_empty    :}
                
authority       <- (userinfo '@')? host (':' port)?
userinfo        <- {:user: {~ (unreserved / pct_encoded / sub_delims / ':')* ~} :}
host            <- {:host: IP_literal / %IPv4address / reg_name :}
port            <- {:port: %DIGIT* -> tonumber :}

IP_literal      <- '[' ( IPv6addrz / %IPv6address / IPvFuture) ']' -- RFC-6874
IPvFuture       <- { 'v' %HEXDIG+ '.' (unreserved / sub_delims / ':')+ }
ZoneID          <- {~ (unreserved / pct_encoded)+ ~}       -- RFC-6874
IPv6addrz       <- {~ %IPv6address '%25' -> '%%' ZoneID ~} -- RFC-6874
reg_name        <- {~ (unreserved / pct_encoded / sub_delims)* ~}
path            <- path_abempty  -- begins with '/' or is empty
                /  path_absolute -- begins with '/' but not '//'
                /  path_noscheme -- begins with a non-colon segment
                /  path_rootless -- begins with a segment
                /  path_empty
path_abempty    <- {| {:root: %istrue :} ( '/' segment)* |}
path_absolute   <- {| {:root: %istrue :}   '/' (segment_nz ('/' segment)* )? |}
path_noscheme   <- {| segment_nz_nc ('/' segment)* |}
path_rootless   <- {| segment_nz    ('/' segment)* |}
path_empty      <- ! . {| |}
segment         <- ! . / {~ pchar+ ~}
segment_nz      <- {~ pchar+ ~}
segment_nz_nc   <- {~ (unreserved / pct_encoded / sub_delims / ';' / '@')+ ~}
pchar           <-  unreserved / pct_encoded / sub_delims / ':' / '@'
query           <- {:query:    %query :}
fragment        <- {:fragment: {~ (pchar / '/' / '?')* ~} :}
pct_encoded     <- %pct_encoded
reserved        <- gen_delims / sub_delims
gen_delims      <- ':' / '/' / '?' / '#' / '[' / ']' / '@'
sub_delims      <- '!' / '$' / '&' / "'" / '(' / ')'
                /  '*' / '+' / ',' / ';' / '='
unreserved      <- %ALPHA / %DIGIT / '-' / '.' / '_' / '~'
]]

-- *********************************************************************

local function doset(dest,name,value)
  value = value or true
  if dest[name] == nil then
    dest[name] = value
  elseif type(dest[name]) ~= 'table' then
    dest[name] = { dest[name] , value }
  else
    table.insert(dest[name],value)
  end
  return dest
end

local pct_encoded = (lpeg.P"%" * abnf.HEXDIG * abnf.HEXDIG)
                  / function(capture)
                      local n = tonumber(capture:sub(2,-1),16)
                      return string.char(n)
                    end

local char  = pct_encoded + (lpeg.P(1) - lpeg.S"=&#")
local name  = lpeg.Cs(char^1)
local value = lpeg.Cs(char^1)
local pair  = name * (lpeg.P"=" * value)^-1 * lpeg.S"&"^-1

local R =
{
  HEXDIG = abnf.HEXDIG,
  ALPHA  = abnf.ALPHA,
  DIGIT  = abnf.DIGIT,
  
  p443        = lpeg.Cc(443),
  p80         = lpeg.Cc( 80),
  p21         = lpeg.Cc( 21),
  istrue      = lpeg.Cc(true),
  tonumber    = tonumber,
  IPv4address = ip.IPv4,
  IPv6address = ip.IPv6,
  query       = lpeg.Cf(lpeg.Ct"" * (lpeg.Cg(pair))^0,doset),
  pct_encoded = pct_encoded,
}

return re.compile(G,R)
