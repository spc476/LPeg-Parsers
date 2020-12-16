package = "org.conman.parsers.utf8"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/utf8-1.0.0/utf8.lua",
  md5 = "2fcf92d0bf98b2d3c2337fafdc191126",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ISO characters",
  detailed   = [[
  	LPEG expression to match valid UTF-8 characters, both graphic and
	control sets.  This module handles *only* the characters not defined
	by ASCII.  If you need to parse both ASCII and UTF-8:

		char = require "org.conman.parsers.utf8"
	             + require "org.conman.parsers.ascii"

	NOTE:  The UTF-8 control characters may match more than a single
	character.  For example, the commonly called ANSI codes (which are
	not ANSI but ISO) like "<ESC>[32;40m" will be matched as one unit.
  ]]
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
  "lpeg >= 1.0.0",
  "org.conman.parsers.utf8.char >= 1.0.0",
  "org.conman.parsers.utf8.control >= 1.0.0",
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
      ['org.conman.parsers.utf8'] = "utf8.lua"
    }
  }
}
