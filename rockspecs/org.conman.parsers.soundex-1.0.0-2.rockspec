package = "org.conman.parsers.soundex"
version = "1.0.0-2"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/soundex-1.0.0/soundex.lua",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "Generate the Soundex value for a given word",
  detailed = [[
	This is an LPEG expression that will return the Soundex value for a given word or name.
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
  copy_directory = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.soundex'] = "soundex.lua"
    }
  }
}
