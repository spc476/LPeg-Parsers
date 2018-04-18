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

local lpeg     = require "lpeg"
local tonumber = tonumber

local Cmt = lpeg.Cmt
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

local IPv4 = dec_octet * "." * dec_octet * "." * dec_octet * "." * dec_octet

local h16 = Cmt(HEXDIG^1,function(_,position,capture)
  local n = tonumber(capture,16)
  if n < 65536 then
    return position
  end
end)

local h16c = h16 * P":" * #HEXDIG
local ls32 = IPv4 + h16c * h16

local function mh16(n)
  local accum = h16
  for _ = 1 , n do
    accum = h16c * accum
  end
  return accum
end

local function mh16c(n)
  local accum = h16c
  for _ = 2 , n do
    accum = accum * h16c
  end
  return accum
end

local IPv6 =                   mh16c(6) * ls32 -- a
           +           P'::' * mh16c(5) * ls32 -- b
           +           P'::' * mh16c(4) * ls32 -- c
           + h16 *     P'::' * mh16c(4) * ls32
           +           P'::' * mh16c(3) * ls32 -- d
           + h16 *     P'::' * mh16c(3) * ls32
           + mh16(1) * P'::' * mh16c(3) * ls32
           +           P'::' * mh16c(2) * ls32 -- e
           + h16     * P'::' * mh16c(2) * ls32
           + mh16(1) * P'::' * mh16c(2) * ls32
           + mh16(2) * P'::' * mh16c(2) * ls32
           +           P'::' * h16c     * ls32 -- f
           + h16     * P'::' * h16c     * ls32
           + mh16(1) * P'::' * h16c     * ls32
           + mh16(2) * P'::' * h16c     * ls32
           + mh16(3) * P'::' * h16c     * ls32
           +           P'::'            * ls32 -- g
           + h16 *     P'::'            * ls32
           + mh16(1) * P'::'            * ls32
           + mh16(2) * P'::'            * ls32
           + mh16(3) * P'::'            * ls32
           + mh16(4) * P'::'            * ls32
           +           P'::'            * h16  -- h
           + h16     * P'::'            * h16
           + mh16(1) * P'::'            * h16
           + mh16(2) * P'::'            * h16
           + mh16(3) * P'::'            * h16
           + mh16(4) * P'::'            * h16
           + mh16(5) * P'::'            * h16
           +           P'::'                   -- i
           + h16     * P'::'
           + mh16(1) * P'::'
           + mh16(2) * P'::'
           + mh16(3) * P'::'
           + mh16(4) * P'::'
           + mh16(5) * P'::'
           + mh16(6) * P'::'

return { IPv4 = lpeg.C(IPv4) , IPv6 = lpeg.C(IPv6) }
