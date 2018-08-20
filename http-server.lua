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

local dump     = require "org.flummux.dump"
local abnf     = require "org.conman.parsers.abnf"
local strftime = require "org.conman.parsers.strftime"
local url      = require "org.conman.parsers.url.url"
local lpeg     = require "lpeg"

local Cb = lpeg.Cb
local Cc = lpeg.Cc
local Cf = lpeg.Cf
local Cg = lpeg.Cg
local Ct = lpeg.Ct
local C  = lpeg.C
local P  = lpeg.P
local R  = lpeg.R
local S  = lpeg.S
local V  = lpeg.V

local function H(t)
  return C(t)
end

local header_name  = (P(1) - P":")^1
local header_value = R" ~"^0

local COLON         = P":" * abnf.LWSP
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

local attribute       = token
local value           = token + quoted_string
local parameter       = C(attribute) * P"=" * C(value)
local type            = token
local subtype         = token
local media_type      = Ct(
                             Cg(type * P"/" * subtype,"media")
                           * Cg(Ct"" / function(t) t.q = "1.0" return t end,"params")
                           * Cg(
                                 Cf(
                                 
                                     Cb'params'
                                     * (P";" * abnf.LWSP^-1 * Cg(parameter))^1,
                                     function(t,k,v)
                                       t[k] = v
                                       return t
                                     end
                                   )
                                 + Cb'params',
                                 'params'
                               )
                          )
local media_type_list = Ct(media_type * (abnf.LWSP^-1 * P"," * abnf.LWSP^-1 * media_type)^0)
local HTTP_date       = strftime:match "%a, %d %b %Y %H:%M:%S"
local cache_directive = Cf(Ct"" * (
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
            
local Method  = P"OPTIONS"
              + P"GET"
              + P"HEAD"
              + P"POST"
              + P"PUT"
              + P"DELETE"
              + P"TRACE"
              + P"CONNECT"
              + token
local version = P"HTTP/1.1" * Cc"1.1"
              + P"HTTP/1.0" * Cc"1.0"
              +               Cc"0.9"
local request = Ct(
                       Cg(Method, 'method')   * abnf.WSP
                     * Cg(url,    'location') * abnf.WSP
                     * Cg(version,'version')
                  )
local header  = H"Date"           * COLON *  HTTP_date           * abnf.CRLF
              + H"Content-Length" * COLON * (R"09"^1 / tonumber) * abnf.CRLF
              + H"Content-Type"   * COLON * media_type           * abnf.CRLF
              + H"Connection"     * COLON * C(token)             * abnf.CRLF
              + H"Cache-Control"  * COLON * cache_directive      * abnf.CRLF
              + H"User-Agent"     * COLON * C(R" ~"^0)           * abnf.CRLF
              + H"Accept"         * COLON * media_type_list      * abnf.CRLF
              + C(header_name)    * COLON * C(header_value)      * abnf.CRLF
              
local headers = Cf(Ct"" * Cg(header)^1 * abnf.CRLF,function(t,k,v)
  if t[k] == nil then
    t[k] = v
  else
    if k == 'Accept' then
      for _,item in ipairs(v) do
        table.insert(t[k],item)
      end
    else
      if type(t[k]) ~= 'table' then
        t[k] = { t[k] , v }
      else
        table.insert(t[k],v)
      end
    end
  end
  return t
end)

return {
  request = request,
  headers = headers,
}

--[[
A-IM
Accept-Charset
Accept-Encoding
Accept-Language
Accept-Datetime
Access-Control-Request-Method
Access-Control-Request-Headers
Authorization
Cookie
Expect
Forwarded
From
Host
If-Match
If-Modified-Since
If-None-Match
If-Range
If-Unmodified-Since
Max-Forwards
Origin
Pragma
Proxy-Authorization
Range
Referer
TE
User-Agent
Upgrade
Via
Warning
--]]
