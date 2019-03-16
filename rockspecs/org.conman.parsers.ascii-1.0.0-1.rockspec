package = "org.conman.parsers.ascii"
version = "1.0.0-1"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/ascii-1.0.0/ascii.lua",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ASCII characters",
  detailed   = [[
  	LPEG expression to match valid ASCII characters, both graphic and
	control sets.
  ]]
}

dependencies =
{
  "lua",
  "lpeg >= 1.0.0",
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
      ['org.conman.parsers.ascii'] = "ascii.lua"
    }
  }
}
