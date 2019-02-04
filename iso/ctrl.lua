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
-- Return name of ISO control character and associated data.
--
-- ********************************************************************
-- luacheck: ignore 611

local lpeg  = require "lpeg"
local iso   = require "org.conman.parsers.iso.char"
local ascii = require "org.conman.parsers.ascii.char"

local Cb = lpeg.Cb
local Cc = lpeg.Cc
local Cf = lpeg.Cf
local Cg = lpeg.Cg
local Cs = lpeg.Cs
local Ct = lpeg.Ct
local C  = lpeg.C
local P  = lpeg.P
local R  = lpeg.R

local codes =
{
  -- ---------------------------------
  -- C1 set
  -- ---------------------------------

  ['\27@']  = '\128' , ['\128'] = '\128' ,
  ['\27A']  = '\129' , ['\129'] = '\129' ,
  ['\27B']  = 'BPH'  , ['\130'] = 'BPH'  , -- BREAK PERMITTED HERE
  ['\27C']  = 'NBH'  , ['\131'] = 'NBH'  , -- NO BREAK HERE
  ['\27D']  = '\132' , ['\132'] = '\132' ,
  ['\27E']  = 'NEL'  , ['\133'] = 'NEL'  , -- NEXT LINE
  ['\27F']  = 'SSA'  , ['\134'] = 'SSA'  , -- START OF SELECTED AREA
  ['\27G']  = 'ESA'  , ['\135'] = 'ESA'  , -- END OF SELECTED AREA
  ['\27H']  = 'HTS'  , ['\136'] = 'HTS'  , -- CHARACTER TABULATION SET
  ['\27I']  = 'HTJ'  , ['\137'] = 'HTJ'  , -- CHARACTER TABULATION WITH JUSTIFICATION
  ['\27J']  = 'VTS'  , ['\138'] = 'VTS'  , -- LINE TABULATION SET
  ['\27K']  = 'PLD'  , ['\139'] = 'PLD'  , -- PARTIAL LINE FORWARD
  ['\27L']  = 'PLU'  , ['\140'] = 'PLU'  , -- PARTIAL LINE BACKWARD
  ['\27M']  = 'RI'   , ['\141'] = 'RI'   , -- REVERSE LINE FEED
  ['\27N']  = 'SS2'  , ['\142'] = 'SS2'  , -- SINGLE-SHIFT TWO
  ['\27O']  = 'SS3'  , ['\143'] = 'SS3'  , -- SINGLE-SHIFT THREE
  -- DCS - handled below                      DEVICE CONTROL STRING
  ['\27Q']  = 'PU1'  , ['\145'] = 'PU1'  , -- PRIVATE USE ONE
  ['\27R']  = 'PU2'  , ['\146'] = 'PU2'  , -- PRIVATE USE TWO
  ['\27S']  = 'STS'  , ['\147'] = 'STS'  , -- SET TRANSMIT STATE
  ['\27T']  = 'CCH'  , ['\148'] = 'CCH'  , -- CANCEL CHARACTER
  ['\27U']  = 'MW'   , ['\149'] = 'MW'   , -- MESSAGE WAITING
  ['\27V']  = 'SPA'  , ['\150'] = 'SPA'  , -- START OF GUARDED AREA
  ['\27W']  = 'EPA'  , ['\151'] = 'EPA'  , -- END OF GUARDED AREA
  -- SOS - handled below                      START OF STRING
  ['\27Y']  = '\153' , ['\153'] = '\153' ,
  ['\27Z']  = 'SCI'  , ['\154'] = 'SCI'  , -- SINGLE CHARACTER INTRODUCER
  -- CSI - handled below                      CONTROL SEQUENCE INTRODUCER
  -- ST  - handled below                      STRING TERMINATOR
  -- OSC - handled below                      OPERATING SYSTEM COMMAND
  -- PM  - handled below                      PRIVACY MESSAGE
  -- APC - handled below                      APPLICATION PROGRAM COMMAND
  
  -- ---------------------------------
  -- Independent control functions
  -- ---------------------------------

  ['\27`'] = 'DMI'  , -- DISABLE MANUAL INPUT
  ['\27a'] = 'INT'  , -- INTERRUPT
  ['\27b'] = 'EMI'  , -- ENABLE MANUAL INPUT
  ['\27c'] = 'RTS'  , -- RESET TO INITIAL STATE
  ['\27d'] = 'CMD'  , -- CODING METHOD DELIMITER
  ['\27e'] = '\27e' ,
  ['\27f'] = '\27f' ,
  ['\27g'] = '\27g' ,
  ['\27h'] = '\27h' ,
  ['\27i'] = '\27i' ,
  ['\27j'] = '\27j' ,
  ['\27k'] = '\27k' ,
  ['\27l'] = '\27l' ,
  ['\27m'] = '\27m' ,
  ['\27n'] = 'LS2'  , -- LOCKING-SHIFT 2
  ['\27o'] = 'LS3'  , -- LOCKING-SHIFT 3
  ['\27p'] = '\27p' ,
  ['\27q'] = '\27q' ,
  ['\27r'] = '\27r' ,
  ['\27s'] = '\27s' ,
  ['\27t'] = '\27t' ,
  ['\27u'] = '\27u' ,
  ['\27v'] = '\27v' ,
  ['\27w'] = '\27w' ,
  ['\27x'] = '\27x' ,
  ['\27y'] = '\27y' ,
  ['\27z'] = '\27z' ,
  ['\27{'] = '\27{' ,
  ['\27|'] = 'LS3R' , -- LOCKING-SHIFT THREE RIGHT
  ['\27}'] = 'LS2R' , -- LOCKING-SHIFT TWO RIGHT
  ['\27~'] = 'LSR1' , -- LOCKING-SHIFT ONE RIGHT
}

