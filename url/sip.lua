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
-- luacheck: ignore 611 631

local abnf = require "org.conman.parsers.abnf"
local ip   = require "org.conman.parsers.ip-text"
local tel  = require "org.conman.parsers.url.tel"
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
local Cg = lpeg.Cg
local Cs = lpeg.Cs
local Ct = lpeg.Ct
local P  = lpeg.P
local S  = lpeg.S

local alphanum = abnf.ALPHA + abnf.DIGIT

local uri_parameters  = Cg(tel.par,'parameters')

local user     = tel.unreserved + tel.pct_encoded + S"&=+$,;?/"
local password = tel.unreserved + tel.pct_encoded + S"&=+$,"
local userinfo = Cg(Ct(tel.telephone_subscriber),'user') * P'@'
               + Cg(Cs(user^1),'user')
               * (P':' * Cg(Cs(password^1),'password'))^-1
               * P'@'
               
local domainlabel = alphanum * (alphanum + ('-' * #alphanum))^0
local hostname    = (domainlabel * P'.'^-1)^1

local host        = Cg(ip.IPv4 + ip.IPv6 + hostname,'host')
local port        = Cg(abnf.DIGIT^1 / tonumber,'port')
local hostport    = host * (P':' * port)^-1

local scheme = Cg(P"sip",'scheme')  * Cg(Cc(5060),'port') * P':'
             + Cg(P"sips",'scheme') * Cg(Cc(5061),'port') * P':'
local sip    = Ct(scheme * userinfo^-1 * hostport * uri_parameters)

return sip
