package = "org.conman.parsers.ascii.char"
version = "1.0.0-2"

source = 
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/asciig-1.0.0/ascii/char.lua",
  md5 = "c483ba9c0da62184f9f29e56fbae7dd4",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "LPEG expression to match valid ASCII graphic characters",
  detailed   = [[
  	LPEG expression to match valid ASCII graphic characters.  Yes, this is
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
      ['org.conman.parsers.ascii.char'] = "char.lua"
    }
  }
}
