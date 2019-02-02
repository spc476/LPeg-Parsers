-- ***************************************************************
--
-- Copyright 2019 by Sean Conner.  All Rights Reserved.
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
-- ====================================================================
--
-- Return name of ASCII control character.  For DLE, return following
-- literal character (if exists).
--
-- ********************************************************************
-- luacheck: ignore 611

local lpeg = require "lpeg"

local convert =
{
  ['\00'] = 'NUL' , -- NULL
  ['\01'] = 'SOH' , -- START OF HEADING
  ['\02'] = 'STX' , -- START OF TEXT
  ['\03'] = 'ETX' , -- END OF TEXT
  ['\04'] = 'EOT' , -- END OF TRANSMISSION
  ['\05'] = 'ENQ' , -- ENQUIRY
  ['\06'] = 'ACK' , -- ACKNOWLEDGE
  ['\07'] = 'BEL' , -- BELL
  ['\08'] = 'BS'  , -- BACKSPACE
  ['\09'] = 'HT'  , -- CHARACTER TABULATION
  ['\10'] = 'LF'  , -- LINE FEED
  ['\11'] = 'VT'  , -- LINE TABULATION
  ['\12'] = 'FF'  , -- FORM FEED
  ['\13'] = 'CR'  , -- CARRIAGE RETURN
  ['\14'] = 'SI'  , -- SHIFT-OUT
  ['\15'] = 'SO'  , -- SHIFT-IN
                    -- DATA LINK ESCAPE (handled below)
  ['\17'] = 'DC1' , -- DEVICE CONTROL ONE (XON)
  ['\18'] = 'DC2' , -- DEVICE CONTROL TWO
  ['\19'] = 'DC3' , -- DEVICE CONTROL THREE (XOFF)
  ['\20'] = 'DC4' , -- DEVICE CONTROL FOUR
  ['\21'] = 'NAK' , -- NEGATIVE ACKNOWLEDGE
  ['\22'] = 'SYN' , -- SYNCHRONOUS IDLE
  ['\23'] = 'ETB' , -- END OF TRANSMISSION BLOCK
  ['\24'] = 'CAN' , -- CANCEL
  ['\25'] = 'EM'  , -- END OF MEDIUM
  ['\26'] = 'SUB' , -- SUBSTITUTE
  ['\27'] = 'ESC' , -- ESCAPE
  ['\28'] = 'FS'  , -- FILE SEPARATOR
  ['\29'] = 'GS'  , -- GROUP SEPATATOR
  ['\30'] = 'RS'  , -- RECORD SEPARATOR
  ['\31'] = 'US'  , -- UNIT SEPARATOR
}

return lpeg.P"\16"   * lpeg.Cc'DLE' * lpeg.C(1)^-1
     + lpeg.R"\0\31" / convert
     + lpeg.P"\127"  * lpeg.Cc'DEL'
