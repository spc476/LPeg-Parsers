package = "org.conman.parsers.strftime"
version = "1.0.0-2"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/strf-1.0.0/strftime.lua",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "Generate LPeg to parse strftime() format strings",
  detailed   = [[
	Given a format string for strftime() (or os.date() in Lua), generate
	LPeg code to parse a string of said format.
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
      ['org.conman.parsers.strftime'] = "strftime.lua"
    }
  }
}
