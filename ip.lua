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
-- luacheck: ignore 611

local floor    = math.floor
local string   = string
local tonumber = tonumber
local lpeg     = require "lpeg"

local Cmt = lpeg.Cmt
local Cf  = lpeg.Cf
local P   = lpeg.P

-- *********************************************************************

local function acc(a,v) return a .. v end

local DIGIT  = lpeg.locale().digit
local HEXDIG = lpeg.locale().xdigit

local dec_octet = Cmt(DIGIT^1,function(_,position,capture)
  local n = tonumber(capture)
  if n < 256 then
    return position,string.char(n)
  end
end)

local IPv4 = Cf(
                 dec_octet * "." * dec_octet * "." * dec_octet * "." * dec_octet,
                 acc
               )

local h16 = Cmt(HEXDIG^1,function(_,position,capture)
  local n = tonumber(capture,16)
  if n < 65536 then
    local q = floor(n/256)
    local r = n % 256
    return position,string.char(q) .. string.char(r)
  end
end)

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

local IPv6 = Cf(                   mh16c(6) * ls32,acc)        -- a
           + Cf(          mcc(1) * mh16c(5) * ls32,acc)        -- b
           + Cf(          mcc(2) * mh16c(4) * ls32,acc)        -- c
           + Cf(h16 *     mcc(1) * mh16c(4) * ls32,acc)
           + Cf(          mcc(3) * mh16c(3) * ls32,acc)        -- d
           + Cf(h16 *     mcc(2) * mh16c(3) * ls32,acc)
           + Cf(mh16(2) * mcc(1) * mh16c(3) * ls32,acc)
           + Cf(          mcc(4) * mh16c(2) * ls32,acc)        -- e
           + Cf(h16     * mcc(3) * mh16c(2) * ls32,acc)
           + Cf(mh16(2) * mcc(2) * mh16c(2) * ls32,acc)
           + Cf(mh16(3) * mcc(1) * mh16c(2) * ls32,acc)
           + Cf(          mcc(5) * h16c     * ls32,acc)        -- f
           + Cf(h16     * mcc(4) * h16c     * ls32,acc)
           + Cf(mh16(2) * mcc(3) * h16c     * ls32,acc)
           + Cf(mh16(3) * mcc(2) * h16c     * ls32,acc)
           + Cf(mh16(4) * mcc(1) * h16c     * ls32,acc)
           + Cf(          mcc(6)            * ls32,acc)        -- g
           + Cf(h16 *     mcc(5)            * ls32,acc)
           + Cf(mh16(2) * mcc(4)            * ls32,acc)
           + Cf(mh16(3) * mcc(3)            * ls32,acc)
           + Cf(mh16(4) * mcc(2)            * ls32,acc)
           + Cf(mh16(5) * mcc(1)            * ls32,acc)
           + Cf(          mcc(7)            * h16 ,acc)        -- h
           + Cf(h16     * mcc(6)            * h16 ,acc)
           + Cf(mh16(2) * mcc(5)            * h16 ,acc)
           + Cf(mh16(3) * mcc(4)            * h16 ,acc)
           + Cf(mh16(4) * mcc(3)            * h16 ,acc)
           + Cf(mh16(5) * mcc(2)            * h16 ,acc)
           + Cf(mh16(6) * mcc(1)            * h16 ,acc)
           + Cf(          mcc(8)                  ,acc)        -- i
           + Cf(h16     * mcc(7)                  ,acc)
           + Cf(mh16(2) * mcc(6)                  ,acc)
           + Cf(mh16(3) * mcc(5)                  ,acc)
           + Cf(mh16(4) * mcc(4)                  ,acc)
           + Cf(mh16(5) * mcc(3)                  ,acc)
           + Cf(mh16(6) * mcc(2)                  ,acc)
           + Cf(mh16(7) * mcc(1)                  ,acc)

return { IPv4 = IPv4 , IPv6 = IPv6 }
