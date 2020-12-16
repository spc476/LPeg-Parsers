package = "org.conman.parsers.ini"
version = "1.0.1-2"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/ini-1.0.1/ini.lua",
  md5 = "73b83b44c6a64d932f344d0a6670229a",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "Parse INI files into a Lua table",
  detailed   = [[
	Provides a INI file parser that returns a Lua table from a INI
	file.  See the homepage for more details.
  ]]
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
  "lpeg >= 1.0.0"
}

build =
{
  type = "none",
  copy_directories = {},
  install = 
  {
    lua = 
    {
      ['org.conman.parsers.ini'] = "ini.lua"
    }
  }
}
