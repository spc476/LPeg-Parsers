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

local tonumber = tonumber
local lpeg     = require "lpeg"

local Cmt = lpeg.Cmt
local Cc  = lpeg.Cc
local C   = lpeg.C
local P   = lpeg.P

-- *********************************************************************

local DIGIT  = lpeg.locale().digit
local HEXDIG = lpeg.locale().xdigit

local dec_octet = Cmt(DIGIT^1,function(_,position,capture)
  local n = tonumber(capture)
  if n < 256 then
    return position
  end
end)

local IPv4 = C(dec_octet * "." * dec_octet * "." * dec_octet * "." * dec_octet)

local h16 = Cmt(HEXDIG^1,function(_,position,capture)
  local n = tonumber(capture,16)
  if n < 65536 then
    return position
  end
end)

local h16c = h16 * P":" * #HEXDIG
local ls32 = IPv4 + h16c * h16

local function mcc()
  return P"::"
end

local function mh16(n)
  local accum = h16c
  for _ = 2 , n - 1 do
    accum = accum * h16c
  end
  return accum * h16
end

local function mh16c(n)
  local accum = h16c
  for _ = 2 , n do
    accum = accum * h16c
  end
  return accum
end

local IPv6 = C(Cc"" *                   mh16c(6) * ls32) -- a
           + C(Cc"" *           mcc() * mh16c(5) * ls32) -- b
           + C(Cc"" *           mcc() * mh16c(4) * ls32) -- c
           + C(Cc"" * h16 *     mcc() * mh16c(4) * ls32)
           + C(Cc"" *           mcc() * mh16c(3) * ls32) -- d
           + C(Cc"" * h16 *     mcc() * mh16c(3) * ls32)
           + C(Cc"" * mh16(2) * mcc() * mh16c(3) * ls32)
           + C(Cc"" *           mcc() * mh16c(2) * ls32) -- e
           + C(Cc"" * h16     * mcc() * mh16c(2) * ls32)
           + C(Cc"" * mh16(2) * mcc() * mh16c(2) * ls32)
           + C(Cc"" * mh16(3) * mcc() * mh16c(2) * ls32)
           + C(Cc"" *           mcc() * h16c     * ls32) -- f
           + C(Cc"" * h16     * mcc() * h16c     * ls32)
           + C(Cc"" * mh16(2) * mcc() * h16c     * ls32)
           + C(Cc"" * mh16(3) * mcc() * h16c     * ls32)
           + C(Cc"" * mh16(4) * mcc() * h16c     * ls32)
           + C(Cc"" *           mcc()            * ls32) -- g
           + C(Cc"" * h16 *     mcc()            * ls32)
           + C(Cc"" * mh16(2) * mcc()            * ls32)
           + C(Cc"" * mh16(3) * mcc()            * ls32)
           + C(Cc"" * mh16(4) * mcc()            * ls32)
           + C(Cc"" * mh16(5) * mcc()            * ls32)
           + C(Cc"" *           mcc()            * h16 ) -- h
           + C(Cc"" * h16     * mcc()            * h16 )
           + C(Cc"" * mh16(2) * mcc()            * h16 )
           + C(Cc"" * mh16(3) * mcc()            * h16 )
           + C(Cc"" * mh16(4) * mcc()            * h16 )
           + C(Cc"" * mh16(5) * mcc()            * h16 )
           + C(Cc"" * mh16(6) * mcc()            * h16 )
           + C(Cc"" *           mcc()                  ) -- i
           + C(Cc"" * h16     * mcc()                  )
           + C(Cc"" * mh16(2) * mcc()                  )
           + C(Cc"" * mh16(3) * mcc()                  )
           + C(Cc"" * mh16(4) * mcc()                  )
           + C(Cc"" * mh16(5) * mcc()                  )
           + C(Cc"" * mh16(6) * mcc()                  )
           + C(Cc"" * mh16(7) * mcc()                  )

return { IPv4 = IPv4 , IPv6 = IPv6 }
