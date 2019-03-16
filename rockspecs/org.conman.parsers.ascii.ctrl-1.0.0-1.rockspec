package = "org.conman.parsers.ascii.ctrl"
version = "1.0.0-1"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/asciiC0-1.0.0/ascii/ctrl.lua",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to return ASCII control character names",
  detailed   = [[
  	LPEG expression to convert an ASCII control character to its name.
  ]]
}

dependencies =
{
  "lua",
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
      ['org.conman.parsers.ascii.ctrl'] = "ctrl.lua"
    }
  }
}
