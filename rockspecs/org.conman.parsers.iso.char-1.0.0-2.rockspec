package = "org.conman.parsers.iso.char"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/isog-1.0.0/iso/char.lua",
  md5 = "0ea3af4124f7c7c92d57ede90a2bbc86",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ISO graphic characters",
  detailed   = [[
  	LPEG expression to match valid ISO graphic characters, for example. 
	those of ISO-8850-1.  This *does not* include matching those
	characters defined by ASCII.  To parse both ASCII and ISO
	extensions:

		char = require "org.conman.parsers.iso.char"
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
      ['org.conman.parsers.iso.char'] = "char.lua"
    }
  }
}