local cstr = R"\8\13" + ascii + iso

local ST  = P"\27\\" + P"\156"
local DCS = (P'\27P' + P'\144') * Cc'DCS' * C(cstr^0) * ST
local SOS = (P'\27X' + P'\152') * Cc'SOS' * C(cstr^0) * ST
local OSC = (P'\27]' + P'\157') * Cc'OSC' * C(cstr^0) * (ST + P"\7") -- xterm
local PM  = (P'\27^' + P'\158') * Cc'PM'  * C(cstr^0) * ST
local APC = (P'\27_' + P'\159') * Cc'APC' * C(cstr^0) * ST

local CSI_codes = [[
  @	ICH	INSERT CHARACTER
  A	CCU	CURSOR UP
  B	CUD	CURSOR DOWN
  C	CUF	CURSOR RIGHT
  D	CUB	CURSOR LEFT
  E	CNL	CURSOR NEXT LINE
  F	CPL	CURSOR PRECEDING LINE
  G	CHA	CURSOR CHARACTER ABSOLUTE
  H	CUP	CURSOR POSITION
  I	CHT	CURSOR FORWARD TABULATION
  J	ED	ERASE IN PAGE
  K	EL	ERASE IN LINE
  L	IL	INSERT LINE
  M	DL	DELETE LINE
  N	EF	ERASE IN FIELD
  O	EA	ERASE IN AREA
  P	DCH	DELETE CHARACTER
  Q	SEE	SELECT EDITING EXTENT
  R	CPR	ACTIVE POSITION REPORT
  S	SU	SCROLL UP
  T	SD	SCROLL DOWN
  U	NP	NEXT PAGE
  V	PP	PRECEDING PAGE
  W	CTC	CURSOR TABULATION CONTROL
  X	ECH	ERASE CHARACTER
  Y	CVT	CURSOR LINE TABULATION
  Z	CBT	CURSOR BACKWARD TABULATION
  [	SRS	START REVERSED STRING
  \	PTX	PARALLEL TEXTS
  ]	SOS	START DIRECTED STRING
  ^	SIMD	SELECT IMPLICIT MOVEMENT DIRECTION
  _	_
  `	HPA	CHARACTER POSITION ABSOLUTE
  a	HPR	CHARACTER POSITION FORWARD
  b	REP	REPEAT
  c	DA	DEVICE ATTRIBUTES
  d	VPA	LINE POSITION ABOLUTE
  e	VPR	LINE POSITION FORWARD
  f	HVP	CHARACTER AND LINE POSITION
  g	TBC	TABULATION CLEAR
  h	SM	SET MODE
  i	MC	MEDIA COPY
  j	HPB	CHARACTER POSITION BACKWARD
  k	VPB	LINE POSITION BACKWARD
  l	RM	RESET MODE
  m	SGR	SELECT GRAPHIC RENDITION
  n	DSR	DEVICE STATUS REPORT
  o	DAQ	DEFINE AREA QUALIFICATION
  p	p	private use
  q	q	|
  r	r	V
  s	s
  t	t
  u	u
  v	v
  w	w
  x	x
  y	y
  z	z
  {	{
  |	|	^
  }	}	|
  ~	~	private use
]]

local CSI_space_codes = [[
  @	SL	SCROLL LEFT
  A	SR	SCROLL RIGHT
  B	GSM	GRAPHIC SIZE MODIFICATION
  C	GSS	GRAPHIC SIZE SELECTION
  D	FNT	FONT SELECTION
  E	TSS	THIN SPACE SPECIFICATION
  F	JFY	JUSTIFY
  G	SPI	SPACING INCREMENT
  H	QUAD	QUAD
  I	SSU	SELECT SIZE UNIT
  J	PFS	PAGE FORMAT SELECTION
  K	SHS	SELECT CHARACTER SPACING
  L	SVS	SELECT LINE SPACING
  M	IGS	IDENTIFY GRAPHIC SUBREPERTOIRE
  N	N
  O	IDCS	IDENTIFY DEVICE CONTROL STRING
  P	PPA	PAGE POSITION ABSOLUTE
  Q	PPR	PAGE POSITION FORWARD
  R	PPB	PAGE POSITION BACKWARD
  S	SPD	SELECT PRESENTATION DIRECTIONS
  T	DTA	DIMENSION TEXT AREA
  U	SLH	SET LINE HOME
  V	SLL	SET LINE LIMIT
  W	FNK	FUNCTION KEY
  X	SPQR	SET PRINT QUALITY AND RAPIDITY
  Y	SEF	SHEET EJECT AND FEED
  Z	PEC	PRESENTATION EXPAND OR CONTRACT
  [	SSW	SET SPACE WIDTH
  \	SACS	SET ADDITIONAL CHARACTER SEPARATION
  ]	SAPV	SELECT ALTERNATIVE PRESENTATION VARIANTS
  ^	STAB	SELECTIVE TABULATION
  _	GCC	GRAPHIC CHARACTER COMBINATION
  `	TATE	TABULATION ALIGNED LEADING SPACE
  a	TALE	TABULATION ALIGNED LEADING EDGE
  b	TAC	TABULATION ALIGNED CENTERED
  c	TCC	TABULATION CENTERED ON CHARACTER
  d	TSR	TABULATION STOP REMOVE
  e	SCO	SELECT CHARACTER ORIENTATION
  f	SCRS	SET REDUCED CHARACTER SEPARATION
  g	SCS	SET CHARACTER SPACING
  h	SLS	SET LINE SPACING
  i	i
  j	j
  k	SCP	SELECT CHARACTER PATH
  l	l
  m	m
  n	n
  o	o
  p	p	private use
  q	q	|
  r	r	V
  s	s
  t	t
  u	u
  v	v
  w	w
  x	x
  y	y
  z	z
  {	{
  |	}	^
  }	}	|
  ~	~	private use
]]


