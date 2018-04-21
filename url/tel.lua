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
local lpeg = require "lpeg"

-- ************************************************************************
--      RFC-3966 RFC-4694 RFC-4715 RFC-4759 RFC-4904 RFC-5341
--
--      tel =
--      {
--        scheme      = 'tel',
--        global      = true,
--        number      = '5616034511',
--        parameters  = { ... }
--      }
--
-- ************************************************************************

local Cc  = lpeg.Cc
local Cf  = lpeg.Cf
local Cg  = lpeg.Cg
local Cs  = lpeg.Cs
local Ct  = lpeg.Ct
local C   = lpeg.C
local P   = lpeg.P
local S   = lpeg.S

local tel = {}

tel.alphanum    = abnf.ALPHA + abnf.DIGIT
tel.pct_encoded = (P"%" * abnf.HEXDIG * abnf.HEXDIG)
                / function(capture)
                    local n = tonumber(capture:sub(2,-1),16)
                    return n
                  end
                     
tel.mark             = S"-_.!~*'()"
tel.unreserved       = tel.alphanum + tel.mark
tel.param_unreserved = S"[]/:&+$"
tel.paramchar        = tel.param_unreserved + tel.unreserved + tel.pct_encoded
tel.pvalue           = Cs(tel.paramchar^1)
tel.pname            = (tel.alphanum + P"-")^1
tel.parameter        = P";"
                     * (tel.pname / function(c) return c:lower() end)
                     * ((P"=" * C(tel.pvalue)) + Cc(true))
tel.par              = Cf(
                           Ct"" * Cg(tel.parameter)^0,
                           function(a,i,v) a[i] = v return a end
                         )
                               
tel.visual_separator     = lpeg.S"-.()" / ""
tel.phonedigit           = abnf.DIGIT  + tel.visual_separator
tel.phonedigit_hex       = abnf.HEXDIG + tel.visual_separator + P"*" + P"#"

tel.local_number_digits  = Cg(Cs(tel.phonedigit_hex^1),'number')
tel.local_number         = tel.local_number_digits  * Cg(tel.par,"parameters") - P";"
tel.global_number_digits = Cg(P"+" * Cc(true),'global')
                         * Cg(Cs(tel.phonedigit^1),'number')
tel.global_number        = tel.global_number_digits * Cg(tel.par,"parameters") - P";"

tel.telephone_subscriber = (tel.global_number + tel.local_number)
                         - abnf.ALPHA -- XXX hack here
tel.tel                  = Ct(Cg(lpeg.P"tel",'scheme') * lpeg.P":" * tel.telephone_subscriber)

function tel:match(...) return self.tel:match(...) end

return tel
