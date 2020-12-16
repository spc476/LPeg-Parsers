package = "org.conman.parsers.utf8.char"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/utf8g-1.0.0/utf8/char.lua",
  md5 = "b10ba6dd8ec9f711958960c102050743",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ISO graphic characters",
  detailed   = [[
  	LPEG expression to match valid UTF-8 graphic characters.  This *does
	not* include matching those characters defined by ASCII.  To parse
	both ASCII and UTF-8 extensions:

		char = require "org.conman.parsers.utf8.char"
                     + require "org.conman.parsers.ascii.char"
  ]]
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
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
      ['org.conman.parsers.utf8.char'] = "char.lua"
    }
  }
}
