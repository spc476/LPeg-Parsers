package = "org.conman.parsers.iso"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/iso-1.0.0/iso.lua",
  md5 = "6806dbbc83dee708c42720081785bacd",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ISO characters",
  detailed   = [[
  	LPEG expression to match valid ISO characters, both graphic and
	control sets, for example, ISO-8859-1.  This module handles *only*
	the characters not defined by ASCII.  If you need to parse both
	ASCII and ISO:

		char = require "org.conman.parsers.iso"
	             + require "org.conman.parsers.ascii"

	NOTE:  The ISO control characters may match more than a single
	character.  For example, the commonly called ANSI codes (which are
	not ANSI but ISO) like "<ESC>[32;40m" will be matched as one unit.
  ]]
}

dependencies =
{
  "lua >= 5,1, <= 5.4",
  "lpeg >= 1.0.0",
  "org.conman.parsers.iso.char >= 1.0.0",
  "org.conman.parsers.iso.control >= 1.0.0",
  "org.conman.parsers.ascii.char >= 1.0.0",
  "org.conman.parsers.ascii.control >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.iso'] = "iso.lua"
    }
  }
}
