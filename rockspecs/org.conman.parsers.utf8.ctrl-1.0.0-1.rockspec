package = "org.conman.parsers.utf8.ctrl"
version = "1.0.0-1"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/utf8C1-1.0.0/utf8/ctrl.lua",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to return UTF-8 control character names and associated data",
  detailed   = [[
	This returns an LPEG expression to convert a UTF-8 control character to its name and
	any associated data.  For example, the following sequence:

		<ESC>[32;40m

	will return "SGR" and a table with two elements, 32 and 40.  See the
	ECMA-48 standard for more information about these control codes.
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
      ['org.conman.parsers.utf8.ctrl'] = "ctrl.lua"
    }
  }
}
