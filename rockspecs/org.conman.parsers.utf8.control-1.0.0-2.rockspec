package = "org.conman.parsers.utf8.control"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/utf8c-1.0.0/utf8/control.lua",
  md5 = "46b93c198cbc0471a94a94e298f7d910",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ISO control characters",
  detailed   = [[
	This is an LPEG expression that matches a valid UTF-8 control
	character or control character sequence.  For example, this will
	match the following ISO control sequence:

		<ESC>[32;40m

	To match the UTF-8 *and* the ASCII control sets:

		control = require "org.conman.parsers.ascii.control"
		        + require "org.conman.parsers.utf8.control"
  ]]
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
  "lpeg >= 1.0.0",
  "org.conman.parsers.utf8.char >= 1.0.0",
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
      ['org.conman.parsers.utf8.control'] = "control.lua"
    }
  }
}
