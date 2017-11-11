-- ***************************************************************
--
-- Copyright 2013 by Sean Conner.  All Rights Reserved.
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
-- luacheck: globals IPv4 IPv6
-- luacheck: ignore 611

local floor    = math.floor
local string   = string
local tonumber = tonumber
local lpeg     = require "lpeg"

local Cf = lpeg.Cf
local Cc = lpeg.Cc
local C  = lpeg.C
local P  = lpeg.P

module(...)

-- *********************************************************************

local function acc(a,v) return a .. v end

local DIGIT  = lpeg.locale().digit
local HEXDIG = lpeg.locale().xdigit

local dec_octet = C(DIGIT^1)
                / function(c)
                    local n = tonumber(c)
                    if n < 256 then
                      return string.char(n)
                    end
                  end
                  
IPv4 = Cf(
        Cc"" * dec_octet * "." * dec_octet * "." * dec_octet * "." * dec_octet,
        acc
)

local h16  = C(HEXDIG^1)
           / function(c)
               local n = tonumber(c,16)
               if n < 65536 then
                 local q = floor(n/256)
                 local r = n % 256
                 return string.char(q) .. string.char(r)
               end
             end
             
local h16c = h16 * P":" * #HEXDIG
local ls32 = IPv4 + h16c * h16

local function mcc(n)
  return P"::" / string.rep("\0",n * 2)
end

local function mh16(n)
  local accum = P(true)
  for _ = 1 , n-1 do
    accum = accum * h16c
  end
  accum = accum * h16
  return accum
end

local function mh16c(n)
  local accum = P(true)
  for _ = 1 , n do
    accum = accum * h16c
  end
  return accum
end

IPv6 = Cf(Cc"" *                    mh16c(6) * ls32,acc)        -- a
     + Cf(Cc"" *           mcc(1) * mh16c(5) * ls32,acc)        -- b
     + Cf(Cc"" *           mcc(2) * mh16c(4) * ls32,acc)        -- c
     + Cf(Cc"" * h16 *     mcc(1) * mh16c(4) * ls32,acc)
     + Cf(Cc"" *           mcc(3) * mh16c(3) * ls32,acc)        -- d
     + Cf(Cc"" * h16 *     mcc(2) * mh16c(3) * ls32,acc)
     + Cf(Cc"" * mh16(2) * mcc(1) * mh16c(3) * ls32,acc)
     + Cf(Cc"" *           mcc(4) * mh16c(2) * ls32,acc)        -- e
     + Cf(Cc"" * h16     * mcc(3) * mh16c(2) * ls32,acc)
     + Cf(Cc"" * mh16(2) * mcc(2) * mh16c(2) * ls32,acc)
     + Cf(Cc"" * mh16(3) * mcc(1) * mh16c(2) * ls32,acc)
     + Cf(Cc"" *           mcc(5) * h16c     * ls32,acc)        -- f
     + Cf(Cc"" * h16     * mcc(4) * h16c     * ls32,acc)
     + Cf(Cc"" * mh16(2) * mcc(3) * h16c     * ls32,acc)
     + Cf(Cc"" * mh16(3) * mcc(2) * h16c     * ls32,acc)
     + Cf(Cc"" * mh16(4) * mcc(1) * h16c     * ls32,acc)
     + Cf(Cc"" *           mcc(6)            * ls32,acc)        -- g
     + Cf(Cc"" * h16 *     mcc(5)            * ls32,acc)
     + Cf(Cc"" * mh16(2) * mcc(4)            * ls32,acc)
     + Cf(Cc"" * mh16(3) * mcc(3)            * ls32,acc)
     + Cf(Cc"" * mh16(4) * mcc(2)            * ls32,acc)
     + Cf(Cc"" * mh16(5) * mcc(1)            * ls32,acc)
     + Cf(Cc"" *           mcc(7)            * h16 ,acc)        -- h
     + Cf(Cc"" * h16     * mcc(6)            * h16 ,acc)
     + Cf(Cc"" * mh16(2) * mcc(5)            * h16 ,acc)
     + Cf(Cc"" * mh16(3) * mcc(4)            * h16 ,acc)
     + Cf(Cc"" * mh16(4) * mcc(3)            * h16 ,acc)
     + Cf(Cc"" * mh16(5) * mcc(2)            * h16 ,acc)
     + Cf(Cc"" * mh16(6) * mcc(1)            * h16 ,acc)
     + Cf(Cc"" *           mcc(8)                  ,acc)        -- i
     + Cf(Cc"" * mh16(1) * mcc(7)                  ,acc)
     + Cf(Cc"" * mh16(2) * mcc(6)                  ,acc)
     + Cf(Cc"" * mh16(3) * mcc(5)                  ,acc)
     + Cf(Cc"" * mh16(4) * mcc(4)                  ,acc)
     + Cf(Cc"" * mh16(5) * mcc(3)                  ,acc)
     + Cf(Cc"" * mh16(6) * mcc(2)                  ,acc)
     + Cf(Cc"" * mh16(7) * mcc(1)                  ,acc)
     
