package = "org.conman.parsers.json"
version = "1.0.3-1"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/json-1.0.3/json.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "Parse JSON files",
  detailed   = [[
	Parse a JSON file into a Lua table.  This supports UTF-8 encoded
	JSON files.
  ]]
}

dependencies =
{
  "lua",
  "lpeg >= 0.10",
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

