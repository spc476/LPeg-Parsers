package = "org.conman.parsers.ascii.ctrl"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/asciiC0-1.0.0/ascii/ctrl.lua",
  md5 = "7ee603a8d96973119c3176f1689a1b1d",
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
      ['org.conman.parsers.ascii.ctrl'] = "ctrl.lua"
    }
  }
}
