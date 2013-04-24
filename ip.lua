
local idiv = require "org.conman.math".idiv
local lpeg = require "lpeg"

local Cf = lpeg.Cf
local Cc = lpeg.Cc
local C  = lpeg.C
local R  = lpeg.R
local P  = lpeg.P

function acc(a,v) return a .. v end

DIGIT  = R"09"
HEXDIG = R("AF","af","09")

dec_octet = C(DIGIT^1)
          / function(c)
              local n = tonumber(c)
              if n < 256 then
                return string.char(n)
              end
            end
              
IPv4 = Cf(
           Cc"" 
           * dec_octet * "." 
           * dec_octet * "." 
           * dec_octet * "." 
           * dec_octet,
           acc)

cc   = P"::" / "\0\0"
set  = -P(R("AF","af","09","::"))
h16  = Cf(Cc(0) * C(HEXDIG * HEXDIG^-3),function(a,b)
                                          return a * 16 + tonumber(b,16)
                                        end)
     / function(c)
         local q,r = idiv(c,256)
         return string.char(q) .. string.char(r)
       end
       
h16c = h16 * P":" * #HEXDIG
ls32 = IPv4 + h16c * h16

function mcc(n)
  return P"::" / string.rep("\0",n * 2)
end

function mh16(n)
  local acc = P(true)
  for i = 1 , n-1 do
    acc = acc * h16c
  end
  acc = acc * h16
  return acc
end

function mh16c(n)
  local acc = P(true)
  for i = 1 , n do
    acc = acc * h16c
  end
  return acc
end

IPv6 = Cf(Cc"" *                    mh16c(6) * ls32 * set,acc)	-- a
     + Cf(Cc"" *           mcc(1) * mh16c(5) * ls32 * set,acc)	-- b
     + Cf(Cc"" *           mcc(2) * mh16c(4) * ls32 * set,acc)	-- c
     + Cf(Cc"" * h16 *     mcc(1) * mh16c(4) * ls32 * set,acc)
     + Cf(Cc"" *           mcc(3) * mh16c(3) * ls32 * set,acc)	-- d
     + Cf(Cc"" * h16 *     mcc(2) * mh16c(3) * ls32 * set,acc)
     + Cf(Cc"" * mh16(2) * mcc(1) * mh16c(3) * ls32 * set,acc)
     + Cf(Cc"" *           mcc(4) * mh16c(2) * ls32 * set,acc)	-- e
     + Cf(Cc"" * h16     * mcc(3) * mh16c(2) * ls32 * set,acc)
     + Cf(Cc"" * mh16(2) * mcc(2) * mh16c(2) * ls32 * set,acc)
     + Cf(Cc"" * mh16(3) * mcc(1) * mh16c(2) * ls32 * set,acc)
     + Cf(Cc"" *           mcc(5) * h16c     * ls32 * set,acc)	-- f
     + Cf(Cc"" * h16     * mcc(4) * h16c     * ls32 * set,acc)
     + Cf(Cc"" * mh16(2) * mcc(3) * h16c     * ls32 * set,acc)
     + Cf(Cc"" * mh16(3) * mcc(2) * h16c     * ls32 * set,acc)
     + Cf(Cc"" * mh16(4) * mcc(1) * h16c     * ls32 * set,acc)
     + Cf(Cc"" *           mcc(6)            * ls32 * set,acc)	-- g
     + Cf(Cc"" * h16 *     mcc(5)            * ls32 * set,acc)
     + Cf(Cc"" * mh16(2) * mcc(4)            * ls32 * set,acc)
     + Cf(Cc"" * mh16(3) * mcc(3)            * ls32 * set,acc)
     + Cf(Cc"" * mh16(4) * mcc(2)            * ls32 * set,acc)
     + Cf(Cc"" * mh16(5) * mcc(1)            * ls32 * set,acc)
     + Cf(Cc"" *           mcc(7)            * h16  * set,acc)	-- h
     + Cf(Cc"" * h16     * mcc(6)            * h16  * set,acc)
     + Cf(Cc"" * mh16(2) * mcc(5)            * h16  * set,acc)
     + Cf(Cc"" * mh16(3) * mcc(4)            * h16  * set,acc)
     + Cf(Cc"" * mh16(4) * mcc(3)            * h16  * set,acc)
     + Cf(Cc"" * mh16(5) * mcc(2)            * h16  * set,acc)
     + Cf(Cc"" * mh16(6) * mcc(1)            * h16  * set,acc)
     + Cf(Cc"" *           mcc(8)                   * set,acc)		-- i
     + Cf(Cc"" * mh16(1) * mcc(7)                   * set,acc)
     + Cf(Cc"" * mh16(2) * mcc(6)                   * set,acc)
     + Cf(Cc"" * mh16(3) * mcc(5)                   * set,acc)
     + Cf(Cc"" * mh16(4) * mcc(4)                   * set,acc)
     + Cf(Cc"" * mh16(5) * mcc(3)                   * set,acc)
     + Cf(Cc"" * mh16(6) * mcc(2)                   * set,acc)
     + Cf(Cc"" * mh16(7) * mcc(1)                   * set,acc)
     
