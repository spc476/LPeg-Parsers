package = "org.conman.parsers.ip-text"
version = "1.0.0-1"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/ip-text-1.0.0/ip-text.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "Parse IPv4/IPv6 addresses",
  detailed   = [[
	Parse an IPv4 or IPv6 address.  The address is returned as text,
	unlike the org.conman.parsers.ip module.
  ]]
}

dependencies =
{
  "lua",
  "lpeg >= 0.12",
}

build =
{
  type = "none",
  copy_directories = {},
  install = 
  {
    lua = 
    {
      ['org.conman.parsers.ip-text'] = "ip-text.lua"
    }
  }
}
