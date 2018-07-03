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

local os   = require "os"
local lpeg = require "lpeg"

local tonumber = tonumber
local error    = error
local string   = string

local Cmt  = lpeg.Cmt
local Cg   = lpeg.Cg
local Ct   = lpeg.Ct
local Cf   = lpeg.Cf
local Cs   = lpeg.Cs
local C    = lpeg.C
local P    = lpeg.P
local S    = lpeg.S
local R    = lpeg.R

-- ***********************************************************************
-- The following could be done easier and simpler with nl_langinfo(),
-- but that isn't portable (being a GNU extension).  This *is* portable,
-- although we cannot get the formats used for "%c", "%x" or "%X".
-- ***********************************************************************

local short_months = {}
local long_months  = {}
local short_days   = {}
local long_days    = {}
local am_pm        = {}

do
  local key
  local now = { year = 2013 , month = 1 , day = 1 , hour = 0 }
  
  for m = 1 , 12 do
    now.month = m
    key = os.date("%b", os.time(now))
    short_months[key] = m
    key = os.date("%B", os.time(now))
    long_months[key] = m
  end
  
  for d = 1 , 7 do
    now.day = d
    key = os.date("%a", os.time(now))
    short_days[key] = d
    key = os.date("%A", os.time(now))
    long_days[key] = d
  end
  
  now.hour   = 0
  key        = os.date("%p", os.time(now))
  am_pm[key] = 0
  
  am_pm[key:lower()] = 0 -- GNU extension

  now.hour   = 12
  key        = os.date("%p", os.time(now))
  am_pm[key] = 12

  am_pm[key:lower()] = 12 -- GNU extension

end

-- ********************************************************************

local function chkrange(min,max)
  return function(_,position,capture)
    local val = tonumber(capture)
    if val < min or val > max then
      return false
    else
      return position,val
    end
  end
end

local utf8c    = R"\128\191"
local utf8     = R"\192\207" * utf8c
               + R"\208\223" * utf8c * utf8c
               + R"\224\247" * utf8c * utf8c * utf8c
               + R"\248\251" * utf8c * utf8c * utf8c * utf8c
               + R"\252\253" * utf8c * utf8c * utf8c * utf8c * utf8c
local char     = R("AZ","az") + utf8
local digit    = R"09"

local dday     = Cmt(digit * digit,        chkrange(1, 31))
local d24hour  = Cmt(digit * digit,        chkrange(0, 23))
local d12hour  = Cmt(digit * digit,        chkrange(1, 12))
local ddyear   = Cmt(digit * digit * digit,chkrange(1,366))
local dmonth   = Cmt(digit * digit,        chkrange(1, 12))
local dminute  = Cmt(digit * digit,        chkrange(0, 59))
local dsecond  = Cmt(digit * digit,        chkrange(0, 61))
local dweeknum = Cmt(digit * digit,        chkrange(0, 53))
local dweek    = Cmt(digit,                chkrange(0,  6))
local d2year   = (digit * digit) / function(c) return c + 1900 end
local d4year   = (digit * digit * digit * digit) / tonumber
local number   = (S"-+" * digit * digit * digit * digit)
local dweek1   = Cmt(digit, function(_,position,capture)
			      local v = tonumber(capture)
			      if v < 1 or v > 7 then
			        return false
			      else
			        if v == 7 then
			          v = 0
			        end
			        return position,v
			      end
			    end)

-- ********************************************************************