-- -------------------------------------------------------------





ddt = require "org.conman.debug"

function test(f,addr)
  local x = f:match(addr)
  if x then
    ddt.hexdump(x)
  else
    print("FAIL","(nil)",addr)
  end
end


test(IPv4,"10.10.10.10")
test(IPv4,"0.0.0.0")
test(IPv4,"255.255.255.255")
test(IPv4,"10.256,10.10")

test(IPv6,"1111:2222:3333:4444:5555:6666:10.10.10.10")
test(IPv6,"1111:2222:3333:4444:5555:6666:7777:8888")
test(IPv6,"fc00::1")
test(IPv6,"fc00::dead:beef")
test(IPv6,"1:2:3:4:5:6:7:8")	-- a
test(IPv6,"::2:3:4:5:6:7:8")	-- b
test(IPv6, "::3:4:5:6:7:8")	-- c
test(IPv6,"1::3:4:5:6:7:8")	-- c
test(IPv6,   "::4:5:6:7:8")	-- d
test(IPv6,  "1::4:5:6:7:8")	-- d
test(IPv6,"1:2::4:5:6:7:8")	-- d
test(IPv6,     "::5:6:7:8")	-- e
test(IPv6,    "1::5:6:7:8")	-- e
test(IPv6,  "1:2::5:6:7:8")	-- e
test(IPv6,"1:2:3::5:6:7:8")	-- e
test(IPv6,       "::6:7:8")	-- f
test(IPv6,      "1::6:7:8")	-- f
test(IPv6,    "1:2::6:7:8")	-- f
test(IPv6,  "1:2:3::6:7:8")	-- f
test(IPv6,"1:2:3:4::6:7:8")	-- f
test(IPv6,         "::7:8")	-- g
test(IPv6, "::10.10.10.10")	-- g
test(IPv6,        "1::7:8")	-- g
test(IPv6,      "1:2::7:8")	-- g
test(IPv6,    "1:2:3::7:8")	-- g
test(IPv6,  "1:2:3:4::7:8")	-- g
test(IPv6,"1:2:3:4:5::7:8")	-- g
test(IPv6,           "::8")	-- h
test(IPv6,          "1::8")	-- h
test(IPv6,        "1:2::8")	-- h
test(IPv6,      "1:2:3::8")	-- h
test(IPv6,    "1:2:3:4::8")	-- h
test(IPv6,  "1:2:3:4:5::8")	-- h
test(IPv6,"1:2:3:4:5:6::8")	-- h
test(IPv6,             "::")	-- i
test(IPv6,            "1::")	-- i
test(IPv6,          "1:2::")	-- i
test(IPv6,        "1:2:3::")	-- i
test(IPv6,      "1:2:3:4::")	-- i
test(IPv6,    "1:2:3:4:5::")	-- i
test(IPv6,  "1:2:3:4:5:6::")	-- i
test(IPv6,"1:2:3:4:5:6:7::")	-- i
