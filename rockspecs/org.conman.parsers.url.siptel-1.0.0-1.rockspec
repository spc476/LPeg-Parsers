package = "org.conman.parsers.url.siptel"
version = "1.0.0-1"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/urlsiptel-1.0.0/url/siptel.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license = "LGPL",
  summary = [[Parse sip:, sips: and tel: URIs]],
  detailed = [[
	Parse sip:, sips: and tel: URIs into a Lua table.  Given that the
	two are intertwined semantically, both are included in this module. 
	]],
}

dependencies =
{
  "lua",
  "lpeg >= 1.0.1",
  "org.conman.parsers.abnf    >= 1.0.0",
  "org.conman.parsers.ip-text >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.url.siptel'] = "siptel.lua"
    }
  }
}
