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

local abnf = require "org.conman.parsers.abnf"
local ip   = require "org.conman.parsers.ip-text"
local lpeg = require "lpeg"

-- ************************************************************************
--      RFC-3261 RFC-3966*
--      sip =
--      {
--        scheme     = 'sip', -- or 'sips'
--        user       = 'sean' or { number = '..' , global = true , parameters = { ... } }
--        password   = 'password',
--        host       = 'conman.org',
--        port       = 5060,
--        parameters = { ... }
--      }
-- ************************************************************************

local Cc = lpeg.Cc
local Cf = lpeg.Cf
local Cg = lpeg.Cg
local Cs = lpeg.Cs
local Ct = lpeg.Ct
local C  = lpeg.C
local P  = lpeg.P
local R  = lpeg.R
local S  = lpeg.S

-- ************************************************************************

local function I(text)
  local mkUl = Cf(
                   (
                     R("AZ","az")
                     / function(c)
                         return P(c:lower()) + P(c:upper())
                       end
                     + P(1)
                     / function(c) return P(c) end
                   )^1,
                   function(a,b) return a * b end
                 )
  return mkUl:match(text) * Cc(text)
end

-- ************************************************************************

local alphanum    = abnf.ALPHA + abnf.DIGIT
local pct_encoded = (P"%" * abnf.HEXDIG * abnf.HEXDIG)
                  / function(capture)
                      local n = tonumber(capture:sub(2,-1),16)
                      return n
                    end
                    
local visual_separator     = lpeg.S"-.()" / ""
local phonedigit           = abnf.DIGIT  + visual_separator
local phonedigit_hex       = abnf.HEXDIG + visual_separator + P"*" + P"#"
local local_number_digits  = Cg(Cs(phonedigit_hex^1),'number')
local global_number_digits = Cg(P"+" * Cc(true),'global')
                           * Cg(Cs(phonedigit^1),'number')
                           
local domainlabel   = alphanum * (alphanum + (P"-" * #alphanum))^0
local domainname    = (domainlabel * P"."^-1)^0
local descriptor    = global_number_digits
                    + Cg(domainname,"domain")
local phone_context = I"phone-context" * P"=" * Ct(descriptor)
local ext           = I"ext"           * P"=" * Cs(phonedigit^1)

local mark             = S"-_.!~*'()"
local unreserved       = alphanum + mark
local param_unreserved = S"[]/:&+$"
local paramchar        = param_unreserved + unreserved + pct_encoded
local pvalue           = Cs(paramchar^1)
local pname            = (alphanum + P"-")^1
local parameter        = phone_context
                       + ext
                       + (pname / function(c) return c:lower() end)
                       * ((P"=" * C(pvalue)) + Cc(true))
local par              = Cf(
                             Ct"" * Cg(P";" * parameter)^0,
                             function(a,i,v) a[i] = v return a end
                           )
                           
local local_number         = local_number_digits  * Cg(par,"parameters") - P";"
local global_number        = global_number_digits * Cg(par,"parameters") - P";"

local telephone_subscriber = (global_number + local_number)
                           - abnf.ALPHA -- XXX hack here
local tel_scheme           = Cg(lpeg.P"tel",'scheme') * P":"

-- ************************************************************************

local uri_parameters  = Cg(par,'parameters')
local user            = unreserved + pct_encoded + S"&=+$,;?/"
local password        = unreserved + pct_encoded + S"&=+$,"
local userinfo        = Cg(Ct(telephone_subscriber),'user') * P'@'
                      + Cg(Cs(user^1),'user')
                      * (P':' * Cg(Cs(password^1),'password'))^-1
                      * P'@'
local host            = Cg(ip.IPv4 + P"[" * ip.IPv6 * P"]" + domainname,'host')
local port            = Cg(abnf.DIGIT^1 / tonumber,'port')
local hostport        = host * (P':' * port)^-1
local sip_scheme      = Cg(P"sip",'scheme')  * Cg(Cc(5060),'port') * P':'
                      + Cg(P"sips",'scheme') * Cg(Cc(5061),'port') * P':'

return Ct(sip_scheme * userinfo^-1 * hostport * uri_parameters)
     + Ct(tel_scheme * telephone_subscriber)
