package = "org.conman.parsers.iso.ctrl"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/isoC1-1.0.0/iso/ctrl.lua",
  md5 = "c3a02b260477491a8004821697956aa3",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to return ISO control character names and associated data",
  detailed   = [[
	This returns an LPEG expression to convert an ISO control character to its name and
	any associated data.  For example, the following sequence:

		<ESC>[32;40m

	will return "SGR" and a table with two elements, 32 and 40.  See the
	ECMA-48 standard for more information about ISO control codes.
  ]]
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
  "lpeg >= 1.0.0",
  "org.conman.parsers.iso.char >= 1.0.0",
  "org.conman.parsers.ascii.char >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.iso.ctrl'] = "ctrl.lua"
    }
  }
}
