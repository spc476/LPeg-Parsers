package = "org.conman.parsers.jsons"
version = "1.0.7-3"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/jsons-1.0.7/jsons.lua",
  md5 = "9917bb2705100bcfc772a0555de9aa17",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
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
      ['org.conman.parsers.jsons'] = "jsons.lua"
    }
  }
}