local CSI do

  local csi     = P"\27[" + P"\155"
  local param   = Cs((R"09" + P":" / ".")^1) / tonumber
  local params  = Ct(param * (P';' * param)^0)
                + C(R"<?" * R"0?"^0)
                + Ct""
                
  local letter  = R"@~"
                / function(c)
                    return P(c)
                  end
                  
  local name    = R"@~"^1
                / function(n)
                    return Cc(n)
                  end
                  
  local entry   = P"  "
                * Cg(letter,'letter')
                * P"\t"
                * Cg(name,'name')
                * P"\t"^-1 * R" ~"^0 * P"\n"
                * (Cb'name' * Cb'letter')
                / function(n,l)
                    return n * params * l
                  end
                  
  local sletter = R"@~"
                / function(c)
                    return P(" " .. c)
                  end
                  
  local sname   = R"@~"^1
                / function(n)
                    if #n == 1 then
                      return Cc(" " .. n)
                    else
                      return Cc(n)
                    end
                  end
                                    
  local sentry  = P"  "
                * Cg(sletter,'letter')
                * P"\t"
                * Cg(sname,'name')
                * P"\t"^-1 * R" ~"^0 * P"\n"
                * (Cb'name' * Cb'letter')
                / function(n,l)
                    return n * params * l
                  end
                  
  local parse_csi  = Cf(entry^1, function(a,b) return a + b end)
  local parse_scsi = Cf(sentry^1,function(a,b) return a + b end)
  local other      = Cg(R"0?"^0,'param')
                   * Cg(R"!/"^0,'inter')
                   * C(1) * Cb'param' * Cb'inter'
                   
  CSI = csi
      * (
            parse_csi:match(CSI_codes)
          + parse_scsi:match(CSI_space_codes)
          + other
        )
end

return CSI + DCS + SOS + OSC+ PM + APC
     + R"\128\159" / codes
     + (P"\27" * R("@_","`~")) / codes
