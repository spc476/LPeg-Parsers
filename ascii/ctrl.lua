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
  ['\000'] = 'NUL' , -- NULL
  ['\001'] = 'SOH' , -- START OF HEADING
  ['\002'] = 'STX' , -- START OF TEXT
  ['\003'] = 'ETX' , -- END OF TEXT
  ['\004'] = 'EOT' , -- END OF TRANSMISSION
  ['\005'] = 'ENQ' , -- ENQUIRY
  ['\006'] = 'ACK' , -- ACKNOWLEDGE
  ['\007'] = 'BEL' , -- BELL
  ['\008'] = 'BS'  , -- BACKSPACE
  ['\009'] = 'HT'  , -- CHARACTER TABULATION
  ['\010'] = 'LF'  , -- LINE FEED
  ['\011'] = 'VT'  , -- LINE TABULATION
  ['\012'] = 'FF'  , -- FORM FEED
  ['\013'] = 'CR'  , -- CARRIAGE RETURN
  ['\014'] = 'SI'  , -- SHIFT-OUT
  ['\015'] = 'SO'  , -- SHIFT-IN
  ['\016'] = 'DLE' , -- DATA LINK ESCAPE
  ['\017'] = 'DC1' , -- DEVICE CONTROL ONE (XON)
  ['\018'] = 'DC2' , -- DEVICE CONTROL TWO
  ['\019'] = 'DC3' , -- DEVICE CONTROL THREE (XOFF)
  ['\020'] = 'DC4' , -- DEVICE CONTROL FOUR
  ['\021'] = 'NAK' , -- NEGATIVE ACKNOWLEDGE
  ['\022'] = 'SYN' , -- SYNCHRONOUS IDLE
  ['\023'] = 'ETB' , -- END OF TRANSMISSION BLOCK
  ['\024'] = 'CAN' , -- CANCEL
  ['\025'] = 'EM'  , -- END OF MEDIUM
  ['\026'] = 'SUB' , -- SUBSTITUTE
  ['\027'] = 'ESC' , -- ESCAPE
  ['\028'] = 'FS'  , -- FILE SEPARATOR
  ['\029'] = 'GS'  , -- GROUP SEPATATOR
  ['\030'] = 'RS'  , -- RECORD SEPARATOR
  ['\031'] = 'US'  , -- UNIT SEPARATOR
  ['\127'] = 'DEL' , -- DELETE
}

return lpeg.R("\0\31","\127\127") / convert
