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
-- luacheck: ignore 611

local abnf     = require "org.conman.parsers.abnf"
local strftime = require "org.conman.parsers.strftime"
local url      = require "org.conman.parsers.url"
local ih       = require "org.conman.parsers.ih"
local lpeg     = require "lpeg"

local Cc = lpeg.Cc
local Cf = lpeg.Cf
local Cg = lpeg.Cg
local Ct = lpeg.Ct
local C  = lpeg.C
local P  = lpeg.P
local R  = lpeg.R
local S  = lpeg.S
local V  = lpeg.V

local TEXT          = R("\1\8","\10\31"," \255")
local separators    = S[[()<>@,;:\<>/[]?={}]]
local token         = (R"!~" - separators)^1
local quoted_pair   = P"\\" * abnf.CHAR
local qdtext        = TEXT - P'"'
local quoted_string = P'"' * (qdtext + quoted_pair)^0 * P'"'
local ctext         = TEXT - S"()"
local comment       =
{
  "comment",
  comment = P"(" * (ctext + quoted_pair + V"comment")^0 * P")"
}

local attribute      = token
local value          = token + quoted_string
local parameter      = attribute * P"=" * value
local type           = token
local subtype        = token
local media_type     = Ct(
                           Cg(type * P"/" * subtype,"media")
                         * Cg(
                             Cf(
                               Ct"" * (P";" * abnf.LWSP^-1 * Cg(parameter))^1,
                               function(t,k,v)
                                 t[k] = v
                                 return t
                               end
                             ),
                             'params'
                           )^-1
                       )
local HTTP_date = strftime:match "%a, %d %b %Y %H:%M:%S %Z"

local cache_response_directive = Cf(Ct"" * (
                  Cg(C'public'           * Cc(true))
                + Cg(C'private'          * C(quoted_string))
                + Cg(C'no-cache'         * C(quoted_string))
                + Cg(C'no-store'         * Cc(true))
                + Cg(C'must-revalidate'  * Cc(true))
                + Cg(C'proxy-revalidate' * Cc(true))
                + Cg(C'max-age'          * P"=" * (R"09"^1 / tonumber))
                + Cg(C's-maxage'         * P"=" * (R"09"^1 / tonumber))
                + Cg(C(token)            * P"=" * C(token + quoted_string))
                ),
                function(t,k,v)
                  t[k] = v
                  return t
                end
            )
            
local version    = P"HTTP/1.1" * Cc "1.1"
                 + P"HTTP/1.0" * Cc "1.0"
                 +               Cc "0.9"
local indication = #P"1" * Cc'info'
                 + #P"2" * Cc'success'
                 + #P"3" * Cc'redirect'
                 + #P"4" * Cc'clienterr'
                 + #P"5" * Cc'servererr'
local status     = (R"15" * R"09" * R"09") / tonumber
local msg        = R(" ~")^0
local response   = Ct(
                         Cg(version,   'version') * abnf.WSP
                       * Cg(indication,'indication')
                       * Cg(status,    'status')  * abnf.WSP
                       * Cg(msg,       'msg')
                     )
                     
local header  = ih.Hc"Date"             * ih.COLON * HTTP_date                * abnf.CRLF
              + ih.Hc"Content-Length"   * ih.COLON * (R"09"^1 / tonumber)     * abnf.CRLF
              + ih.Hc"Content-Location" * ih.COLON * url                      * abnf.CRLF
              + ih.Hc"Content-Type"     * ih.COLON * media_type               * abnf.CRLF
              + ih.Hc"Location"         * ih.COLON * url                      * abnf.CRLF
              + ih.Hc"ETag"             * ih.COLON * P"W/"^-1 * quoted_string * abnf.CRLF
              + ih.Hc"Connection"       * ih.COLON * token                    * abnf.CRLF
              + ih.Hc"Expires"          * ih.COLON * HTTP_date                * abnf.CRLF
              + ih.Hc"Last-Modified"    * ih.COLON * HTTP_date                * abnf.CRLF
              + ih.Hc"Cache-Control"    * ih.COLON * cache_response_directive * abnf.CRLF
              + ih.generic

return {
  response = response,
  headers  = ih.headers(header),
}

--[[
Access-Control-Allow-Origin
Access-Control-Allow-Credentials
Access-Control-Expose-Headers
Access-Control-Max-Age
Access-Control-Allow-Methods
Access-Control-Allow-Headers
Accept-Patch
Accept-Ranges
Age
Allow
Alt-Svc
Content-Disposition
Content-Encoding
Content-Language
Content-Range
Delta-Base
IM
Last-Modified
Link
P3P
Pragma
Proxy-Authenticate
Public-Key-Pins
Retry-After
Server
Set-Cookie
Strict-Transport-Security
Trailer
Transfer-Encoding
Tk
Upgrade
Vary
Via
Warning
WWW-Authenticate
--]]