local oct     = R"07"
local hex     = R("09","AF","af")
local normal  = C(P(1) - (P[[\]] + P"%"))
local escaped = P[[\n]] / "\n"
              + P[[\t]] / "\t"
              + P[[\v]] / "\v"
              + P[[\b]] / "\b"
              + P[[\r]] / "\r"
              + P[[\f]] / "\f"
              + P[[\a]] / "\a"
              + P[[\\]] / "\\"
              + P[[\?]] / "?"
              + P[[\']] / "'"
              + P[[\"]] / '"'
              + P[[\]]  * C(oct * oct * oct) / function(c) return tonumber(c,8) end
              + P[[\x]] * C(hex * hex)       / function(c) return tonumber(c,16) end
local text    = Cs((escaped + normal)^1)
              / function(c) return P(c) end

-- -------------------------------------------------------------------

local directives = P"a" / function()
                      return Cg(char^1 / short_days,"wday")
                    end

           + P"A" / function()
                      return Cg(char^1 / long_days,"wday")
                    end

           + P"b" / function()
                      return Cg(char^1 / short_months,"month")
                    end

           + P"B" / function()
                      return Cg(char^1 / long_months,"month")
                    end

           + P"c" / function()
                      error("%c format specifier not supported")
                    end

           + P"d" / function()
                      return Cg(dday,"day")
                    end

           + P"H" / function()
                      return Cg(d24hour,"hour")
                    end

           + P"I" / function()
                      return Cg(d12hour,"hour")
                    end

           + P"j" / function()
                      return Cg(ddyear,"yday")
                    end

           + P"m" / function()
                      return Cg(dmonth,"month")
                    end

           + P"M" / function()
                      return Cg(dminute,"min")
                    end

           + P"p" / function()
                      return Cg(char^1 / am_pm,"pm")
                    end

           + P"S" / function()
                      return Cg(dsecond,"sec")
                    end

           + P"U" / function()
                      return Cg(dweeknum,"weeknums")
                    end

           + P"w" / function()
                      return Cg(dweek,"wday")
                    end

           + P"W" / function()
                      return Cg(dweeknum,"weeknumm")
                    end

           + P"x" / function()
                      error("%x format specifier not supported")
                    end

           + P"X" / function()
                      error("%X format specifier not supported")
                    end

           + P"y" / function()
                      return Cg(d2year,"year")
                    end

           + P"Y" / function()
                      return Cg(d4year,"year")
                    end

           + P"Z" / function()
                      return Cg(char^1,"zone")
                    end

           + P"%" / function()
                      return P"%"
                    end

-- -------------------------------------------------------------------
-- C99 extensions
-- -------------------------------------------------------------------

           + P"F" / function()
                      return Cg(d4year,"year")  * P"-"
                           * Cg(dmonth,"month") * P"-"
                           * Cg(dday,"day")
                    end

-- -------------------------------------------------------------------
-- General UNIX extensions
-- -------------------------------------------------------------------

           + P"C" / function()
                      return Cg(d2year,"year")
                    end

           + P"D" / function()
                      return Cg(dmonth,"month") * P"/"
                           * Cg(dday,"day")     * P"/"
                           * Cg(d2year,"year")
                    end

           + P"e" / function()
                      return P" "^-1
                           * Cg(Cmt(digit^1,chkrange(1,31)),"day")
                    end

           + P"E" / function()
                      error("%E format modifier not supported")
                    end

           + P"h" / function()
                      return Cg(char^1 / short_months,"month")
                    end

           + P"n" / function()
                      return P"\n"
                    end

           + P"O" / function()
                      error("%O format modifier not supported")
                    end

           + P"r" / function()
                      return Cg(d12hour,"hour") * P":"
                           * Cg(dminute,"min")  * P":"
                           * Cg(dsecond,"sec")  * P" "
                           * Cg(char^1 / am_pm,"pm")
                    end
             
           + P"R" / function()
                      return Cg(d24hour,"hour") * P":"
                           * Cg(dminute,"min")
                    end

           + P"t" / function()
                      return P"\t"
                    end

           + P"T" / function()
                      return Cg(d24hour,"hour") * P":"
                           * Cg(dminute,"min")  * P":"
                           * Cg(dsecond,"sec")
                    end

           + P"u" / function()
                      return Cg(dweek1,"wday")
                    end

           + P"V" / function()
                      return Cg(dweeknum,"weeknumm4")
                    end

-- -------------------------------------------------------------------
-- TZ (Time Zone) extensions
-- -------------------------------------------------------------------

           + P"g" / function()
                      return Cg(d2year,"year")
                    end

           + P"G" / function()
                      return Cg(d4year,"year")
                    end

           + P"k" / function()
                      return P" "^-1
                           * Cg(Cmt(digit^1,chkrange(1,23)),"hour")
                      end

           + P"l" / function()
                      return P" "^-1
                           * Cg(Cmt(digit^1,chkrange(1,12)),"hour")
                      end

           + P"s" / function()
                      return Cg(digit^1 / tonumber,"epoch")
                    end

           + P"+" / function()
                      error("%+ format specifier not supported")
                    end

-- -------------------------------------------------------------------
-- GNU extensions
-- -------------------------------------------------------------------

           + P"P" / function()
                      return Cg(char^1 / am_pm,"pm")
                    end
                      
           + P"z" / function()
                      return Cg(number,"zone")
                    end

-- -------------------------------------------------------------------
-- Catch all
-- -------------------------------------------------------------------

           + P(1) / function(c)
                      error(string.format("%%%s format specifier not supported",c))
                    end
                    
local directive = P"%" * directives

return Cf((text + directive)^0,function(a,b) return a * b end)
       / function(c)
           return Ct(c)
         end
