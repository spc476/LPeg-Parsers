package = "org.conman.parsers.ascii.control"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/asciic-1.0.0/ascii/control.lua",
  md5 = "42e13275aefe9fb19bcba95a295c3207",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ASCII control characters",
  detailed   = [[
  	LPEG expression to match valid ASCII control characters.  Yes, this is
  	a two line module, what of it?
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
      ['org.conman.parsers.ascii.control'] = "control.lua"
    }
  }
}
