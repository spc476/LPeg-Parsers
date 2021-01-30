package = "org.conman.parsers.json"
version = "1.1.1-3"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/json-1.1.1/json.lua",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "Parse JSON files",
  detailed   = [[
	Parse a JSON file into a Lua table.  This supports UTF-8 encoded
	JSON files.
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
      ['org.conman.parsers.json'] = "json.lua"
    }
  }
}

