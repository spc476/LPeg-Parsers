-- ***************************************************************
--
-- Copyright 2012 by Sean Conner.  All Rights Reserved.
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

local lpeg = require "lpeg"
local re   = require "re"

local P  = lpeg.P
local S  = lpeg.S
local R  = lpeg.R
local V  = lpeg.V
local C  = lpeg.C
local Cc = lpeg.Cc
local Cf = lpeg.Cf
local Ct = lpeg.Ct
local Cp = lpeg.Cp

-- ***********************************************************************
-- create a parsing expression that will match text case-insensitively
-- ***********************************************************************

local function H(text)
  local pattern = P(true)
  for c in text:gmatch(".") do
    pattern = pattern * (P(c:lower()) + P(c:upper()))
  end
  
  return pattern
end

-- ***********************************************************************
-- function to acculate values into a table.  Values with the same key
-- will end up together under a single key, in the order they appear.  The
-- keys themselves are in no particular order.
-- ***********************************************************************

local function doset(tab,idx)

  local function append(t,l)
    if type(l) == 'table' and #l > 0 then
      for i = 1 , #l do
        t[#t + 1] = l[i]
      end
    else
      t[#t + 1] = l
    end
  end
  
  local function addto(t,l)
    for name,value in pairs(l) do
      if t[name] == nil then
        t[name] = value
      elseif type(t[name]) == 'table' then
        append(t[name],value)
      else
        local r = { t[name] }
        append(r,value)
        t[name] = r
      end
    end
  end
  
  if idx._GENERIC then
    tab.generic = tab.generic or {}
    idx._GENERIC = nil
    addto(tab.generic,idx)
  else
    addto(tab,idx)
  end
  
  return tab
end

-- *******************************************************************

local FROM       = H "From"
local VCHAR      = R"!~"
local WSP        = S" \t"
local SP         = P" "
local CRLF       = P"\r"^-1 * P"\n"
local ctext      = R("!'" , "*[" , "]~")
local qtext      = R("!!" , "#[" , "]~")
local dtext      = R("!Z" , "^~")
local theheaders = Cf(Ct"" * V"headers"^1,doset) * CRLF

local eoh        = (CRLF * #CRLF) + (CRLF - (CRLF^-1 * WSP))
local name       = C((P(1) - (P":" + CRLF + WSP))^1)
local value      = C((P(1) - eoh)^0) / function(v)
                                         return v:gsub("[%s%c]+"," ")
                                       end
                                       
local unixfrom   = FROM * WSP * (P(1) - eoh)^0 * CRLF

local generic_header = name * ":" * WSP^0 * value * eoh
        / function(a,b)
            b = b or ""
            return { [a] = b , _GENERIC = true }
          end
          
local group =
  V"CFWS"^-1
  * Cf(
        C(V"display_name")
        * Cf(
              Ct"" * P":" * V"group_list"^-1 + Cc(),
              function(a,b)
                a[#a + 1] = b
                return a
              end
            ),
        function(a,b)
          return { [a] = b }
        end
      )
  * P";"
  * V"CFWS"^-1
  
local mimetype =
  Cf(
      Ct(C(V"type" * P"/" * V"subtype"))
      * ( P";" * V"FWS"
          * C(V"attribute") * P"=" * C(V"value")
          / function(a,b)
              return { a , b:gsub([["]],"") }
            end
        )^0 + Cc(),
      function(a,b)
        a[b[1]] = b[2]
        return a
      end
    )
  * V"CFWS"^-1
  
-- ********************************************************************

local G = --[[ lpeg/re ]] [[

email           <- %theheaders
headers         <-

                   %unixfrom    -- burn a Unix style From line
                   
                -- -------------------------------------------------------
                -- Fields defined in RFC-822, RFC-2822 and RFC-5322
                -- see RFC-5321 for further information about
                -- Return-Path: and Received:
                -- -------------------------------------------------------
                
                /  {:from:                      fromhdr         :} -> {}
                /  {:to:                        tohdr           :} -> {}
                /  {:subject:                   subjecthdr      :} -> {}
                /  {:date:                      datehdr         :} -> {}
                /  {:cc:                        cchdr           :} -> {}
                /  {:bcc:                       bcchdr          :} -> {}
                /  {:comment:                   commenthdr      :} -> {}
                /  {:keywords:                  keywordshdr     :} -> {}
                /  {:message_id:                message_idhdr   :} -> {}
                /  {:in_reply_to:               in_reply_tohdr  :} -> {}
                /  {:references:                referenceshdr   :} -> {}
                /  {:reply_to:                  reply_tohdr     :} -> {}
                /  {:sender:                    senderhdr       :} -> {}
                /  {:received:                  receivedhdr     :} -> {}
                /  {:return_path:               return_pathhdr  :} -> {}
                /  {:encrypted:                 encryptedhdr    :} -> {}
                
                -- --------------------------------------------------------
                -- fields defined in RFC-2045, RFC-2046, RFC-2047, RFC-2048
                -- and RFC-2049 (MIME related headers).
                -- Content-Length: isn't defined, but is in common
                -- enough use to include it here
                -- --------------------------------------------------------
                
                /  {:mime:                      mimehdr         :} -> {}
                /  {:content_type:              content_typehdr :} -> {}
                /  {:content_transfer_encoding: ctehdr          :} -> {}
                /  {:content_id:                content_idhdr   :} -> {}
                /  {:content_description:       content_deschdr :} -> {}
                /  {:content_length:            content_lenhdr  :} -> {}
                
                -- --------------------------------------------------------
                -- fields defined in RFC-2919 (List-ID:) and RFC-2369
                -- these fields relate to mailing lists
                -- --------------------------------------------------------
                
                /  {:list_id:                   list_idhdr      :} -> {}
                /  {:list_help:                 list_helphdr    :} -> {}
                /  {:list_unsubscribe:          list_unsubhdr   :} -> {}
                /  {:list_subscribe:            list_subhdr     :} -> {}
                /  {:list_post:                 list_posthdr    :} -> {}
                /  {:list_owner:                list_ownerhdr   :} -> {}
                /  {:list_archive:              list_archivehdr :} -> {}
                
                -- --------------------------------------------------------
                -- fields defined in RFC-1036 (Usenet).  There is some
                -- overlap with RFC-822, so those fields not defined there
                -- are defined here
                -- --------------------------------------------------------
                
                /  {:newsgroups:                newsgrouphdr    :} -> {}
                /  {:path:                      pathhdr         :} -> {}
                /  {:followup_to:               followup_tohdr  :} -> {}
                /  {:expires:                   expireshdr      :} -> {}
                /  {:control:                   controlhdr      :} -> {}
                /  {:distribution:              distributionhdr :} -> {}
                /  {:organization:              organizationhdr :} -> {}
                /  {:summary:                   summaryhdr      :} -> {}
                /  {:approved:                  approvedhdr     :} -> {}
                /  {:lines:                     lineshdr        :} -> {}
                /  {:xref:                      xrefhdr         :} -> {}
                
                -- --------------------------------------------------------
                -- field defined in RFC-3834
                -- --------------------------------------------------------
                
                /  {:auto_submitted:            autosubmithdr   :} -> {}
                
                -- --------------------------------------------------------
                -- field defined in RFC-5064
                -- --------------------------------------------------------
                
                /  {:archived_at:               archived_athdr  :} -> {}
                
                -- --------------------------------------------------------
                -- fields that are otherwise undefined accumulate here
                -- (also, malformed defined headers will end up here)
                -- --------------------------------------------------------
                
                /   %generic_header
                
-- ------------------------------------------------------------------------

fromhdr         <- %FROM         ':' mailbox_list            -> {} %CRLF
subjecthdr      <- %SUBJECT      ':' unstructured => cleanup       %CRLF
datehdr         <- %DATE         ':' date_time               -> {} %CRLF
tohdr           <- %TO           ':' address_list            -> {} %CRLF
cchdr           <- %CC           ':' address_list            -> {} %CRLF
bcchdr          <- %BCC          ':' address_list            -> {} %CRLF
commenthdr      <- %COMMENT      ':' unstructured => cleanup       %CRLF
keywordshdr     <- %KEYWORDS     ':' (phrase (',' phrase)* ) -> {} %CRLF
message_idhdr   <- %MESSAGE_ID   ':' msg_id                        %CRLF
in_reply_tohdr  <- %IN_REPLY_TO  ':' msg_id+                 -> {} %CRLF
referenceshdr   <- %REFERENCES   ':' msg_id+                 -> {} %CRLF
reply_tohdr     <- %REPLY_TO     ':' address_list            -> {} %CRLF
senderhdr       <- %SENDER       ':' mailbox                 -> {} %CRLF
receivedhdr     <- %RECEIVED     ':' FWS stamp               -> {} %CRLF
return_pathhdr  <- %RETURN_PATH  ':' FWS reverse_path        -> {} %CRLF
encryptedhdr    <- %ENCRYPTED    ':' unstructured => cleanup       %CRLF

mimehdr         <- %MIME_VERSION              ':' mimeversion             %CRLF
content_typehdr <- %CONTENT_TYPE              ':' FWS %mimetype           %CRLF
ctehdr          <- %CONTENT_TRANSFER_ENCODING ':' FWS mechanism           %CRLF
content_idhdr   <- %CONTENT_ID                ':' msg_id                  %CRLF
content_deschdr <- %CONTENT_DESCRIPTION       ':' unstructured => cleanup %CRLF
content_lenhdr  <- %CONTENT_LENGTH            ':' FWS length              %CRLF

list_idhdr      <- %LIST_ID          ':' FWS           list_id    -> {} %CRLF
list_helphdr    <- %LIST_HELP        ':' FWS           list_locs  -> {} %CRLF
list_unsubhdr   <- %LIST_UNSUBSCRIBE ':' FWS           list_locs  -> {} %CRLF
list_subhdr     <- %LIST_SUBSCRIBE   ':' FWS           list_locs  -> {} %CRLF
list_posthdr    <- %LIST_POST        ':' FWS (list_no? list_locs) -> {} %CRLF
list_ownerhdr   <- %LIST_OWNER       ':' FWS           list_locs  -> {} %CRLF
list_archivehdr <- %LIST_ARCHIVE     ':' FWS           list_locs  -> {} %CRLF

newsgrouphdr    <- %NEWSGROUPS       ':' FWS newsgroups           -> {} %CRLF
pathhdr         <- %PATH             ':' FWS newspath?            -> {} %CRLF
followup_tohdr  <- %FOLLOWUP_TO      ':' FWS newsgroups           -> {} %CRLF
expireshdr      <- %EXPIRES          ':' date_time                -> {} %CRLF
controlhdr      <- %CONTROL          ':' FWS control_list         -> {} %CRLF
distributionhdr <- %DISTRIBUTION     ':' FWS dist_list            -> {} %CRLF
organizationhdr <- %ORGANIZATION     ':' unstructured => cleanup        %CRLF
summaryhdr      <- %SUMMARY          ':' unstructured => cleanup        %CRLF
approvedhdr     <- %APPROVED         ':' unstructured => cleanup        %CRLF
lineshdr        <- %LINES            ':' FWS length                     %CRLF
xrefhdr         <- %XREF             ':' FWS xref                 -> {} %CRLF

autosubmithdr   <- %AUTO_SUBMITTED   ':' FWS auto_submit          -> {} %CRLF

archived_athdr  <- %ARCHIVED_AT      ':' FWS archive_url                %CRLF

-- ------------------------------------------------------------------------

auto_submit     <- {:type: ('no' / 'auto-generated' / 'auto-replied' / token) :}
                   ( CFWS? ";" CFWS? parameter )*
                   
archive_url     <- "<" { [^>]+ } ">"

        -- -------------------------------------------
        -- Usenet (newsgroups) specific headers
        -- -------------------------------------------
        
xref            <- {:host: xrefhost :} FWS xreflist
xreflist        <- groupmsg -> {} (FWS groupmsg)* -> {}
xrefhost        <- [A-Za-z0-9]+
groupmsg        <- {:newsgroup: dot_atom_text :} ":" {:id: %d+ :}
dist_list       <- distribution (FWS? "," FWS? distribution)*
distribution    <- { [A-Za-z]+ }
newsgroups      <- { dot_atom_text } ( FWS? "," FWS? { dot_atom_text } )*
newspath        <- newshost (punct+ newshost)*
newshost        <- { [A-Za-z0-9.]+ }
punct           <- [][~`!@#$%^&*()-_=+{}|\;':"<>,/?] / FWS
control_list    <- (
                        ctrl_cancel
                     /  ctrl_ihave
                     /  ctrl_sendme
                     /  ctrl_newgroup
                     /  ctrl_rmgroup
                     /  ctrl_sendsys
                     /  ctrl_version
                   ) -> {}
ctrl_cancel     <- {:cmd: CANCEL   -> "cancel"   :} FWS msg_id
ctrl_ihave      <- {:cmd: IHAVE    -> "ihave"    :} FWS msg_id+
ctrl_sendme     <- {:cmd: SENDME   -> "sendme"   :} FWS msg_id+
ctrl_newgroup   <- {:cmd: NEWGROUP -> "newgroup" :} FWS { dot_atom_text } (FWS moderated)?
ctrl_rmgroup    <- {:cmd: RMGROUP  -> "rmgroup"  :} FWS { dot_atom_text }
ctrl_sendsys    <- {:cmd: SENDSYS  -> "sendsys"  :}
ctrl_version    <- {:cmd: VERSION  -> "version"  :}
moderated       <- {:moderated: MODERATED :}

CANCEL          <- [Cc][Aa][Nn][Cc][Ee][Ll]
IHAVE           <- [Ii][Hh][Aa][Vv][Ee]
SENDME          <- [Ss][Ee][Nn][Dd][Mm][Ee]
NEWGROUP        <- [Nn][Ee][Ww][Gg][Rr][Oo][Uu][Pp]
RMGROUP         <- [Rr][Mm][Gg][Rr][Oo][Uu][Pp]
SENDSYS         <- [Ss][Ee][Nn][Dd][Ss][Yy][Ss]
VERSION         <- [Vv][Ee][Rr][Ss][Ii][Oo][Nn]
MODERATED       <- [Mm][Oo][Dd][Ee][Rr][Aa][Tt][Ee][Dd]

        -- ----------------------------------------------
        -- Mailing list specific headers
        -- ----------------------------------------------
        
list_id         <- {:name: phrase? :} "<" {:id: list_label :} ">"
list_label      <- dot_atom_text
list_locs       <- list_loc ("," list_loc)*
list_loc        <- CFWS? "<" { [^>]+ } ">" CFWS?
list_no         <- CFWS? {:list_no: [Nn][Oo] :}

        -- -----------------------------------------------
        -- MIME specific headers
        -- -----------------------------------------------
        
length          <- %d+ -> tonumber
mechanism       <- BIT7                 -> "7bit"
                /  BIT8                 -> "8bit"
                /  BINARY               -> "binary"
                /  QUOTED_PRINTABLE     -> "quoted_printable"
                /  BASE64               -> "base64"
                /  x_token
BIT7            <- "7" BIT
BIT8            <- "8" BIT
BINARY          <- [Bb][Ii][Nn][Aa][Rr][Yy]
QUOTED_PRINTABLE<- [Qq][Uu][Oo][Tt][Ee][Dd]
                   "-" [Pp][Rr][Ii][Nn][Tt][Aa][Bb][Ll][Ee]
BASE64          <- [Bb][Aa][Ss][Ee] "64"
BIT             <- [Bb][Ii][Tt]

type            <- discrete_type / composite_type
discrete_type   <- "text"
                /  "image"
                /  "audio"
                /  "video"
                /  "application"
                /  extension_token
composite_type  <- "message"
                /  "multipart"
                /  extension_token
extension_token <- x_token
x_token         <- [Xx] "-" ([A-Za-z0-9] / '-')+
subtype         <- extension_token / iana_token
iana_token      <- ([A-Za-z0-9] / '-')+
parameter       <- (attribute '=' value) -> {}
attribute       <- token
value           <- (token / quoted_string)
token           <- [^][()<>@,;:\"/?=%s%c]+

mimeversion     <- (CFWS? {%d+} CFWS? '.' CFWS? {%d+} CFWS?) -> {} -> vmerge

        -- ----------------------------------------------------
        -- tracing (Return-Path and Received) specific headers
        -- ----------------------------------------------------
        
reverse_path    <- path / "<>"

stamp           <- (
                     from_domain? by_domain? opt_info? CFWS?
                     ";" {:when: date_time -> {} :}
                   ) -> {}
from_domain     <- %FROM    FWS {:from: extended_domain :}
by_domain       <- CFWS BY FWS {:by:   extended_domain :}
extended_domain <- domain
                /  domain FWS "(" tcp_info ")"
                /  address_literal FWS "(" tcp_info ")"
tcp_info        <- address_literal
                /  domain FWS address_literal
opt_info        <- via? with? id? for? arc?
via             <- CFWS VIA FWS {:link: link :}
with            <- CFWS WITH FWS {:with: protocol :}
id              <- CFWS ID FWS {:id: (atom !'.' / msg_id / dot_atom_text) :}
for             <- CFWS FOR FWS {:for: (path / mailbox / user) :}
arc             <- CFWS atom FWS word
link            <- TCP / addtl_link
addtl_link      <- atom
protocol        <- ESMTP !atext
                /  SMTP  !atext
                /  attdl_protocol
attdl_protocol  <- atom
path            <- "<" (adl ":")? mailbox ">"
adl             <- at_domain ("," at_domain)*
at_domain       <- "@" domain
user            <- [A-Za-z0-9]+
BY              <- [Bb][Yy]
VIA             <- [Vv][Ii][Aa]
WITH            <- [Ww][Ii][Tt][Hh]
FOR             <- [Ff][Oo][Rr]
TCP             <- [Tt][Cc][Pp]
ESMTP           <- [Ee] SMTP
SMTP            <- [Ss][Mm][Tt][Pp]
ID              <- [Ii][Dd]

        -- -----------------------------
        -- message IDs
        -- -----------------------------
        
msg_id          <- CFWS? "<" { id_left "@" id_right } ">" CFWS?
id_left         <- dot_atom_text
id_right        <- dot_atom_text / no_fold_literal
no_fold_literal <- "[" %dtext* "]"

        -- ------------------------------------------
        -- time keeps on slipping, into the future
        -- ------------------------------------------
        
date_time       <- ( {:weekday: day_of_week :} "," )? thedate time CFWS?
day_of_week     <- FWS { day_name }
day_name        <- 'Mon' / 'Tue' / 'Wed' / 'Thu' / 'Fri' / 'Sat' / 'Sun'
thedate         <- day month year
day             <- FWS {:day: %d^+1 -> tonumber :} FWS
month           <- {:month:
                   (
                        'Jan' / 'Feb' / 'Mar' / 'Apr'
                      / 'May' / 'Jun' / 'Jul' / 'Aug'
                      / 'Sep' / 'Oct' / 'Nov' / 'Dec'
                   ) -> monthtrans :}
year            <- FWS {:year: %d^4 -> tonumber :} FWS
time            <- time_of_day zone
time_of_day     <- hour ":" min (":" second)?
hour            <- {:hour: %d%d -> tonumber :}
min             <- {:min:  %d%d -> tonumber :}
second          <- {:sec:  %d%d -> tonumber :}
zone            <- FWS {:zone: (("+" / "-") %d^4) -> tozone:}

        -- ----------------------------------------------------
        -- various tokens and pieces used to build up a larger
        -- parsing expression
        -- ----------------------------------------------------
        
unstructured    <- FWS? { (FWS? %VCHAR)* } %WSP*
phrase          <- word+
word            <- atom / quoted_string

quoted_string   <- CFWS? '"' ((FWS? qcontent)* => cleanup) FWS? '"' CFWS?
qcontent        <- %qtext / quoted_pair
quoted_pair     <- "\" (%VCHAR / %WSP)

atom            <- CFWS? {atext+} CFWS?

atext           <- [A-Za-z]
                /  [0-9]
                /  "!"
                /  "#"
                /  "$"
                /  "%"
                /  "&"
                /  "'"
                /  "*"
                /  "+"
                /  "-"
                /  "/"
                /  "="
                /  "?"
                /  "^"
                /  "_"
                /  "`"
                /  "{"
                /  "|"
                /  "}"
                /  "~"
                
dot_atom_text   <- atext+ ('.' atext+)*
dot_atom        <- CFWS? { dot_atom_text } CFWS?
FWS             <- (%WSP* %CRLF)? %WSP+
CFWS            <- (FWS? comment)? FWS?
                /  FWS
comment         <- "(" (FWS? ccontent)* FWS? ")"
ccontent        <- %ctext / quoted_pair / comment

        -- --------------------------------------------------
        -- Email addresses---for those of you who don't want
        -- a 4,000+ line regular expression
        -- --------------------------------------------------
        
address_list    <- address ("," address)*
address         <- mailbox / %group
group_list      <- mailbox_list / CFWS
mailbox_list    <- mailbox ("," mailbox)*
mailbox         <- (name_addr / addr_spec) -> {}
name_addr       <- {:name: display_name? :} angle_addr
display_name    <- phrase+ -> {} -> merge
angle_addr      <- CFWS? "<" addr_spec ">" CFWS?
addr_spec       <- {:address: (local_part "@" domain) -> merge_addr :}
local_part      <- dot_atom / quoted_string
domain          <- dot_atom / domain_literal
domain_literal  <- CFWS? { "[" (FWS? %dtext)* FWS? "]" } CFWS?
address_literal <- "[" %dtext* "]"

]]

-- ***********************************************************************

local Rules =
{
  -- -----------------------------------------------------------------------
  -- These are being defined here instead of in the re portion because of a
  -- rule limitiation in LPeg 0.12 (default of 200, requires a recompile to
  -- extend).  Moving the header names out to here will let this work under
  -- LPeg 0.12, while still working back to LPeg 0.10.2.
  -- -----------------------------------------------------------------------
  
  RETURN_PATH = H "Return-Path",
  RECEIVED    = H "Received",
  -- Resent headers still need to be done
  DATE        = H "Date",
  FROM        = FROM,
  SENDER      = H "Sender",
  REPLY_TO    = H "Reply-To",
  TO          = H "To",
  CC          = H "Cc",
  BCC         = H "Bcc",
  MESSAGE_ID  = H "Message-ID",
  IN_REPLY_TO = H "In-Reply-To",
  REFERENCES  = H "References",
  SUBJECT     = H "Subject",
  COMMENT     = H "Comment",
  KEYWORDS    = H "Keywords",
  ENCRYPTED   = H "Encrypted",
  
  MIME_VERSION              = H "MIME-Version",
  CONTENT_TYPE              = H "Content-Type",
  CONTENT_TRANSFER_ENCODING = H "Content-Transfer-Encoding",
  CONTENT_ID                = H "Contend-ID",
  CONTENT_DESCRIPTION       = H "Content-Description",
  CONTENT_LENGTH            = H "Content-Length",
  
  LIST_ID          = H "List-ID",
  LIST_HELP        = H "List-Help",
  LIST_UNSUBSCRIBE = H "List-Unsubscribe",
  LIST_SUBSCRIBE   = H "List-Subscribe",
  LIST_POST        = H "List-Post",
  LIST_OWNER       = H "List-Owner",
  LIST_ARCHIVE     = H "List-Archive",
  
  NEWSGROUPS   = H "Newsgroups",
  PATH         = H "Path",
  FOLLOWUP_TO  = H "Followup-To",
  EXPIRES      = H "Expires",
  CONTROL      = H "Control",
  DISTRIBUTION = H "Distribution",
  ORGANIZATION = H "Organization",
  SUMMARY      = H "Summary",
  APPROVED     = H "Approved",
  LINES        = H "Lines",
  XREF         = H "XRef",
  
  AUTO_SUBMITTED = H"Auto-Submitted",
  
  ARCHIVED_AT  = H "Archived-At",
  
  -- -------[ end of header names ]---------------
  
  VCHAR      = VCHAR,
  WSP        = WSP,
  SP         = SP,
  CRLF       = CRLF,
  ctext      = ctext,
  qtext      = qtext,
  dtext      = dtext,
  theheaders = theheaders,
  group      = group,
  mimetype   = mimetype,
  generic_header = generic_header,
  unixfrom   = unixfrom,
  
  tonumber = tonumber,
  
  merge_addr = function(l,d)
    return l .. "@" .. d
  end,
  
  monthtrans = function(cap)
    local trans =
    {
      Jan = 1 , Feb =  2 , Mar =  3 , Apr =  4 ,
      May = 5 , Jun =  6 , Jul =  7 , Aug =  8 ,
      Sep = 9 , Oct = 10 , Nov = 11 , Dec = 12
    }
    
    return trans[cap]
  end,
  
  merge = function(cap)
    return table.concat(cap," ")
  end,
  
  vmerge = function(cap)
    return table.concat(cap,".")
  end,
  
  last = function(list)
    return list[#list]
  end,
  
  tozone = function(cap)
    local hour = tonumber(cap:sub(2,3)) * 3600
    local min  = tonumber(cap:sub(4,5)) *   60
    local sec  = hour + min
    
    if cap:sub(1,1) == '-' then
      return -sec
    else
      return sec
    end
  end,
  
  cleanup = function(_,position,capture)
    local new = capture:gsub("\n","")
    new = new:gsub([[\.]],function(x) return x:sub(2,2) end)
    new = new:gsub("\t"," ")
    return position,new
  end,
  
  ddt = function(_,p,c)
    local dump = require "org.conman.table".dump
    print(">>>",p,c)
    if type(c) == 'table' then
      dump("c",c)
    end
    return p
  end,
};

-- **********************************************************************

return re.compile(G,Rules) * Cp()

