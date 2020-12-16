package = "org.conman.parsers.ip"
version = "1.0.2-2"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/ip-1.0.2/ip.lua",
  md5 = "3fabd84057dc0fb4bab8ceab5f85deea",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "Parse IPv4/IPv6 addresses",
  detailed   = [[
	Parse an IPv4 or IPv6 address.  The address is returned as binary in
	network byte order.
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
      ['org.conman.parsers.ip'] = "ip.lua"
    }
  }
}
