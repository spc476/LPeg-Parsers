package = "org.conman.parsers.jsonS"
version = "1.0.0-1"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/jsonS-1.0.0/jsonS.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "Parse JSON files",
  detailed   = [[
	Parse a JSON file into a Lua table.  This supports UTF-8 encoded
	JSON files, and can handle much larger files than
	org.conman.parsers.json.  You can also stream data into the parser
	via a function instead of passing in the entire JSON dataset as a
	string.
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
      ['org.conman.parsers.jsonS'] = "jsonS.lua"
    }
  }
}

