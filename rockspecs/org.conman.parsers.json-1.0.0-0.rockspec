package = "org.conman.parsers.json"
version = "1.0.0-0"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/json-1.0.0/json.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "Parse JSON files",
  detailed   = [[
	Parse a JSON file into a Lua table.  This supports UTF-8 encoded
	JSON files.  Be warned, this module requires an experimental module
	that can compile C code embedded in Lua, which is not easy to
	install.

	You have been warned.
  ]]
}

dependencies =
{
  "lua",
  "lpeg >= 0.10",
  "org.conman.cc >= 1.0.0",
  "org.conman.iconv >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install = 
  {
    lua = 
    {
      ['org.conman.parsers.json'] = "json.lua"
    }
  }
}

