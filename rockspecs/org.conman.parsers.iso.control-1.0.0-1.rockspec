package = "org.conman.parsers.iso.control"
version = "1.0.0-1"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/isoc-1.0.0/iso/control.lua",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ISO control characters",
  detailed   = [[
	This is an LPEG expression that matches a valid ISO control
	character or control character sequence.  For example, this will
	match the following ISO control sequence:

		<ESC>[32;40m

	To match the ISO *and* the ASCII control sets:

		control = require "org.conman.parsers.ascii.control"
		        + require "org.conman.parsers.iso.control"
  ]]
}

dependencies =
{
  "lua",
  "lpeg >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.iso.control'] = "control.lua"
    }
  }
}
